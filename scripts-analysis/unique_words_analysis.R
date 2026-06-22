library(tidyverse)

models <- c(
  GPT35   = "GPT3.5_gennew_concatenated_files",
  Mistral = "Mistral-7B-Instruct-v0.3_gennew_concatenated_files_2",
  Qwen    = "Qwen2.5-7B-Instruct_gennew_concatenated_files_2"
)

operators <- c("attractive", "efficient", "original", "random")

# ── Load data: one row per (Model, Mutation, Selection) ──────────────────────
rows <- list()
for (mod in names(models)) {
  for (mut in operators) {
    for (sel in operators) {
      path <- file.path(models[mod], "freqWords", paste0("freqWords_", mut, "_", sel, ".csv"))
      n_words <- nrow(read_csv(path, show_col_types = FALSE))
      rows[[length(rows) + 1]] <- tibble(Model = mod, Mutation = mut, Selection = sel, uniqueWords = n_words)
    }
  }
}
data <- bind_rows(rows) |>
  mutate(across(c(Mutation, Selection), as.factor))

# ── Descriptive means ─────────────────────────────────────────────────────────
cat("--- Mean unique words by mutation operator (across all models and selection operators) ---\n")
data |>
  group_by(Mutation) |>
  summarise(mean = round(mean(uniqueWords)), sd = round(sd(uniqueWords)), .groups = "drop") |>
  arrange(desc(mean)) |>
  print()

cat("\n--- Mean unique words by mutation operator, per model ---\n")
data |>
  group_by(Model, Mutation) |>
  summarise(mean = round(mean(uniqueWords)), .groups = "drop") |>
  pivot_wider(names_from = Mutation, values_from = mean) |>
  print()

# ── Main effects: lm(uniqueWords ~ Mutation + Selection) per model ────────────
cat("\n--- Two-way ANOVA (Mutation + Selection) per model ---\n")
for (mod in names(models)) {
  cat("\nModel:", mod, "\n")
  d   <- filter(data, Model == mod)
  fit <- lm(uniqueWords ~ Mutation + Selection, data = d)
  av  <- anova(fit)
  ss  <- av$`Sum Sq`
  print(av)
  cat(sprintf("  eta2 Mutation=%.3f  eta2 Selection=%.3f\n",
              ss[1] / sum(ss), ss[2] / sum(ss)))
}

# ── Planned contrast: "original" vs. mean of other three ─────────────────────
cat("\n--- Planned contrast: original vs. (attractive + efficient + random) ---\n")
for (mod in names(models)) {
  d   <- filter(data, Model == mod) |>
    mutate(original_vs_rest = ifelse(Mutation == "original", 3, -1))
  fit <- lm(uniqueWords ~ original_vs_rest + Selection, data = d)
  co  <- summary(fit)$coefficients["original_vs_rest", ]
  cat(sprintf("%-8s  b=%.1f  t(9)=%.2f  p=%.4f\n",
              mod, co["Estimate"], co["t value"], co["Pr(>|t|)"]))
}
