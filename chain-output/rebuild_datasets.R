library(tidyverse)
library(tidytext)

# MUT:
# notice: 
# (i) combination Mutation == "attractive" & Selection == "random" seems to be missed
# (ii) combination Mutation == "efficient" & Selection == "random" has a 0 ID so I recoded it

# load data:
chains_mut <- read_csv("GPT3.5_mut_concatenated_files.csv")

# build the "entire" dataset:
full_chain <- tibble(Mutation = character(), Selection = character(), Step = numeric(), ID = numeric(), Statement = factor())

# go through all combinations:

# MUTATION == "original"
example <- chains_mut |>
  filter(Mutation == "original" & Selection == "attractive")

unique_statments <- unique(example$Statement)

for(s in 0:100){
  current_step <- filter(example, Step == s)
  full_IDs <- sample(current_step$ID, 50, replace = TRUE, prob = current_step$Count)
  current_step_full = tibble(
    Mutation = "original", Selection = "attractive",
    Step = rep(s, 50), ID = full_IDs, Statement = unique_statments[full_IDs])
  full_chain <- bind_rows(full_chain, current_step_full)
}
  
example <- chains_mut |>
  filter(Mutation == "original" & Selection == "random")

unique_statments <- unique(example$Statement)

for(s in 0:100){
  current_step <- filter(example, Step == s)
  full_IDs <- sample(current_step$ID, 50, replace = TRUE, prob = current_step$Count)
  current_step_full = tibble(
    Mutation = "original", Selection = "random",
    Step = rep(s, 50), ID = full_IDs, Statement = unique_statments[full_IDs])
  full_chain <- bind_rows(full_chain, current_step_full)
}

example <- chains_mut |>
  filter(Mutation == "original" & Selection == "original")

unique_statments <- unique(example$Statement)

for(s in 0:100){
  current_step <- filter(example, Step == s)
  full_IDs <- sample(current_step$ID, 50, replace = TRUE, prob = current_step$Count)
  current_step_full = tibble(
    Mutation = "original", Selection = "original",
    Step = rep(s, 50), ID = full_IDs, Statement = unique_statments[full_IDs])
  full_chain <- bind_rows(full_chain, current_step_full)
}

example <- chains_mut |>
  filter(Mutation == "original" & Selection == "efficient")

unique_statments <- unique(example$Statement)

for(s in 0:100){
  current_step <- filter(example, Step == s)
  full_IDs <- sample(current_step$ID, 50, replace = TRUE, prob = current_step$Count)
  current_step_full = tibble(
    Mutation = "original", Selection = "attractive",
    Step = rep(s, 50), ID = full_IDs, Statement = unique_statments[full_IDs])
  full_chain <- bind_rows(full_chain, current_step_full)
}

# MUTATION == "random"
example <- chains_mut |>
  filter(Mutation == "random" & Selection == "attractive")

unique_statments <- unique(example$Statement)

for(s in 0:100){
  current_step <- filter(example, Step == s)
  full_IDs <- sample(current_step$ID, 50, replace = TRUE, prob = current_step$Count)
  current_step_full = tibble(
    Mutation = "random", Selection = "attractive",
    Step = rep(s, 50), ID = full_IDs, Statement = unique_statments[full_IDs])
  full_chain <- bind_rows(full_chain, current_step_full)
}

example <- chains_mut |>
  filter(Mutation == "random" & Selection == "random")

unique_statments <- unique(example$Statement)

for(s in 0:100){
  current_step <- filter(example, Step == s)
  full_IDs <- sample(current_step$ID, 50, replace = TRUE, prob = current_step$Count)
  current_step_full = tibble(
    Mutation = "random", Selection = "random",
    Step = rep(s, 50), ID = full_IDs, Statement = unique_statments[full_IDs])
  full_chain <- bind_rows(full_chain, current_step_full)
}

example <- chains_mut |>
  filter(Mutation == "random" & Selection == "original")

