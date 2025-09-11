library(tidyverse)
library(tidytext)
library(SnowballC)

# load data:
chains_gen <- read_csv("../GPT3.5_gennew_concatenated_files_FULL.csv")

# pre-process for text mining:
chains_gen <- chains_gen |>
  unnest_tokens(word, Statement) |>
 # anti_join(stop_words, by = "word") |> # get rid of "stop words", we do not need it for dictionary analysis
  mutate(stem = wordStem(word)) # stemming

# DICTIONARY ANALYSIS:
# Calculate the frequency for each step, for each combination, of the words present in the dictionary file.
# It produces one file for each combination mutation/selection.
#
# example with "I-pronouns". 
#
# Any one-column file with the header "word" will work. 
# If the data are stemmed (see line 12 above) also the words in the dictionary need to be stemmed. 

dictionary <- read_csv("dictionaries/I-pronouns.csv")
for (m in unique(chains_gen$Mutation)){
  for(s in unique(chains_gen$Selection)){
    combination <- chains_gen |>
      filter(Mutation == m & Selection == s)
    totals <- combination |>
      group_by(Step) |>
      summarise(total = n())
    match_words <- combination |>
      inner_join(dictionary) |>
      count(Step) |>
      full_join(totals) |>
      replace_na(list(n = 0)) |>
      mutate(frequency = n/total) |>
      arrange(Step)
    write_csv(match_words, file = paste0("I-pronouns_",m, "_", s, ".csv"))
  }
}




# OUTPUT:
# A panel plot of frequencies in each combination.  
#
# example with "I-pronouns". 

# put together all the data:
full_freq<- c()
for (m in unique(chains_gen$Mutation)){
  for(s in unique(chains_gen$Selection)){
    data <- read_csv(file = paste0("output/I-pronouns_",m, "_", s, ".csv"))
    full_freq <- c(full_freq, data$frequency)
  }
}
full_data <- tibble(Step = rep(0:100, 12), 
                    Mutation = rep(unique(chains_gen$Mutation), each = 303),
                    Selection = rep(rep(unique(chains_gen$Selection), each = 101), 4),
                    Frequency = full_freq)

# plot:
ggplot(data = full_data, aes(x = Step, y = Frequency)) +
  geom_line(color = "blue") +
  facet_grid(vars(Mutation), vars(Selection)) +
  theme_bw() +
  labs(title = "output/LIWC I-pronouns")
ggsave("I-pronouns.pdf", width = 6, height = 6)



# EXTRA:

# frequency of all words through the combinations:
for (m in unique(chains_gen$Mutation)){
  for(s in unique(chains_gen$Selection)){
    combination <- chains_gen |>
      filter(Mutation == m & Selection == s) |>
      count(stem, sort = TRUE)
    write_csv(combination, file = paste0("freqWords_",m, "_", s, ".csv"))
  }
}






