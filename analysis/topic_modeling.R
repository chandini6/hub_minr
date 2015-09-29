# 1 Implement LDAvis: http://cpsievert.github.io/LDAvis/reviews/reviews.html
# 1 Figure out a) how many topic models to fit, and b) what specialized stop words to use
# 2 Try LSA (grab from rails_mailing_list mining)

data("TwentyNewsgroups", package = "LDAvis")
str(TwentyNewsgroups)

mallet.instances <- mallet.import(ids_comments$id,
                                  ids_comments$text,
                                  "/Users/Aron/Desktop/programming/R/TextAnalysisWithR/data/stoplist.csv",
                                  FALSE,
                                  token.regexp="[\\p{L}']+")

# create a topic trainer object.
topic.model <- MalletLDA(num.topics=43)
topic.model$loadDocuments(mallet.instances)

vocabulary <- topic.model$getVocabulary()

word.freqs <- mallet.word.freqs(topic.model)

topic.model$setAlphaOptimization(40, 80)
topic.model$train(400)

topic.words.m <- mallet.topic.words(topic.model,
                                    smoothed=TRUE,
                                    normalized=TRUE)
dim(topic.words.m)
topic.words.m[1:3, 1:3]

vocabulary <- topic.model$getVocabulary() 
colnames(topic.words.m) <- vocabulary 
topic.words.m[1:3, 1:3]

keywords <- c("california", "ireland")
topic.words.m[, keywords]

imp.row <- which(rowSums(topic.words.m[, keywords]) ==
                   max(rowSums(topic.words.m[, keywords])))

mallet.top.words(topic.model, topic.words.m[imp.row,], 10)

# Wordcloud visualization
library(wordcloud)

topic.top.words <- mallet.top.words(topic.model,
                                    topic.words.m[2,], 100)

wordcloud(topic.top.words$words,
          topic.top.words$weights,
          c(4, .8), rot.per=0, random.order=F)