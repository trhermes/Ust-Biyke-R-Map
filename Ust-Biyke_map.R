# Taylor Hermes 
# 22 April 2021

# Install the following libraries with install.packages(), functions used are indicated to the right
library(ggmap)          # ggmap() get_stamenmap()
library(ggrepel)        # geom_label_repel()
library(rgdal)          # readOGR()
library(broom)          # tidy()
library(ggsn)           # scalebar() north2()
library(grDevices)      # cairo_pdf()

# Read in site location data in tab-separated format: site name, latitude, longitude (decimal degrees)
sites <- read.csv("Ust-Biyke_sites.csv", sep=",")

# NOTE: Check the working directory!

# Download shapefile of Natural Earth Data admin0 borders
download.file(
  "https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/cultural/ne_10m_admin_0_countries.zip", 
  "ne_10m_admin_0_countries.zip", "auto")

# Unzip file
unzip("ne_10m_admin_0_countries.zip")

# Read in shapefile
borders <- readOGR(dsn="ne_10m_admin_0_countries.shp", stringsAsFactors = FALSE)

# Convert into tabular format and group features for mapping
borders2 <- tidy(borders, group=group) 

# Manually specify bounding box for map
# One could also generate the bounds based on min and max lat/long in sites
map_borders <- c(bottom  = 47.5, 
                 top     = 53,
                 left    = 81.4,
                 right   = 90.5)

# Download map tiles
map <- get_stamenmap(map_borders, zoom = 9, maptype = "terrain-background", force=T)

# Map it
figure1 <- ggmap(map) +
  geom_path(data=borders2, aes(x=long, y=lat, group = group), size=1) +
  geom_point(data=sites, stroke=1, size = 5, aes(x=Longitude, y=Latitude), shape=21) + 
  xlab(expression(paste("Longitude (", degree,"E)"))) + 
  ylab(expression(paste("Latitude (", degree,"N)"))) +
  geom_label_repel(data=sites, aes(x=Longitude, y=Latitude, label=Site), size=8, 
                   min.segment.length = 0.1, box.padding = 1, label.padding = 0.4) +
  scalebar(x.min=81.7, x.max=90, y.min=47.8, y.max=81.5, dist = 100, height = 0.003, 
           st.dist = 0.003, st.size=6, dist_unit = "km",
           transform = TRUE, model = "WGS84", location = "bottomleft") +
  annotate("text", label= "Kazakhstan", x=83, y=49, size=6, color="black", fontface="italic") +
  annotate("text", label= "China", x=87.4, y=48, size=6, color="black", fontface="italic") +
  annotate("text", label= "Mongolia", x=89.5, y=49, size=6, color="black", fontface="italic") +
  annotate("text", label= "Russia", x=83, y=52, size=6, color="black", fontface="italic") +
  theme(axis.text = element_text(size = 15), axis.title = element_text(size = 15))  

# north2() insets a north arrow onto the ggplot while also printing the plot, thus it cannot be used with ggsave()
# One must use base R graphics technique to save output: open device, print, close/save device
# grDevices::cairo_pdf() is preferred to avoid issues with dingbats
grDevices::cairo_pdf(file="Figure 1_updated.pdf",
    width=11.5,height=11.5)
north2(figure1, symbol=12, 0.92, 0.92, scale = 0.07)
dev.off()
