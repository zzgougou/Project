# Loading required libraries
# For handling spatial data
library(sf)
# For retrieving elevation data
library(elevatr)     
# For raster data manipulation
library(raster)      
# For creating ridge plots
library(ggridges)    
# For data visualization
library(ggplot2)     

# Disabling the use of s2 geometry in sf
sf_use_s2(FALSE)

# Retrieving the country boundary for Switzerland using naturalearth
Switzerland <- ne_countries(scale = "medium", returnclass = "sf", country = "Switzerland")

# Getting elevation raster data for Switzerland at zoom level 8
elevation_switzerland <- get_elev_raster(Switzerland, z = 8)

# Cropping the elevation data to the extent of Switzerland
r2 <- crop(elevation_switzerland, extent(Switzerland))
elevation_switzerland <- mask(r2, Switzerland)

# (Optional) Plotting the elevation raster
# plot(elevation_switzerland)

# Extracting latitude and longitude from matrix_full
latitude <- matrix_full$latitude
longitude <- matrix_full$longitude

# Creating a data frame for GBIF coordinates
gbif_coord <- data.frame(longitude, latitude)

# Defining the coordinate reference system (CRS) for the points
ll_prj <- "EPSG:4326"

# Creating spatial points from the GBIF coordinates
points <- sp::SpatialPoints(gbif_coord, proj4string = sp::CRS(SRS_string = ll_prj))

# Extracting elevation values for the species occurrences using bilinear interpolation
elevation_points <- extract(elevation_switzerland, points, method = 'bilinear')

# Combining the elevation data with the original matrix_full data frame
matrix_full_elev <- data.frame(matrix_full, elevation_points)

# Fixing the new matrix
# fix(matrix_full_elev)

# Creating a ridge plot for elevation distribution across species
p2 <- ggplot(matrix_full_elev, aes(x = elevation_points, y = species, fill = species)) +
  geom_density_ridges() +
  theme_ridges() + 
  theme(legend.position = "none")

# Printing the plot
#print(p2)