unique_statments <- unique(example$Statement)

for(s in 0:100){
  current_step <- filter(example, Step == s)
  full_IDs <- sample(current_step$ID, 50, replace = TRUE, prob = current_step$Count)
  current_step_full = tibble(
    Mutation = "random", Selection = "original",
    Step = rep(s, 50), ID = full_IDs, Statement = unique_statments[full_IDs])
  full_chain <- bind_rows(full_chain, current_step_full)
}

example <- chains_mut |>
  filter(Mutation == "random" & Selection == "efficient")

unique_statments <- unique(example$Statement)

for(s in 0:100){
  current_step <- filter(example, Step == s)
  full_IDs <- sample(current_step$ID, 50, replace = TRUE, prob = current_step$Count)
  current_step_full = tibble(
    Mutation = "random", Selection = "attractive",
    Step = rep(s, 50), ID = full_IDs, Statement = unique_statments[full_IDs])
  full_chain <- bind_rows(full_chain, current_step_full)
}

# MUTATION == "attractive"
example <- chains_mut |>
  filter(Mutation == "attractive" & Selection == "attractive")

unique_statments <- unique(example$Statement)

for(s in 0:100){
  current_step <- filter(example, Step == s)
  full_IDs <- sample(current_step$ID, 50, replace = TRUE, prob = current_step$Count)
  current_step_full = tibble(
    Mutation = "attractive", Selection = "attractive",
    Step = rep(s, 50), ID = full_IDs, Statement = unique_statments[full_IDs])
  full_chain <- bind_rows(full_chain, current_step_full)
}

# MISSING
# example <- chains_mut |>
#   filter(Mutation == "attractive" & Selection == "random")
# 
# unique_statments <- unique(example$Statement)
# 
# for(s in 0:100){
#   current_step <- filter(example, Step == s)
#   full_IDs <- sample(current_step$ID, 50, replace = TRUE, prob = current_step$Count)
#   current_step_full = tibble(
#     Mutation = "attractive", Selection = "random",
#     Step = rep(s, 50), ID = full_IDs, Statement = unique_statments[full_IDs])
#   full_chain <- bind_rows(full_chain, current_step_full)
# }

example <- chains_mut |>
  filter(Mutation == "attractive" & Selection == "original")

unique_statments <- unique(example$Statement)

for(s in 0:100){
  current_step <- filter(example, Step == s)
  full_IDs <- sample(current_step$ID, 50, replace = TRUE, prob = current_step$Count)
  current_step_full = tibble(
    Mutation = "attractive", Selection = "original",
    Step = rep(s, 50), ID = full_IDs, Statement = unique_statments[full_IDs])
  full_chain <- bind_rows(full_chain, current_step_full)
}

example <- chains_mut |>
  filter(Mutation == "attractive" & Selection == "attractive")

unique_statments <- unique(example$Statement)

for(s in 0:100){
  current_step <- filter(example, Step == s)
  full_IDs <- sample(current_step$ID, 50, replace = TRUE, prob = current_step$Count)
  current_step_full = tibble(
    Mutation = "attractive", Selection = "attractive",
    Step = rep(s, 50), ID = full_IDs, Statement = unique_statments[full_IDs])
  full_chain <- bind_rows(full_chain, current_step_full)
}

# MUTATION == "efficient"
example <- chains_mut |>
  filter(Mutation == "efficient" & Selection == "attractive")

unique_statments <- unique(example$Statement)

for(s in 0:100){
  current_step <- filter(example, Step == s)
  full_IDs <- sample(current_step$ID, 50, replace = TRUE, prob = current_step$Count)
  current_step_full = tibble(
    Mutation = "efficient", Selection = "attractive",
    Step = rep(s, 50), ID = full_IDs, Statement = unique_statments[full_IDs])
  full_chain <- bind_rows(full_chain, current_step_full)
}

example <- chains_mut |>
  filter(Mutation == "efficient" & Selection == "random")
