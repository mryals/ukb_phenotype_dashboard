library(data.table)
library(tidyverse)
library(ggplot2)
library(readxl)
library(readr)
library(DBI)

#To run the global functions, make sure all of the files are loaded into the www folder within your shiny app
#Enter the name of your database file for the database_file_name before running
database_file_name <- "ukb"
gp_v <- "2"

instances <- c("0", "1", "2", "3")
names(instances) <- c("Initial assessment visit (0)", "First repeat assessment visit (1)", "Imaging visit (2)", "First repeat imaging visit (3)")

dict <- fread(file.path("www", "Data_Dictionary_Showcase.tsv")) %>%
  filter(ItemType %in% "Data") %>%
  mutate(ValueType = as.factor(ValueType),
         Stability = as.factor(Stability),
         Strata = as.factor(Strata),
         Sexed = as.factor(Sexed)
  )

EXPORT_DATA <- list()

all_sheets <- readxl::excel_sheets(file.path("www", glue("all_lkps_maps_v{gp_v}.xlsx")))
lkps_sheets <- grep("lkp", all_sheets, value = T)
maps_sheets <- setdiff(all_sheets, c(lkps_sheets, "Description", "Contents"))


maps_data <- readRDS(file.path("www", glue("all_maps_v{gp_v}.RDS")))
lkps_data <- readRDS(file.path("www", glue("all_lkps_v{gp_v}.RDS")))

get_pheno_data <- function(field_ids, instance = NULL, decode = FALSE) {
  require(DBI)
  require(readr)
  require(data.table)
  require(dplyr)
  stopifnot(is.numeric(field_ids))
  stopifnot(is.null(instance) | is.numeric(instance))
  
  data_dict <- read_tsv(file.path("www","Data_Dictionary_Showcase.tsv"),
                        col_types = cols(), progress = FALSE)
  # data_dict %>% count(ValueType)
  # # A tibble: 8 x 2
  #   ValueType                n
  # * <chr>                <int>
  # 1 Categorical multiple   122
  # 2 Categorical single    2503
  # 3 Compound                11
  # 4 Continuous            2773
  # 5 Date                  1206
  # 6 Integer                567
  # 7 Text                   213
  # 8 Time                    72
  
  codings <- data.table::fread(file.path("www","Codings.tsv"), quote="")
  
  stopifnot(all(field_ids %in% data_dict$FieldID))
  
  mydb <- dbConnect(RSQLite::SQLite(), file.path("www",glue("{database_file_name}.db")))
  
  query_db <- function(field_id) {
    dat <- dbGetQuery(mydb, 'SELECT * FROM pheno WHERE "field" == :x',
                      params = list(x = as.character(field_id)))
  }
  
  dat_list <- lapply(field_ids, function(x) query_db(x))
  dat <- rbindlist(dat_list)
  
  dbDisconnect(mydb)
  
  info <- data_dict %>%
    filter(FieldID %in% field_ids)
  
  name = info %>%
    select(field = FieldID,
           name = Field) %>%
    mutate(field = as.character(field))
  
  if(decode & any(!is.na(info$Coding))) {
    suppressMessages(
      field_coding <- info %>%
        select(field = FieldID,
               Coding) %>%
        mutate(field = as.character(field)) %>%
        left_join(codings) %>%
        dplyr::rename(value = Value,
                      value_decoded = Meaning)
    )
    
    suppressMessages(
      dat <- dat %>% dplyr::left_join(field_coding)
    )
    dat <- dat %>%
      # mutate(value = ifelse(is.na(value_decoded), value, value_decoded)) %>%
      # select(-Coding, -value_decoded)
      select(-Coding)
  }
  
  suppressMessages(
    dat <- dat %>%
      dplyr::left_join(name)
  )
  
  if(is.null(instance)) {
    return(dat)
  } else {
    cond = as.character(instance)
    return(dat %>% filter(instance %in% cond))
  }
}

summary_plot <- function(data, value_type) {
  if(value_type %in% c("Continuous", "Integer")) {
    data$value <- as.numeric(data$value)
    ggplot(data = data) + 
      geom_histogram(aes(value, color = instance)) +
      theme_bw()
  } else if (startsWith(value_type, "Categorical")) {
    if("value_decoded" %in% names(data)) {
      ggplot(data = data) + 
        geom_bar(aes(y = value_decoded)) +
        theme_bw()
    } else {
      ggplot(data = data) + 
        geom_bar(aes(y = value)) +
        theme_bw()
    }
    
  }
}

find_icd10_maps <- function(icd10 = "") {
  icd10_lkps <- lkps_data[["icd10_lkp"]] %>%
    # filter(ALT_CODE %in% icd10) %>%
    filter(grepl(pattern = glue::glue("^{icd10}"), ALT_CODE)) %>%
    select(ICD10_CODE = ALT_CODE, ICD10_DESCRIPTION = DESCRIPTION)
  
  read_v2_lkps <- lkps_data[["read_v2_lkp"]] %>%
    select(CODE = read_code,
           DESCRIPTION = term_description)
  
  read_ctv3_lkps <- lkps_data[["read_ctv3_lkp"]] %>%
    select(CODE = read_code,
           DESCRIPTION = term_description)
  
  icd9_icd10 <- maps_data[["icd9_icd10"]] %>%
    # filter(ICD10 %in% icd10) %>%
    filter(grepl(pattern = glue::glue("^{icd10}"), ICD10)) %>%
    select(ICD10_CODE = ICD10, 
           CODE = ICD9,
           DESCRIPTION = DESCRIPTION_ICD9) %>%
    mutate(MAPPING_TYPE = "ICD9 to ICD10")
  
  read_v2_icd10 <- maps_data[["read_v2_icd10"]] %>%
    # filter(icd10_code %in% icd10) %>%
    filter(grepl(pattern = glue::glue("^{icd10}"), icd10_code)) %>%
    select(ICD10_CODE = icd10_code,
           CODE = read_code) %>%
    left_join(read_v2_lkps) %>%
    mutate(MAPPING_TYPE = "READ V2 to ICD10")
  
  read_ctv3_icd10 <- maps_data[["read_ctv3_icd10"]] %>%
    # filter(icd10_code %in% icd10) %>%
    filter(grepl(pattern = glue::glue("^{icd10}"), icd10_code)) %>%
    select(ICD10_CODE = icd10_code,
           CODE = read_code,
           MAPPING_STATUS = mapping_status) %>%
    left_join(read_ctv3_lkps) %>%
    mutate(MAPPING_TYPE = "READ CTV3 to ICD10")
  
  maps_dat <- rbindlist(list(icd9_icd10, read_v2_icd10, read_ctv3_icd10),
                        fill = TRUE)
  
  dat <- icd10_lkps %>%
    left_join(maps_dat) %>%
    mutate(MAPPING_STATUS = as.factor(MAPPING_STATUS)) %>%
    select(ICD10_CODE, ICD10_DESCRIPTION, MAPPING_TYPE,
           MAPPING_STATUS, CODE, DESCRIPTION)
  
  return(dat)
  
}