#####################################################################################
#####################################################################################
############# Introduction to Classification and Machine Learning

# Load necessary libraries
library(caret)
library(randomForest)
library(ggplot2)
library(sf)
library(rnaturalearth)

# Load the dataset
data_stat <- matrix_full_final

# Split data into training and testing sets
a <- createDataPartition(data_stat$Landcover, list=FALSE, p = 0.7)
matrix_full_train <- data_stat[a, ]
matrix_full_test <- data_stat[-a, ]

#### With continuous data 
# Create the random forest model using continuous data
output.forest <- randomForest(NDVI ~ temp + precip + Green, 
                              data = matrix_full_train, ntree=100)

# Display the importance of each variable in the model
importance(output.forest)  
windows()  # Open a new window for plotting
varImpPlot(output.forest)  # Plot variable importance

# Predict on the test data
pred_test <- predict(output.forest, newdata = matrix_full_test, type = "class")
pred_test

# Actual values for comparison
valid_test <- matrix_full_test$NDVI

# Create a data frame to compare predictions and actual values
matt_pred <- data.frame(valid_test, pred_test)

# Plot predictions vs actual values
P <- ggplot(data = matt_pred, mapping = aes(x = valid_test, y = pred_test)) 
P + geom_point(shape = 18) + 
  geom_smooth(method = "lm", se = FALSE) + 
  theme_classic()

# Calculate correlation between predictions and actual values
cor.test(valid_test, pred_test)

###### Map the prediction vs real data
matt_pred$latitude <- matrix_full_test$latitude
matt_pred$longitude <- matrix_full_test$longitude

# Retrieve spatial data for Switzerland
Switzerland <- ne_countries(scale = "medium", returnclass = "sf", country = "Switzerland")

# Plot actual NDVI values on a map of Switzerland
ggplot(data = Switzerland) +
  geom_sf() +
  geom_point(data = matrix_full_test, aes(x = longitude, y = latitude, alpha = NDVI), 
             size = 4, shape = 16, color = "darkgreen") + 
  theme_classic()

# Plot predicted NDVI values on a map of Switzerland
ggplot(data = Switzerland) +
  geom_sf() +
  geom_point(data = matt_pred, aes(x = longitude, y = latitude, alpha = pred_test), 
             size = 4, shape = 16, color = "darkgreen") + 
  theme_classic()

######################################################################
######################################################################

# Calculate prediction accuracy
matt_pred$accuracy <- abs(matt_pred$valid_test - matt_pred$pred_test)

# Plot accuracy on a map of Switzerland
ggplot(data = Switzerland) +
  geom_sf() +
  geom_point(data = matt_pred, aes(x = longitude, y = latitude, alpha = accuracy), 
             size = 2, shape = 16, color = "darkred") + 
  theme_classic()

######################################################################
######################################################################
#####################################################################
########## With factor data 

# Reload the dataset
data_stat <- matrix_full_eco_elev_clim_sat

# Split data into training and testing sets
a <- createDataPartition(data_stat$Landcover, list=FALSE, p = 0.7)
matrix_full_train <- data_stat[a, ]
matrix_full_test <- data_stat[-a, ]

# Create the random forest model using factor data
output.forest <- randomForest(as.factor(Landcover) ~ temp + precip + NDVI, 
                              data = matrix_full_train, ntree=100)

# Display the importance of each variable in the model
importance(output.forest)  
varImpPlot(output.forest) 

# Predict on the test data
pred_test <- predict(output.forest, newdata = matrix_full_test, type = "class")
pred_test

# Actual values for comparison
valid_test <- matrix_full_test$Landcover

# Create a data frame to compare predictions and actual values
matt_pred <- data.frame(valid_test, pred_test)

# Compute the confusion matrix and see the accuracy score
conf_mat <- confusionMatrix(table(matt_pred$valid_test, matt_pred$pred_test))
conf_mat 

# Convert confusion matrix to data frame for plotting
conf_mat_data <- as.data.frame(conf_mat$table)

# Plot the confusion matrix
ggplot(data = conf_mat_data, aes(x = Var1, y = Var2, fill = Freq)) +
  geom_tile() +
  geom_text(aes(label = Freq), vjust = 1) +
  scale_fill_gradient(low = "white", high = "blue") +
  labs(title = "Confusion Matrix", x = "Predicted", y = "Actual") +
  theme_minimal()

######################################################################
#####################################################################
########## On the full dataset

# Create the random forest model using all variables
output.forest <- randomForest(as.factor(Landcover) ~ ., 
                              data = matrix_full_train, ntree=100)

# Plot variable importance
varImpPlot(output.forest) 
