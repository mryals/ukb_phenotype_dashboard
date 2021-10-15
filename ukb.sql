# make sure you have sqlite3 installed
# then run the following line within your terminal
# sqlite3 ukb.db <ukb.sql
.mode csv
.import ukb_long.csv pheno
.schema
CREATE INDEX idx_pheno_field ON pheno (field);
