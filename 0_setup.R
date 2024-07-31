install.packages(c("czso", "statnipokladna", "dplyr", "tidyr", "forcats",
                   "lubridate", "RCzechia", "ggplot2", "readr"))

library(statnipokladna)
library(readr)

orgs <- sp_get_codelist("ucjed")
write_rds(orgs, "data-processed/orgs_raw.rds")

orgs <- read_rds("data-processed/orgs_raw.rds")

orgs_proc <- orgs |> 
  filter(start_date <= "2023-01-01", end_date > "2023-12-31") |> 
  sp_add_codelist("druhuj") |> 
  sp_add_codelist("poddruhuj")

write_rds(orgs_proc, "data-processed/orgs_proc.rds")