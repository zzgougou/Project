# Load required libraries
# For accessing GBIF occurrence data
library(rgbif)
# For obtaining spatial data
library(rnaturalearth)
# For data visualization
library(ggplot2)
# For accessing iNaturalist occurrence data
library(rinat)
# For spatial operations
library(raster)
# For working with spatial data
library(sf)


# The species I'm interested in
species_list <- c("Merops apiaster", "Oriolus oriolus", "Coracias garrulus")

# Retrieve spatial data for Switzerland
Switzerland <- ne_countries(scale = "medium", returnclass = "sf", country = "Switzerland")

# Function to download and extract occurrence data from GBIF
get_gbif_data <- function(species_name) {
  gbif_data <- occ_data(scientificName = species_name, hasCoordinate = TRUE, limit = 5000)
  occur <- gbif_data$data
  gbif_data_switzerland <- occur[occur$country == "Switzerland",]
  return(gbif_data_switzerland)
}

# Function to retrieve and process iNaturalist data
get_inat_data <- function(species_name) {
  inat_data <- get_inat_obs(query = species_name, place_id = "switzerland")
  return(inat_data)
}

# Function to create a combined data frame for GBIF and iNaturalist data
create_combined_data <- function(species_name) {
  gbif_data <- get_gbif_data(species_name)
  inat_data <- get_inat_data(species_name)
  
  # GBIF data frame
  gbif_df <- data.frame(
    species = gbif_data$species,
    latitude = gbif_data$decimalLatitude,
    longitude = gbif_data$decimalLongitude,
    source = rep("gbif", nrow(gbif_data))
  )
  
  # iNaturalist data frame
  inat_df <- data.frame(
    species = inat_data$scientific_name,
    latitude = inat_data$latitude,
    longitude = inat_data$longitude,
    source = rep("inat", nrow(inat_data))
  )
  
  # Combine GBIF and iNaturalist data frames
  combined_df <- rbind(gbif_df, inat_df)
  return(combined_df)
}

# Retrieve data for all species and combine into one data frame
matrix_full <- do.call(rbind, lapply(species_list, create_combined_data))

# Plotting combined data on a map of Switzerland
p1 <- ggplot(data = Switzerland) +
  geom_sf() +
  geom_point(data = matrix_full, aes(x = longitude, y = latitude, fill = species), size = 2, shape = 23) +
  theme_classic()
#print(p1)
