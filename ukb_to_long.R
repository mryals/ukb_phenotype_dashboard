library(fst)
library(tidyverse)
library(data.table)
library(glue)

ukb.dir <- "your_ukb_folder"
ukb.data <- "ukbxxxxx.tab" # replace with the file you have

system.time(ukb <- fread(file.path(ukb.dir, ukb.data)))
system.time(write_fst(ukb, file.path(ukb.dir, "ukb.fst")))

ukb <- read_fst(file.path(ukb.dir, "ukb.fst"))


for (i in 2:ncol(ukb)) {
  dat <- ukb[, c(1, i)]
  col_names <- unlist(strsplit(names(dat)[2], split = ".", fixed = T))
  names(dat) <- c('eid', 'value')
  
  dat <- dat %>%
    filter(!is.na(value)) %>%
    mutate(field = col_names[2],
           instance = col_names[3],
           array = col_names[4])
  
  if(i == 2) {
    fwrite(dat, file.path(ukb.dir, "ukb_long.csv"), row.names = FALSE, append = FALSE, col.names = TRUE)
  } else {
    fwrite(dat, file.path(ukb.dir, "ukb_long.csv"), row.names = FALSE, append = TRUE, col.names = FALSE)
  }
}

