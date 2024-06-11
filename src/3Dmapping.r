# Loading required libraries
# For handling spatial data
library(sf)          
# For retrieving elevation data
library(elevatr)     
# For raster data manipulation
library(raster)      
# For creating 3D visualizations
library(rayshader)   
# For reading PNG files
library(png)         

# Disabling the use of s2 geometry in sf
sf_use_s2(FALSE)

# Retrieving the country boundary for Switzerland using naturalearth
Switzerland <- ne_countries(scale = "medium", returnclass = "sf", country = "Switzerland")

# Getting elevation raster data for Switzerland at zoom level 8
elevation_switzerland <- get_elev_raster(Switzerland, z = 8)

# Cropping and masking the elevation data
r2 <- crop(elevation_switzerland, extent(Switzerland))
elevation_switzerland <- mask(r2, Switzerland)

# Converting elevation raster to matrix and setting extent
elmat <- raster_to_matrix(elevation_switzerland)
attr(elmat, "extent") <- extent(elevation_switzerland)

# Downloading and loading the texture map
elevation_texture_map <- readPNG("./data/Switzerland2.png")

# Creating a data frame for GBIF data
latitude <- matrix_full$latitude
longitude <- matrix_full$longitude
gbif_coord <- data.frame(longitude, latitude)

# Extracting elevation values for all species occurrences
ll_prj <- "EPSG:4326"
points <- sp::SpatialPoints(gbif_coord, proj4string = sp::CRS(SRS_string = ll_prj))
elevation_points <- raster::extract(elevation_switzerland, points, method = 'bilinear')

# Creating a data frame with elevation points
matrix_full_elev <- data.frame(matrix_full, elevation_points)

# Defining colors for different species
species_colors <- c("Oriolus oriolus" = "blue", "Merops apiaster" = "green", "Coracias garrulus" = "red")

# Creating a vector of colors for each point based on species
point_colors <- species_colors[matrix_full_elev$species]

# 3D version with colors for different species
# elmat %>% 
#   sphere_shade(texture = "bw") %>%
#   add_overlay(elevation_texture_map, alphacolor = NULL, alphalayer = 0.7) %>%
#   add_shadow(cloud_shade(elmat, zscale = 100, start_altitude = 500, end_altitude = 2000), 0) %>%
#   add_water(detect_water(elmat), color = "lightblue") %>%
#   plot_3d(elmat, zscale = 100, fov = 0, theta = 135, zoom = 0.75, 
#           phi = 45, windowsize = c(1500, 800))

# # Rendering points on the 3D elevation map with different colors for each species
# render_points(
#   extent = extent(Switzerland), size = 10,
#   lat = gbif_coord$latitude, long = gbif_coord$longitude,
#   altitude = elevation_points + 100, zscale = 150, color = point_colors
# )
