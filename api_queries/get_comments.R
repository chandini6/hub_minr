# 0. Set up the query 
ctx = interactive.login("usr", "pass")

# This function makes sure I get the pagination right
digest_header_links <- function(x) {
  y <- x$headers$link
  if(is.null(y)) {
    # message("No links found in header.")
    m <- matrix(0, ncol = 3, nrow = 4)
    links <- as.data.frame(m)
    names(links) <- c("rel", "per_page", "page")
    return(links)
  }
  y %>%
    str_split(", ") %>% unlist %>%  # split into e.g. next, last, first, prev
    str_split_fixed("; ", 2) %>%    # separate URL from the relation
    plyr::alply(2) %>%              # workaround: make into a list
    as.data.frame() %>%        # convert to data.frame, no factors!
    setNames(c("URL", "rel")) %>%   # sane names
    dplyr::mutate_(rel = ~ str_match(rel, "next|last|first|prev"),
                   per_page = ~ str_match(URL, "per_page=([0-9]+)") %>%
                     `[`( , 2) %>% as.integer,
                   page = ~ str_match(URL, "&page=([0-9]+)") %>%
                     `[`( , 2) %>% as.integer,
                   URL = ~ str_replace_all(URL, "<|>", ""))
}

owner = "rubinius"
repo = "rubinius"

comments <- function(i){
  commits <- get.issue.comments(owner = owner, repo = repo, number = i, ctx = get.github.context(), per_page=100)
  links <- digest_header_links(commits)
  number_of_pages <- links[2,]$page
  if (number_of_pages != 0)
    try_default(for (n in 1:number_of_pages){
      if (as.integer(commits$headers$`x-ratelimit-remaining`) < 5)
        Sys.sleep(as.integer(commits$headers$`x-ratelimit-reset`)-as.POSIXct(Sys.time()) %>% as.integer())
      else
        get.issue.comments(owner = owner, repo = repo, number = i, ctx = get.github.context(), per_page=100, page = n)
    }, default = NULL)
  else 
    return(commits)
}

first_comments <- function(i){
  first_comment <- get.pull.request(owner = owner, repo = repo, i, ctx = get.github.context())
  first_comment_body <- first_comment$content$body
  return(first_comment_body)
}

list <- read.csv(paste0("/Users/Aron/dropbox/Thesis/3-Variance/Journal/Computational Analysis/compute/", repo, "_include.csv"), header = FALSE)

comments_lists <- lapply(list$V1, comments)
first_comment_lists <- lapply(list$V1, first_comments)

grep_comments <- function(input){
  unlist(input, use.names=FALSE )[ grepl( "body", names(unlist(input)))]
}

body_lists <- lapply(comments_lists, grep_comments)

unlisted_comments <- unlist(body_lists)
all_comments_list <- list(first_comment_lists, unlisted_comments)

saveRDS(all_comments_list, file = "all_comments_list.rds")

comments_df <- as.data.frame(all_comments_list, stringsAsFactors = FALSE)

ids_comments <- cbind(as.character(seq(1, nrow(comments_df), by = 1)), comments_df, stringsAsFactors = FALSE)

colnames(ids_comments) <- c("id", "text")

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
topic.top.words <- mallet.top.words(topic.model,
                                    topic.words.m[2,], 100)

wordcloud(topic.top.words$words,
          topic.top.words$weights,
          c(4, .8), rot.per=0, random.order=F)