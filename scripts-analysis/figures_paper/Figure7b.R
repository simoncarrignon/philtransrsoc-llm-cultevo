## Minimal real-distance example for interpreting cosine distances.
## Uses existing embeddings created by embed_statement.py and the same
## row-normalized cosine distance calculation as getDistanceSemanticThrouhgtime.R.

normalize_rows <- function(x) {
  x <- as.matrix(x)
  sweep(x, 1L, sqrt(rowSums(x * x)), "/")
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

read_embedding_file <- function(path, source) {
  d <- read.csv(path, stringsAsFactors = FALSE, check.names = FALSE)
  embed_cols <- grep("^embedding_", names(d), value = TRUE)

  if (!length(embed_cols)) {
    stop("No embedding columns found in ", path, call. = FALSE)
  }

  meta <- data.frame(
    Source = source,
    ID = if ("ID" %in% names(d)) as.character(d$ID) else NA_character_,
    Step = if ("Step" %in% names(d)) as.character(d$Step) else NA_character_,
    Mutation = if ("Mutation" %in% names(d)) as.character(d$Mutation) else NA_character_,
    Selection = if ("Selection" %in% names(d)) as.character(d$Selection) else NA_character_,
    Domain = if ("Domain" %in% names(d)) as.character(d$Domain) else NA_character_,
    Statement = d$Statement,
    stringsAsFactors = FALSE
  )

  cbind(meta, d[, embed_cols, drop = FALSE])
}

nearest_row <- function(d, target, source_filter = NULL, exclude_statement = NULL) {
  x <- d

  if (!is.null(source_filter)) {
    x <- x[x$Source %in% source_filter, ]
  }
  if (!is.null(exclude_statement)) {
    x <- x[x$Statement != exclude_statement, ]
  }

  x <- x[!duplicated(x$Statement), ]
  x[which.min(abs(x$DistanceToA - target)), ]
}

mean_pairwise_distance <- function(mat) {
  d <- cosine_distance(mat)
  mean(d[upper.tri(d, diag = FALSE)], na.rm = TRUE)
}

wrap_label <- function(x, width = 32) {
  paste(strwrap(x, width = width), collapse = "\n")
}

files <- c(
  "Mistral" = "../text_analysis/embeddings/Mistral-7B-Instruct-v0.3_gennew_concatenated_files_1_statement_embeddings.csv",
  "GPT3.5" = "../text_analysis/embeddings/GPT3.5_gennew_concatenated_files_statement_embeddings.csv",
  "Qwen2.5" = "../text_analysis/embeddings/Qwen2.5-7B-Instruct_gennew_concatenated_files_1_statement_embeddings.csv",
  "Length-matched outgroup" = "../text_analysis/embeddings/length_matched_outgroup_statement_embeddings.csv",
  "Random facts outgroup" = "../text_analysis/embeddings/random_facts_outgroup_statement_embeddings.csv",
  "Reference outgroup" = "../text_analysis/embeddings/reference_outgroup_statement_embeddings.csv"
)

all_embeddings <- do.call(
  rbind,
  Map(read_embedding_file, files, names(files))
)

embed_cols <- grep("^embedding_", names(all_embeddings), value = TRUE)
analysed_sources <- c("Mistral", "GPT3.5", "Qwen2.5")
all_embeddings$StepNum <- suppressWarnings(as.numeric(all_embeddings$Step))

A_statement <- paste(
  "Incorporating a variety of fruits and vegetables into your meals ensures",
  "you receive a spectrum of vitamins and minerals, vital for boosting immunity",
  "and enhancing your energy levels, contributing to an overall healthier you."
)

A_idx <- which(all_embeddings$Statement == A_statement)[1]
if (is.na(A_idx)) {
  stop("Could not find the chosen A statement in existing embeddings.", call. = FALSE)
}

A_embedding <- as.matrix(all_embeddings[A_idx, embed_cols, drop = FALSE])
all_embeddings$DistanceToA <- as.vector(
  cosine_distance(A_embedding, as.matrix(all_embeddings[, embed_cols, drop = FALSE]))
)

A_row <- all_embeddings[A_idx, ]
B_row <- nearest_row(
  all_embeddings,
  target = 0.30,
  source_filter = analysed_sources,
  exclude_statement = A_statement
)
C_row <- nearest_row(
  all_embeddings,
  target = 0.50,
  source_filter = analysed_sources,
  exclude_statement = A_statement
)
D_row <- nearest_row(
  all_embeddings,
  target = 0.70,
  source_filter = analysed_sources,
  exclude_statement = A_statement
)
E_row <- nearest_row(
  all_embeddings,
  target = 0.90,
  source_filter = "Length-matched outgroup",
  exclude_statement = A_statement
)

example_rows <- rbind(A_row, B_row, C_row, D_row, E_row)
example_rows$Label <- c("A", "B", "C", "D", "E")
example_rows$Interpretation <- c(
  "reference statement",
  "closest real paraphrase-like statement found in analysed data",
  "real analysed statement at the observed mean-distance scale",
  "real analysed statement farther away but still health-advice themed",
  "same-length different-topic outgroup statement"
)

example_table <- example_rows[, c(
  "Label",
  "Interpretation",
  "Source",
  "ID",
  "Step",
  "Mutation",
  "Selection",
  "Domain",
  "DistanceToA",
  "Statement"
)]
example_table$DistanceToA <- round(example_table$DistanceToA, 6)

initial_rows <- all_embeddings[
  all_embeddings$Source %in% analysed_sources &
    is.finite(all_embeddings$StepNum) &
    all_embeddings$StepNum == 0,
]
initial_rows <- initial_rows[!duplicated(initial_rows$Statement), ]
initial_mean <- mean_pairwise_distance(as.matrix(initial_rows[, embed_cols, drop = FALSE]))

generated_rows <- all_embeddings[
  all_embeddings$Source %in% analysed_sources &
    is.finite(all_embeddings$StepNum) &
    all_embeddings$StepNum > 0,
]
chain_id <- paste(
  generated_rows$Source,
  generated_rows$Mutation,
  generated_rows$Selection,
  sep = " | "
)
final_idx <- unlist(
  lapply(split(seq_len(nrow(generated_rows)), chain_id), function(idx) {
    idx[generated_rows$StepNum[idx] == max(generated_rows$StepNum[idx], na.rm = TRUE)]
  }),
  use.names = FALSE
)
final_rows <- generated_rows[final_idx, ]
final_rows <- final_rows[!duplicated(final_rows$Statement), ]
final_mean <- mean_pairwise_distance(as.matrix(final_rows[, embed_cols, drop = FALSE]))

benchmark_table <- data.frame(
  Benchmark = c(
    "mean pairwise distance among unique initial statements",
    "mean pairwise distance among unique final-step generated statements"
  ),
  NStatements = c(nrow(initial_rows), nrow(final_rows))
)

png("Figure7b.png", width = 1200, height = 1100, pointsize = 20)
grad_cols <- setNames(colorRampPalette(c("#0072B2", "#D55E00"))(4), c("B","C","D","E"))
cols <- c(A = "#444444", grad_cols)
plot_rows <- example_table
x <- seq_len(nrow(plot_rows))
x <- rep(0,nrow(plot_rows))
y <- plot_rows$DistanceToA

par(mar = c(4.0, 6.4, 3.0, 1), mgp = c(3.5, 1.0, 0), tcl = -0.35,xpd=F)
plot( x, y, type = "b", pch = 21, bg = cols[plot_rows$Label], col = "#222222", lwd = 3, cex = 2.1, xaxt = "n", xlab = "", ylab = "Cosine distance to A", xlim = c(0, 1), ylim = c(0, 1),frame.plot=F)
#axis(1, at = x, labels = plot_rows$Label, cex.axis = 1.0)
abline(h = initial_mean, lty = 2, lwd = 2.6, col = "#4D4D4D")
abline(h = final_mean, lty = 2, lwd = 2.6, col = "#8C510A")
text( .9, initial_mean, sprintf("initial mean = %.3f", initial_mean), pos = 3, cex = 0.78, col = "#333333", xpd = NA)
text( .9, final_mean, sprintf("final-step mean = %.3f", final_mean), pos = 3, cex = 0.78, col = "#6B3D00", xpd = NA,adj=1)
#title("Real cosine distances to statement A")
#box()
par(xpd=T)
for (i in seq_along(x)) {
  text( x[i], y[i], paste0("", wrap_label(paste(plot_rows$Label[i],":",plot_rows$Statement[i]), width = 84)), cex = 1.2, col = "#222222", pos=4)#adj=c(0,1))
}
dev.off()

