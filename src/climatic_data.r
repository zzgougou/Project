# Loading required libraries
# For accessing GBIF data
library(rgbif)
# For accessing natural earth data
library(rnaturalearth)
# For creating plots
library(ggplot2)
# For accessing iNaturalist data # For accessing iNaturalist data
library(rinat)
# For raster data manipulation
library(raster)
# For handling spatial data
library(sf)
# For data reshaping
library(tidyr)
# For data manipulation
library(dplyr)
# For geospatial data
library(geodata)

# Assuming matrix_full is your data frame with latitude and longitude columns
# Creating spatial points
spatial_points <- SpatialPoints(coords = matrix_full[, c("longitude", "latitude")], proj4string = CRS("+proj=longlat +datum=WGS84"))

# Retrieving temperature data for Switzerland for all 12 months
sw_clim_tmin <- worldclim_country("switzerland", var = "tmin", path = tempdir())
sw_clim_tmin_br <- brick(sw_clim_tmin)

# Retrieving precipitation data for Switzerland for all 12 months
sw_clim_prec <- worldclim_country("switzerland", var = "prec", path = tempdir())
sw_clim_prec_br <- brick(sw_clim_prec)

# Initializing lists to store monthly data
monthly_temp <- list()
monthly_precip <- list()

# Extracting data for each month (1 to 12 = january to december) using iteration
for (i in 1:12) {
  # Extract temperature for month i
  temp_raster <- sw_clim_tmin_br[[i]]
  temp_values <- raster::extract(temp_raster, spatial_points, method = 'bilinear')
  monthly_temp[[i]] <- data.frame(temp = temp_values, month = i)
  
  # Extracting precipitation for month i
  precip_raster <- sw_clim_prec_br[[i]]
  precip_values <- raster::extract(precip_raster, spatial_points, method = 'bilinear')
  monthly_precip[[i]] <- data.frame(precip = precip_values, month = i)
}

# Combining monthly data into a single data frame
all_temp <- do.call(rbind, monthly_temp)
all_precip <- do.call(rbind, monthly_precip)

# Adding species information to the data
all_temp <- cbind(matrix_full[, c("species", "longitude", "latitude")], all_temp)
all_precip <- cbind(matrix_full[, c("species", "longitude", "latitude")], all_precip)

# Combining temperature and precipitation data
climate_data <- merge(all_temp, all_precip, by = c("species", "longitude", "latitude", "month"))

# Converting month numbers to month names
climate_data$month <- factor(climate_data$month, levels = 1:12, labels = month.name)

# Reshaping the data from long to wide format, otherwise it would multiply my lines by 12
climate_data_wide <- climate_data %>%
  pivot_wider(names_from = month, values_from = c(temp, precip))

# Creating the ggplot for climate data by month
p4 <- ggplot(climate_data, aes(x = precip, y = temp, color = species)) +
  geom_point() +
  facet_wrap(~month, scales = "fixed") +
  theme_minimal() +
  labs(x = "Precipitation", y = "Temperature", title = "Monthly Climate Data for Species Occurrences")
#print(p4)

# Merging the reshaped climate data with your main matrix
matrix_full_elev_eco_clim <- merge(matrix_full_elev_eco, climate_data_wide, by = c("species", "longitude", "latitude"))

# Fixing the merged matrix
#fix(matrix_full_elev_eco_clim)
