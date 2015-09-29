# For this script to run I have to run my local version of rgithub. Open the rgithub Rstudio project and build and reload the package to use the modified get.commit() function that allows for setting the "git" argument to NULL.

# 0. Set up the query 
ctx = interactive.login("3f2c05f63b3d9cebf87f", "03554cba5aa1d4730737ce85cf8d0ccd599dc661")

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