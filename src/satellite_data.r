# Installing required package from GitHub
# remotes::install_github("wmgeolab/rgeoboundaries")

# Loading libraries
# For accessing geoboundaries data
library(rgeoboundaries)
# For handling spatial data
library(sf)
# For raster data manipulation
library(terra)
# For file paths
library(here)
# For creating plots
library(ggplot2)
# For color scales
library(viridis)

# Reading in the downloaded NDVI raster data
NDVI_raster <- rast("./data/modis/MYD13Q1_NDVI_2020_153.tif")

# Transforming the data
NDVI_raster <- project(NDVI_raster, "+proj=longlat +datum=WGS84")

# Cropping the data to the boundary of Switzerland
map_boundary_sf <- st_read("./data/modis/switzerland.shp")
NDVI_raster <- mask(NDVI_raster, map_boundary_sf)

# Plotting the masked NDVI raster
#plot(NDVI_raster)

# Dividing values by 10000 to have NDVI values between -1 and 1
NDVI_raster <- NDVI_raster * 0.0001

# Converting matrix_full_elev_eco_clim to an sf object
spatial_points <- st_as_sf(matrix_full_elev_eco_clim, coords = c("longitude", "latitude"), crs = 4326)
#plot(st_geometry(spatial_points), add = TRUE)

# Extracting values
NDVI <- raster::extract(NDVI_raster, spatial_points)

# Combining NDVI values with existing data frame
matrix_full_final <- data.frame(matrix_full_elev_eco_clim, NDVI)

# Fixing the FINAL MATRIX
#fix(matrix_full_final)