# there is a zero here, so I have to recode manually IDs!!!!!
example$ID[example$ID >=10] = example$ID[example$ID >=10] + 1
example$ID[example$ID == 0] = 10
unique_statments <- unique(example$Statement)

for(s in 0:100){
  current_step <- filter(example, Step == s)
  full_IDs <- sample(current_step$ID, 50, replace = TRUE, prob = current_step$Count)
  current_step_full = tibble(
    Mutation = "efficient", Selection = "random",
    Step = rep(s, 50), ID = full_IDs, Statement = unique_statments[full_IDs])
  full_chain <- bind_rows(full_chain, current_step_full)
}

example <- chains_mut |>
  filter(Mutation == "efficient" & Selection == "original")

unique_statments <- unique(example$Statement)

for(s in 0:100){
  current_step <- filter(example, Step == s)
  full_IDs <- sample(current_step$ID, 50, replace = TRUE, prob = current_step$Count)
  current_step_full = tibble(
    Mutation = "efficient", Selection = "original",
    Step = rep(s, 50), ID = full_IDs, Statement = unique_statments[full_IDs])
  full_chain <- bind_rows(full_chain, current_step_full)
}

example <- chains_mut |>
  filter(Mutation == "efficient" & Selection == "attractive")

unique_statments <- unique(example$Statement)

for(s in 0:100){
  current_step <- filter(example, Step == s)
  full_IDs <- sample(current_step$ID, 50, replace = TRUE, prob = current_step$Count)
  current_step_full = tibble(
    Mutation = "efficient", Selection = "attractive",
    Step = rep(s, 50), ID = full_IDs, Statement = unique_statments[full_IDs])
  full_chain <- bind_rows(full_chain, current_step_full)
}

write_csv(full_chain, file = "GPT3.5_mut_concatenated_files_FULL.csv")

################################################################################
################################################################################
################################################################################
# GENNEW:
# load data:
chains_gen <- read_csv("GPT3.5_gennew_concatenated_files.csv")
# notice: 
# (i) combination Mutation == "attractive" & Selection == "random" seems to be missed
# (ii) combination Mutation == "attractive" & Selection == "original") seems to be missed
# (iii) combination Mutation == "efficient" & Selection == "random" has a 0 ID so I recoded it
# (iv) combination Mutation == "random" & Selection == "original" has a 0 ID so I recoded it

# build the "entire" dataset:
full_chain <- tibble(Mutation = character(), Selection = character(), Step = numeric(), ID = numeric(), Statement = factor())

# go through all combinations:

# MUTATION == "original"
example <- chains_gen |>
  filter(Mutation == "original" & Selection == "attractive")

unique_statments <- unique(example$Statement)

for(s in 0:100){
  current_step <- filter(example, Step == s)
  full_IDs <- sample(current_step$ID, 50, replace = TRUE, prob = current_step$Count)
  current_step_full = tibble(
    Mutation = "original", Selection = "attractive",
    Step = rep(s, 50), ID = full_IDs, Statement = unique_statments[full_IDs])
  full_chain <- bind_rows(full_chain, current_step_full)
}

example <- chains_gen |>
  filter(Mutation == "original" & Selection == "random")

unique_statments <- unique(example$Statement)

for(s in 0:100){
  current_step <- filter(example, Step == s)
  full_IDs <- sample(current_step$ID, 50, replace = TRUE, prob = current_step$Count)
  current_step_full = tibble(
    Mutation = "original", Selection = "random",
    Step = rep(s, 50), ID = full_IDs, Statement = unique_statments[full_IDs])
  full_chain <- bind_rows(full_chain, current_step_full)
}

example <- chains_gen |>
  filter(Mutation == "original" & Selection == "original")

unique_statments <- unique(example$Statement)

for(s in 0:100){
  current_step <- filter(example, Step == s)
  full_IDs <- sample(current_step$ID, 50, replace = TRUE, prob = current_step$Count)
  current_step_full = tibble(
    Mutation = "original", Selection = "original",
    Step = rep(s, 50), ID = full_IDs, Statement = unique_statments[full_IDs])
  full_chain <- bind_rows(full_chain, current_step_full)
}

