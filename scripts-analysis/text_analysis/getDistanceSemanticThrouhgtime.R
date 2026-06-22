args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 1L) {
  stop("Usage: Rscript getDistanceSemanticThrouhgtime.R <simulation_csv_without_.csv>")
}
simu_file <- args[[1]]

norm_txt <- function(x) gsub("[[:space:]]+", " ", trimws(as.character(x)))

dist_summary <- function(x, prefix) {
  x <- as.vector(x)
  x <- x[is.finite(x)]

  if (!length(x)) {
    return(c(
      setNames(NA_real_, paste0("Mean", prefix)),
      setNames(NA_real_, paste0("S", prefix)),
      setNames(NA_real_, paste0("Median", prefix)),
      setNames(NA_real_, paste0("Q75", prefix))
    ))
  }

  c(
    setNames(mean(x), paste0("Mean", prefix)),
    setNames(sd(x), paste0("S", prefix)),
    setNames(median(x), paste0("Median", prefix)),
    setNames(
      as.numeric(quantile(x, probs = 0.75, names = FALSE)),
      paste0("Q75", prefix)
    )
  )
}

normalize_rows <- function(x) {
  x <- as.matrix(x)
  storage.mode(x) <- "double"

  norm <- sqrt(rowSums(x * x))
  if (any(!is.finite(norm) | norm == 0)) {
    stop("Found an embedding row with zero or non-finite length.")
  }

  sweep(x, 1L, norm, "/")
}

cosine_distance <- function(a, b = NULL) {
  a <- normalize_rows(a)

  if (is.null(b)) {
    sim <- tcrossprod(a)
  } else {
    b <- normalize_rows(b)
    sim <- tcrossprod(a, b)
  }

  sim <- pmax(pmin(sim, 1), -1)
  1 - sim
}

upper_pair_values <- function(d) {
  if (nrow(d) < 2L) {
    return(NA_real_)
  }
  d[upper.tri(d, diag = FALSE)]
}

get_metrics <- function(x, init) {
  d_within <- upper_pair_values(cosine_distance(x))
  d_init <- cosine_distance(x, init)
  d_init_nearest <- apply(d_init, 1L, min)

  c(
    dist_summary(d_within, "DistWithin"),
    dist_summary(d_init_nearest, "DistInit"),
    dist_summary(d_init, "DistInitAll")
  )
}

suffix_names <- function(x, suffix) {
  names(x) <- paste0(names(x), suffix)
  x
}

metric_df <- function(x) {
  as.data.frame(as.list(x), check.names = FALSE)
}

simu_time <- read.csv(paste0(simu_file, ".csv"), stringsAsFactors = FALSE)
alld <- read.csv(
  file.path("embeddings", paste0(basename(simu_file), "_statement_embeddings.csv")),
  stringsAsFactors = FALSE,
  check.names = FALSE
)

embed_cols <- grep("^embedding_", names(alld), value = TRUE)
if (!length(embed_cols)) {
  stop("No embedding columns found. Expected columns named embedding_*.")
}

alld$statement_norm <- norm_txt(alld$Statement)
init <- as.matrix(alld[alld$Step == 0, embed_cols, drop = FALSE])
if (!nrow(init)) {
  stop("No initial embeddings found with Step == 0.")
}

out <- list()
i <- 1L

for (mut in unique(simu_time$Mutation)) {
  for (sel in unique(simu_time$Selection)) {
    exp <- simu_time[simu_time$Mutation == mut & simu_time$Selection == sel, ]
    message(sel, " ", mut)

    for (tstep in sort(unique(exp$Step))) {
      step_df <- exp[exp$Step == tstep, ]
      idx <- match(norm_txt(step_df$Statement), alld$statement_norm)
      if (anyNA(idx)) {
        missing_statements <- unique(step_df$Statement[is.na(idx)])
        stop(
          "Could not match ", length(missing_statements),
          " statement(s) to embeddings for ",
          mut, " / ", sel, " at step ", tstep, "."
        )
      }
      step_emb <- as.matrix(alld[idx, embed_cols, drop = FALSE])

      cnt <- step_df$InPrompts
      cnt[is.na(cnt) | cnt < 0] <- 0
      cnt <- as.integer(round(cnt))

      if (tstep == 0) {
        weighted_idx <- idx
        weight_mode <- "InitialStatements"
      } else if (sum(cnt) > 0) {
        weighted_idx <- rep(idx, cnt)
        weight_mode <- "InPrompts"
      } else {
        prob <- step_df$Count
        prob[is.na(prob) | prob < 0] <- 0
        if (sum(prob) == 0) {
          prob <- rep(1, length(prob))
        }
        weighted_idx <- sample(idx, size = 50, replace = TRUE, prob = prob)
        weight_mode <- "CountSample50"
      }

      weighted_emb <- as.matrix(alld[weighted_idx, embed_cols, drop = FALSE])
      raw <- get_metrics(step_emb, init)
      weighted <- get_metrics(weighted_emb, init)
      metric_values <- c(raw, suffix_names(weighted, "Weighted"))

      out[[i]] <- cbind(
        data.frame(
          Step = tstep,
          DistanceMetric = "cosine_distance",
          DistInitDefinition = "nearest_initial",
          DistInitAllDefinition = "all_initial_pairwise",
          RawN = nrow(step_emb),
          WeightedN = nrow(weighted_emb),
          WeightMode = weight_mode,
          stringsAsFactors = FALSE
        ),
        metric_df(metric_values),
        data.frame(
          Mutation = mut,
          Selection = sel,
          stringsAsFactors = FALSE
        )
      )
      i <- i + 1L
    }
  }
}

dischange <- do.call(rbind, out)
write.csv(
  dischange,
  file = file.path("embeddings", paste0(basename(simu_file), "_embeddings_distances.csv")),
  row.names = FALSE
)
