# please download and decompress the primarycare_codings.zip
# wget  -nd  biobank.ndph.ox.ac.uk/ukb/ukb/auxdata/primarycare_codings.zip
# unzip primarycare_codings.zip
library(readxl)
library(glue)

#Set gp_dir to 'www' by default but set it to any directory you want to use
gp_dir <- "www" 
#Update to version as needed
gp_v <- "2"

all_sheets <- readxl::excel_sheets(file.path(gp_dir, glue("all_lkps_maps_v{gp_v}.xlsx")))
lkps_sheets <- grep("lkp", all_sheets, value = T)
maps_sheets <- setdiff(all_sheets, c(lkps_sheets, "Description", "Contents"))

maps_data <- lapply(maps_sheets, function(x) readxl::read_excel(file.path("www", glue("all_lkps_maps_v{gp_v}.xlsx")), sheet = x))
names(maps_data) <- maps_sheets
lkps_data <- lapply(lkps_sheets, function(x) readxl::read_excel(file.path("www", glue("all_lkps_maps_v{gp_v}.xlsx")), sheet = x))
names(lkps_data) <- lkps_sheets

saveRDS(lkps_data, file=glue("www/all_lkps_v{gp_v}.RDS"))
saveRDS(maps_data, file=glue("www/all_maps_v{gp_v}.RDS"))
