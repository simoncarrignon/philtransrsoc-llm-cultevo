
sel_names <- mut_names <- c("original","efficient","attractive","random")
cols=palette.colors(n=length(mut_names),palette="Set 1")
cols <- scales::hue_pal()(length(mut_names))  
lty_map <- setNames(rep(1:6, length.out = length(sel_names)), sel_names)
names(cols)=sort(mut_names)
pchs=20+1:length(sel_names) 
names(pchs)=sel_names
models<-c("Mistral 7B"= "Mistral-7B-Instruct-v0.3_gennew_concatenated_files_1","Qwen2.5 7B"= "Qwen2.5-7B-Instruct_gennew_concatenated_files_1","Qwen2.5 7B"="qwen2.5-7b-var1_","OpenAI ChatGPT3.5"= "GPT3.5_gennew_concatenated_files","Qwen3 8B"= "qwen3-8b-")
allembeddings <- lapply(models[-c(5,3)][c(1,3,2)],function(m)read.csv(paste0("embeddings/",m,"_statement_embeddings.csv")))
allembeddings <- do.call("rbind",allembeddings)
pcares <- prcomp(allembeddings[,grepl("embeddings*",colnames(allembeddings))])
plot(pcares$x[,1:2],col=adjustcolor(cols[allembeddings$Mutation],.6),pch=20)
legend("topright",pch=20,col=cols[mut_names],legend=mut_names)

gs<-c("Outgroup"="reference_outgroup","Random"="random_facts_outgroup")
og <- lapply(ogs,function(m)read.csv(paste0("embeddings/",m,"_statement_embeddings.csv")))
og <- read.csv("embeddings/length_matched_outgroup_statement_embeddings.csv")
og<-do.call("rbind",og)
allembeddingswo <- rbind(allembeddings[,grepl("embeddings*",colnames(allembeddings))],og[,grepl("embeddings*",colnames(og))])
pcares <- prcomp(allembeddingswo[,grepl("embedding*",colnames(allembeddingswo))])
plot(pcares$x[,1:2],col=c(adjustcolor(cols[allembeddings$Mutation],.6),rep("black",nrow(og))),pch=20)
legend("topright",pch=20,col=cols[mut_names],legend=mut_names)

mat <- as.matrix(allembeddingswo[,grepl("embedding*",colnames(allembeddingswo))])
hc <- hclust(as.dist(mat), method = "average")

heatmap(
  mat,
  Rowv = as.dendrogram(hc),
  Colv = as.dendrogram(hc),
  scale = "none",
  symm = TRUE,
  revC = TRUE,
  margins = c(12, 12),
  RowSideColors = side_cols,
  ColSideColors = side_cols,
  col = colorRampPalette(c("#f7fbff", "#9ecae1", "#3182bd", "#08306b"))(80),
  main = "Embedding Distance Matrix With Hierarchical Tree",
  xlab = "",
  ylab = ""
)
