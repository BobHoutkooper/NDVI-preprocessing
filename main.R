# Loner
# Bob Houtkooper
# 08-01-2016

#Import packages
library(raster)

#Source functions
source("R/ExtractCloudMask.R")
source("R/NDVI.R")

#Load Datasets
load('data/LC81970242014109-SC20141230042441.tar.gz') 
load('data/LT51980241990098-SC20150107121947.tar.gz')

#The workflow to preprocess the data
untar('data/LC81970242014109-SC20141230042441.tar.gz')
untar('data/LT51980241990098-SC20150107121947.tar.gz')

all.data <- list.files('data/', pattern = glob2rx('*.tif'), full.names = TRUE)

#preprocess clouds
landsat8cfmas <- raster('data/LC81970242014109LGN00_cfmask.tif')
landsat5cfmas <- raster('data/LT51980241990098KIS00_cfmask.tif')
cfmas_extent <- intersect(landsat5cfmas, landsat8cfmas)

#preprocess landsat 5
landsat5red <- raster('data/LT51980241990098KIS00_sr_band3.tif')
landsat5ni <- raster('data/LT51980241990098KIS00_sr_band4.tif')
landsat5_red_crop <- crop(landsat5red, cfmas_extent)
landsat5_ni_crop <- crop(landsat5ni, cfmas_extent)

#preprocess landsat 8
landsat8red <- raster('data/LC81970242014109LGN00_sr_band4.tif')
landsat8ni <- raster('data/LC81970242014109LGN00_sr_band5.tif')
landsat8_red_crop <- crop(landsat8red, cfmas_extent)
landsat8_ni_crop <- crop(landsat8ni, cfmas_extent)

#Calculate NDVI
ndvilandsat5 <- overlay(x=landsat5_red_crop, y=landsat5_ni_crop, fun=ndvOver)
ndvilandsat8 <- overlay(x=landsat8_red_crop, y=landsat8_ni_crop, fun=ndvOver)

#erase clouds
ndvilandsat5_cloudfree<- overlay(x = ndvilandsat5, y = cfmas_extent, fun = cloud2NA)
ndvilandsat8_cloudfree<- overlay(x = ndvilandsat8, y = cfmas_extent, fun = cloud2NA)

#Some visualization of the intermediary outputs (just picked some randomly)
plot(landsat8cfmas)
plot(cfmas_extent)
plot(landsat5_ni_crop)
plot(ndivlandsat8_cloudfree)

#How to produce and visualize the final output
final_output <- ndvilandsat8_cloudfree-ndvilandsat5_cloudfree
breakpoints <- c(-1, -0.5, 0, 0.5, 1)
colours <- c("yellow", "red", "green", "brown", "black")
plot(final_output, breaks=breakpoints, col=colours, zlim=c(-1,1))



