# Loading required libraries
# For raster data manipulation
library(raster)
# For handling spatial data
library(sf)

# Setting the file path to your GeoTIFF
#file_path <- "./data/WorldEcosystem.tif"

# Reading the raster GeoTIFF
Switzerland <- ne_countries(scale = "medium", returnclass = "sf", country = "Switzerland")

# Crop and mask
#r3 <- crop(ecosystem_raster, extent(Switzerland))
#ecosystem_switzerland <- mask(r3, Switzerland)

# Save the raster to a file
# output_filepath <- "./data/ecosystem_switzerland.tif"
# writeRaster(ecosystem_switzerland, filename = output_filepath, format = "GTiff", overwrite = TRUE)

# Path to the file saved the crop of switzerland in .tif format in order to fit in GitHub.
file_path <- "./data/ecosystem_switzerland.tif"
ecosystem_switzerland <- raster(file_path)
#plot(ecosystem_switzerland)

# Assuming matrix_full_elev is your data frame with latitude and longitude columns
spatial_points <- SpatialPoints(coords = matrix_full_elev[, c("longitude","latitude")], proj4string = CRS("+proj=longlat +datum=WGS84"))

#plot(spatial_points, add = TRUE, pch = 16, cex = 2)

# Extracting values
eco_values <- raster::extract(ecosystem_switzerland, spatial_points)

# Combining extracted values with existing data frame
matrix_full_elev_ec <- data.frame(matrix_full_elev, eco_values)
# fix(matrix_full_elev_eco)

# Printing the extracted values
# print(eco_values)

# Loading metadata for ecosystem data
metadat_eco <- read.delim("./data/WorldEcosystem.metadata.tsv")

# Merging ecosystem data with metadata
matrix_full_elev_eco <- merge(matrix_full_elev_ec, metadat_eco, by.x = "eco_values", by.y = "Value")

# Printing the first few rows of the metadata
#head(metadat_eco)

# Displaying the new matrix
#fix(matrix_full_elev_eco)

# Creating a ggplot for spatial distribution of ecosystems in Switzerland
p3 <- ggplot() +
  geom_sf(data = Switzerland) +
  geom_point(data = matrix_full_elev_eco, aes(x = longitude, y = latitude, color = Landcover, shape = species), size = 2) +
  labs(title = "Spatial Distribution of Species per Ecosystems in Switzerland", x = "Longitude", y = "Latitude") +
  theme_minimal()

#print(p3)
