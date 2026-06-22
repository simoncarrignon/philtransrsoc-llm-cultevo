# Get the raw posterior numbers from the ABC output.
posteriors <- readRDS(file.path("abc", "output", "list_allposteriors_rep01.RDS"))

modelnames <- c("GPT3.5", "Mistral 7B", "Qwen 2.5")
models <- c(
  "gpt3.5_generate_new_statements",
  "mistral-7b-instruct-v0.3_generate_new_statements",
  "qwen2.5-7b-instruct_generate_new_statements"
)
names(modelnames) <- models

operators <- c("attractive", "efficient", "original", "random")

#extract value for CrI
posterior_interval <- function(x) {
  c(
    mid = median(x),
    lwr = unname(quantile(x, 0.025)),
    upr = unname(quantile(x, 0.975))
  )
}

#show the metrics shown in the paper
delta_summary <- function(delta_beta, delta_J) {
  beta <- posterior_interval(delta_beta)
  J <- posterior_interval(delta_J)
  data.frame(
    delta_beta = unname(beta["mid"]),
    beta_lwr = unname(beta["lwr"]),
    beta_upr = unname(beta["upr"]),
    delta_J = unname(J["mid"]),
    J_lwr = unname(J["lwr"]),
    J_upr = unname(J["upr"])
  )
}

#sample the posterior (with replacement)
sample_posterior_draws <- function(raw_numbers, n_draws = 2000) {
  draws <- lapply(split(raw_numbers, interaction(raw_numbers$model, raw_numbers$mutation, raw_numbers$selection, drop = TRUE)), function(x) {
    x <- x[sample(seq_len(nrow(x)), n_draws, replace = TRUE), ]
    x$posterior_draw <- sample(seq_len(n_draws))
    x
  })
  do.call(rbind, draws)
}

#impact of selection
selection_contrast <- function(data, baseline, other) {
  cell_means <- aggregate(
    cbind(beta, J) ~ posterior_draw + selection,
    data = data[data$selection %in% c(baseline, other), ],
    mean
  )
  wide_beta <- reshape(cell_means[c("posterior_draw", "selection", "beta")], idvar = "posterior_draw", timevar = "selection", direction = "wide")
  wide_J <- reshape(cell_means[c("posterior_draw", "selection", "J")], idvar = "posterior_draw", timevar = "selection", direction = "wide")
  delta_beta <- wide_beta[[paste0("beta.", baseline)]] - wide_beta[[paste0("beta.", other)]]
  delta_J <- wide_J[[paste0("J.", baseline)]] - wide_J[[paste0("J.", other)]]
  cbind(contrast = paste(baseline, other, sep = " - "), delta_summary(delta_beta, delta_J))
}

raw_delta_summary <- function(first, second, n_draws = 20000) {
  set.seed(123)
  i_first <- sample(seq_len(nrow(first)), n_draws, replace = TRUE)
  i_second <- sample(seq_len(nrow(second)), n_draws, replace = TRUE)
  delta_summary(first$beta[i_first] - second$beta[i_second], first$J[i_first] - second$J[i_second])
}

# Raw numbers are the J and beta values in adj.values for each model/mutation/selection cell.
raw_numbers <- do.call(rbind, lapply(names(modelnames), function(m) {
  do.call(rbind, lapply(operators, function(mut) {
    do.call(rbind, lapply(operators, function(sel) {
      key <- paste(mut, sel, sep = "_")
      values <- as.data.frame(unname(posteriors[[m]]$alladjustment[[key]]$adj.values))
      colnames(values)[1:2] <- c("J", "beta")
      cbind(
        model = unname(modelnames[m]),
        mutation = mut,
        selection = sel,
        values
      )
    }))
  }))
}))

rownames(raw_numbers) <- NULL

# Match each scenario to 2000 posterior draws so ranges and contrasts are compared draw-by-draw.
set.seed(123)
posterior_draws <- sample_posterior_draws(raw_numbers)

# Test which factor has the largest posterior range in beta and J.
factor_ranges <- do.call(rbind, lapply(c("model", "mutation", "selection"), function(f) {
  cell_means <- aggregate(
    cbind(beta, J) ~ posterior_draw + level,
    data = data.frame(
      posterior_draw = posterior_draws$posterior_draw,
      level = posterior_draws[[f]],
      beta = posterior_draws$beta,
      J = posterior_draws$J
    ),
    mean
  )
  beta_range <- tapply(cell_means$beta, cell_means$posterior_draw, function(x) max(x) - min(x))
  J_range <- tapply(cell_means$J, cell_means$posterior_draw, function(x) max(x) - min(x))
  beta <- posterior_interval(beta_range)
  J <- posterior_interval(J_range)
  data.frame(
    factor = f,
    R_beta = unname(beta["mid"]),
    R_beta_lwr = unname(beta["lwr"]),
    R_beta_upr = unname(beta["upr"]),
    R_J = unname(J["mid"]),
    R_J_lwr = unname(J["lwr"]),
    R_J_upr = unname(J["upr"])
  )
}))
print(factor_ranges)

# Test random selection against the other selection operators within Mistral 7B.
mistral_random_selection <- do.call(rbind, lapply(setdiff(operators, "random"), function(other) {
  selection_contrast(posterior_draws[posterior_draws$model == "Mistral 7B", ], "random", other)
}))
print(mistral_random_selection)

# Test random selection against the other selection operators within Qwen 2.5.
qwen_random_selection <- do.call(rbind, lapply(setdiff(operators, "random"), function(other) {
  selection_contrast(posterior_draws[posterior_draws$model == "Qwen 2.5", ], "random", other)
}))
print(qwen_random_selection)

# Test whether GPT3.5 beta is near zero only under random selection.
gpt35_beta_by_selection <- do.call(rbind, lapply(operators, function(sel) {
  by_draw <- aggregate(beta ~ posterior_draw, data = posterior_draws[posterior_draws$model == "GPT3.5" & posterior_draws$selection == sel, ], mean)
  beta <- posterior_interval(by_draw$beta)
  data.frame(
    selection = sel,
    beta = unname(beta["mid"]),
    beta_lwr = unname(beta["lwr"]),
    beta_upr = unname(beta["upr"])
  )
}))

# Test efficient versus random selection with original mutation for each model.
efficient_vs_random_original_mutation <- do.call(rbind, lapply(modelnames, function(m) {
  efficient <- raw_numbers[raw_numbers$model == m & raw_numbers$mutation == "original" & raw_numbers$selection == "efficient", ]
  random <- raw_numbers[raw_numbers$model == m & raw_numbers$mutation == "original" & raw_numbers$selection == "random", ]
  cbind(model = m, raw_delta_summary(efficient, random))
}))
efficient_vs_random_original_mutation
