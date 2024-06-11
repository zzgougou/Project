# How are these different migratory birds interacting with eachother?
# Are they settling in completely different places? Different ecosystems?

##### 1 importdata
#Species repartition
print(p1)
# Here we have the repartition of my 3 species of migratory birds, we can spot the dominance of merops apiaster over the others, their repartition seem to be within the same regions.

##### 2 elevation
#Species occurence by elevation
print(p2)
# When it comes to elevation, they are spread differently, with once again merops apiaster having the wider range of altitude.

##### 3 3Dmapping
#3D - Interactive map:
elmat %>% 
  sphere_shade(texture = "bw") %>%
  add_overlay(elevation_texture_map, alphacolor = NULL, alphalayer = 0.7) %>%
  add_shadow(cloud_shade(elmat, zscale = 100, start_altitude = 500, end_altitude = 2000), 0) %>%
  add_water(detect_water(elmat), color = "lightblue") %>%
  plot_3d(elmat, zscale = 100, fov = 0, theta = 135, zoom = 0.75, 
          phi = 45, windowsize = c(1500, 800))

# Rendering points on the 3D elevation map with different colors for each species
render_points(
  extent = extent(Switzerland), size = 10,
  lat = gbif_coord$latitude, long = gbif_coord$longitude,
  altitude = elevation_points + 100, zscale = 150, color = point_colors
)
# Interactive 3D map with Swiss elevation, each color represents a specific species as per earlier.

##### 4 ecosystems
# Distribution of species per ecosystem in Switzerland
print(p3)
# Some details about the ecosystem of habitat, per species and per "Landcover".

##### 5 climatic_data
# Grid of temperature per month, categorized by species
print(p4)
# Monthly temperature per species per month, over the whole year. Gives an input on the range of temperature they live in. We have to keep in mind that these birds are migratory, therefore we can determine a threshold of temperature when they leave, as well as when they settle.

##### 6 satellite_data
plot(NDVI_raster)
plot(st_geometry(spatial_points), add = TRUE)
# More precise view of the repartition with NDVI as background

# exporting our final matrix :):):)
write.csv(matrix_full_final, "./output/matrix_full.csv", row.names = FALSE)
# Dataset available for further calculation