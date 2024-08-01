library(eurostat)
library(dplyr)
library(ggplot2)
library(forcats)
library(tidyr)
library(tmap)
library(sf)

tax0 <- get_eurostat("gov_10a_taxag")

tax <- tax0 |>
  label_eurostat(fix_duplicated = TRUE, code = "geo") |>
  filter(TIME_PERIOD == "2022-01-01", unit == "Million euro",
         na_item == "Taxes on land, buildings and other structures",
         sector == "General government")

pop <- get_eurostat("tps00001") |>
  filter(TIME_PERIOD == "2022-01-01") |>
  select(geo_code = geo, pop = values)

dta <- tax |>
  drop_na(values) |>
  left_join(pop) |>
  mutate(ptax_percap = values/pop * 1e6,
         geo = as.factor(geo) |> fct_reorder(ptax_percap))

ggplot(dta, aes(ptax_percap, geo, fill = geo_code == "CZ")) +
  geom_col() +
  theme(legend.position = "none")

poly <- eurostat::get_eurostat_geospatial(nuts_level = "0")


poly |>
  left_join(dta, by = join_by(geo == geo_code)) |>
  ggplot(aes(fill = ptax_percap)) +
  geom_sf() +
  coord_sf(xlim = c(-25, 40), ylim = c(35, 75)) +
  scale_fill_viridis_b(n.breaks = 6) +
  theme_void()

poly |>
  left_join(dta, by = join_by(geo == geo_code)) |>
  tm_shape(bbox = c(-25, 25, 35, 75)) +
  tm_polygons("ptax_percap", n = 10)
