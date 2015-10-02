setwd("/Users/Aron/Dropbox/Thesis/3-Variance/Journal/Computational Analysis/compute/")

required_packages <- c('rgithub','roxygen2', 'plyr')

new_packages <- required_packages[!(required_packages %in% installed.packages()[,'Package'])]
if(length(new_packages)) install.packages(new_packages)
lapply(required_packages, library, character.only = TRUE)

if(required_packages == c('rgithub'))
{
  install.packages("devtools")
  require(devtools)
  install_github("cscheid/rgithub")
}