library(tidyverse)
library(tidytext)
library(SnowballC)


chain <- read_csv("processed_statements.csv")
# load data:
chains_mut <- read_csv("processed_statements.csv")

# build the "entire" dataset:
example <- chains_mut 
|>
  filter(Mutation == "original" & Selection == "random")

unique_statments <- unique(example$Statement)

full_chain <- tibble(Step = numeric(), ID = numeric(), Statement = factor())

for(s in 0:10){
  current_step <- filter(example, Step == s)
  full_IDs <- sample(current_step$ID, 50, replace = TRUE, prob = current_step$Count)
  current_step_full = tibble(Step = rep(s, 50), ID = full_IDs, Statement = unique_statments[full_IDs+1])
  full_chain <- bind_rows(full_chain, current_step_full)
}

full_chain_real <- tibble(Step = numeric(), ID = numeric(), Statement = factor())
for(s in 1:9){
  current_step <- filter(example, Step == s)
full_IDs = rep( current_step$ID,times=current_step$InPrompt)
  current_step_full = tibble(Step = rep(s, 50), ID = full_IDs , Statement = unique_statments[full_IDs+1])
  full_chain_real <- bind_rows(full_chain_real, current_step_full)
}
  
  
# pre-process for text mining:
chains_mut <- full_chain |>
  unnest_tokens(word, Statement) |>
  anti_join(stop_words, by = "word") |>
  mutate(stem = wordStem(word))
  
chains_mut_real <- full_chain_real |>
  unnest_tokens(word, Statement) |>
  anti_join(stop_words, by = "word") |>
  mutate(stem = wordStem(word))

# choose here the combination mutation/selection: (NOW I DO AT THE BEGINNING)
combination <- chains_mut |>
 # filter(Mutation == "original" & Selection == "random") |>
  group_by(Step) |>
  count(stem, sort = TRUE)

combination_real <- chains_mut_real |>
 # filter(Mutation == "original" & Selection == "random") |>
  group_by(Step) |>
  count(stem, sort = TRUE)

# plot single stem:
combination |>
  filter(stem == "boost") |>
  ggplot(aes(x = Step, y = n)) +
    geom_line() + geom_point() +
    theme_minimal() 

combination_real |>
  filter(stem == "boost") |>
  ggplot(aes(x = Step, y = n)) +
    geom_line() + geom_point() +
    theme_minimal()

# Add an identifier to each dataset
combination$source <- "predicted"
combination_real$source <- "real"

combined_data <- bind_rows(combination, combination_real)

combined_data |>
  filter(stem == "boost") |>
ggplot(aes(x = Step, y = n, color = source)) +
  geom_line() + 
  geom_point() + 
  theme_minimal()

# Combine the datasets
combined_data <- bind_rows(combination, combination_real)
# distribution:
combination |>
  group_by(stem) |>
  summarise(cumulative = sum(n)) |>
  arrange(-cumulative) |>
  ggplot(aes(x = seq_along(cumulative), y = cumulative)) +
    geom_line() +
    theme_minimal()
  