example <- chains_gen |>
  filter(Mutation == "original" & Selection == "efficient")

unique_statments <- unique(example$Statement)

for(s in 0:100){
  current_step <- filter(example, Step == s)
  full_IDs <- sample(current_step$ID, 50, replace = TRUE, prob = current_step$Count)
  current_step_full = tibble(
    Mutation = "original", Selection = "attractive",
    Step = rep(s, 50), ID = full_IDs, Statement = unique_statments[full_IDs])
  full_chain <- bind_rows(full_chain, current_step_full)
}

# MUTATION == "random"
example <- chains_gen |>
  filter(Mutation == "random" & Selection == "attractive")

unique_statments <- unique(example$Statement)

for(s in 0:100){
  current_step <- filter(example, Step == s)
  full_IDs <- sample(current_step$ID, 50, replace = TRUE, prob = current_step$Count)
  current_step_full = tibble(
    Mutation = "random", Selection = "attractive",
    Step = rep(s, 50), ID = full_IDs, Statement = unique_statments[full_IDs])
  full_chain <- bind_rows(full_chain, current_step_full)
}

example <- chains_gen |>
  filter(Mutation == "random" & Selection == "random")

unique_statments <- unique(example$Statement)

for(s in 0:100){
  current_step <- filter(example, Step == s)
  full_IDs <- sample(current_step$ID, 50, replace = TRUE, prob = current_step$Count)
  current_step_full = tibble(
    Mutation = "random", Selection = "random",
    Step = rep(s, 50), ID = full_IDs, Statement = unique_statments[full_IDs])
  full_chain <- bind_rows(full_chain, current_step_full)
}

example <- chains_gen |>
  filter(Mutation == "random" & Selection == "original")
# there is a zero here, so I have to recode manually IDs!
example$ID[example$ID >=10] = example$ID[example$ID >=10] + 1
example$ID[example$ID == 0] = 10
unique_statments <- unique(example$Statement)

for(s in 0:100){
  current_step <- filter(example, Step == s)
  full_IDs <- sample(current_step$ID, 50, replace = TRUE, prob = current_step$Count)
  current_step_full = tibble(
    Mutation = "random", Selection = "original",
    Step = rep(s, 50), ID = full_IDs, Statement = unique_statments[full_IDs])
  full_chain <- bind_rows(full_chain, current_step_full)
}

example <- chains_gen |>
  filter(Mutation == "random" & Selection == "efficient")

unique_statments <- unique(example$Statement)

for(s in 0:100){
  current_step <- filter(example, Step == s)
  full_IDs <- sample(current_step$ID, 50, replace = TRUE, prob = current_step$Count)
  current_step_full = tibble(
    Mutation = "random", Selection = "attractive",
    Step = rep(s, 50), ID = full_IDs, Statement = unique_statments[full_IDs])
  full_chain <- bind_rows(full_chain, current_step_full)
}

# MUTATION == "attractive"
example <- chains_gen |>
  filter(Mutation == "attractive" & Selection == "attractive")

unique_statments <- unique(example$Statement)

for(s in 0:100){
  current_step <- filter(example, Step == s)
  full_IDs <- sample(current_step$ID, 50, replace = TRUE, prob = current_step$Count)
  current_step_full = tibble(
    Mutation = "attractive", Selection = "attractive",
    Step = rep(s, 50), ID = full_IDs, Statement = unique_statments[full_IDs])
  full_chain <- bind_rows(full_chain, current_step_full)
}

