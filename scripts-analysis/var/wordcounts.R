library(tidyverse)
library(tidytext)
library(SnowballC)

# load data:
chains_mut <- read_csv("GPT3.5_mut_concatenated_files.csv")

# build the "entire" dataset:
example <- chains_mut |>
  filter(Mutation == "original" & Selection == "random")

unique_statments <- unique(example$Statement)

full_chain <- tibble(Step = numeric(), ID = numeric(), Statement = factor())

for(s in 0:100){
  current_step <- filter(example, Step == s)
  full_IDs <- sample(current_step$ID, 50, replace = TRUE, prob = current_step$Count)
  current_step_full = tibble(Step = rep(s, 50), ID = full_IDs, Statement = unique_statments[full_IDs])
  full_chain <- bind_rows(full_chain, current_step_full)
}
  
  
# pre-process for text mining:
chains_mut <- full_chain |>
  unnest_tokens(word, Statement) |>
  anti_join(stop_words, by = "word") |>
  mutate(stem = wordStem(word))

# choose here the combination mutation/selection: (NOW I DO AT THE BEGINNING)
combination <- chains_mut |>
 # filter(Mutation == "original" & Selection == "random") |>
  group_by(Step) |>
  count(stem, sort = TRUE)

# plot single stem:
combination |>
  filter(stem == "quinoa") |>
  ggplot(aes(x = Step, y = n)) +
    geom_line() + geom_point() +
    theme_minimal()

# distribution:
combination |>
  group_by(stem) |>
  summarise(cumulative = sum(n)) |>
  arrange(-cumulative) |>
  ggplot(aes(x = seq_along(cumulative), y = cumulative)) +
    geom_line() +
    theme_minimal()
  

