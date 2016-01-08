#y = near-infrared
#x= red

ndvOver <- function(x, y) {
  ndvi <- (y - x) / (y + x)
  return(ndvi)
}