# MISSING
# example <- chains_gen |>
#   filter(Mutation == "attractive" & Selection == "random")
# 
# unique_statments <- unique(example$Statement)
# 
# for(s in 0:100){
#   current_step <- filter(example, Step == s)
#   full_IDs <- sample(current_step$ID, 50, replace = TRUE, prob = current_step$Count)
#   current_step_full = tibble(
#     Mutation = "attractive", Selection = "random",
#     Step = rep(s, 50), ID = full_IDs, Statement = unique_statments[full_IDs])
#   full_chain <- bind_rows(full_chain, current_step_full)
# }

# example <- chains_gen |>
#   filter(Mutation == "attractive" & Selection == "original")
# 
# unique_statments <- unique(example$Statement)
# 
# for(s in 0:100){
#   current_step <- filter(example, Step == s)
#   full_IDs <- sample(current_step$ID, 50, replace = TRUE, prob = current_step$Count)
#   current_step_full = tibble(
#     Mutation = "attractive", Selection = "original",
#     Step = rep(s, 50), ID = full_IDs, Statement = unique_statments[full_IDs])
#   full_chain <- bind_rows(full_chain, current_step_full)
# }

example <- chains_gen |>
  filter(Mutation == "attractive" & Selection == "attractive")

unique_statments <- unique(example$Statement)

for(s in 0:100){
  current_step <- filter(example, Step == s)
  full_IDs <- sample(current_step$ID, 50, replace = TRUE, prob = current_step$Count)
  current_step_full = tibble(
    Mutation = "attractive", Selection = "attractive",
    Step = rep(s, 50), ID = full_IDs, Statement = unique_statments[full_IDs])
  full_chain <- bind_rows(full_chain, current_step_full)
}

# MUTATION == "efficient"
example <- chains_gen |>
  filter(Mutation == "efficient" & Selection == "attractive")

unique_statments <- unique(example$Statement)

for(s in 0:100){
  current_step <- filter(example, Step == s)
  full_IDs <- sample(current_step$ID, 50, replace = TRUE, prob = current_step$Count)
  current_step_full = tibble(
    Mutation = "efficient", Selection = "attractive",
    Step = rep(s, 50), ID = full_IDs, Statement = unique_statments[full_IDs])
  full_chain <- bind_rows(full_chain, current_step_full)
}

example <- chains_gen |>
  filter(Mutation == "efficient" & Selection == "random")
# there is a zero here, so I have to recode manually IDs!
example$ID[example$ID >=10] = example$ID[example$ID >=10] + 1
example$ID[example$ID == 0] = 10
unique_statments <- unique(example$Statement)

for(s in 0:100){
  current_step <- filter(example, Step == s)
  full_IDs <- sample(current_step$ID, 50, replace = TRUE, prob = current_step$Count)
  current_step_full = tibble(
    Mutation = "efficient", Selection = "random",
    Step = rep(s, 50), ID = full_IDs, Statement = unique_statments[full_IDs])
  full_chain <- bind_rows(full_chain, current_step_full)
}

example <- chains_gen |>
  filter(Mutation == "efficient" & Selection == "original")

unique_statments <- unique(example$Statement)

for(s in 0:100){
  current_step <- filter(example, Step == s)
  full_IDs <- sample(current_step$ID, 50, replace = TRUE, prob = current_step$Count)
  current_step_full = tibble(
    Mutation = "efficient", Selection = "original",
    Step = rep(s, 50), ID = full_IDs, Statement = unique_statments[full_IDs])
  full_chain <- bind_rows(full_chain, current_step_full)
}

example <- chains_gen |>
  filter(Mutation == "efficient" & Selection == "attractive")

unique_statments <- unique(example$Statement)

for(s in 0:100){
  current_step <- filter(example, Step == s)
  full_IDs <- sample(current_step$ID, 50, replace = TRUE, prob = current_step$Count)
  current_step_full = tibble(
    Mutation = "efficient", Selection = "attractive",
    Step = rep(s, 50), ID = full_IDs, Statement = unique_statments[full_IDs])
  full_chain <- bind_rows(full_chain, current_step_full)
}

write_csv(full_chain, file = "GPT3.5_gennew_concatenated_files_FULL.csv")