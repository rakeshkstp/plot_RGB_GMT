#!/usr/bin/env Rscript
rm(list=ls(all=TRUE))
library(raster)
library(ncdf4)
library(oceanmap)

# Get NET-CDF file path
#ncfile <- commandArgs(TRUE)[1]
ncfile <- file.choose()

# Get NC file name
fname <- basename(ncfile)

# Get Sensor Name
sensor <- substr(fname,1,3)
rm(fname)

# Define bands
if ( sensor == "MOD") 
  bands <- c("rhos_645", "rhos_555", "rhos_469")

# Define CRS
prj <- "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"

# Open NET-CDF file
ncin <- nc_open(ncfile)

# Get Longitude and Latitude
lon <- ncvar_get(ncin,"lon")
lat <- ncvar_get(ncin,"lat")

# Get RGB index from NC file
dname <- names(ncin$var)
rgbindx <- c(which(grepl(pattern = bands[1], x = dname)), 
             which(grepl(pattern = bands[2], x = dname)), 
             which(grepl(pattern = bands[3], x = dname)))
rm(bands)

if (length(rgbindx) < 3)
  stop(paste0("One of the RGB band not present in ",ncfile,". Exiting ..."))

# Define RGB list
rgb <- list()
rgbnames <- c("red","green","blue")

# Read RGB bands
for (b in 1:length(rgbnames)) 
{   rgb[[rgbnames[b]]] <- ncvar_get(ncin,dname[rgbindx[b]])
    message(paste0("\tConverting matrix to raster ... ",rgbnames[b]))
    capture.output(rgb[[rgbnames[b]]] <- matrix2raster(rgb[[rgbnames[b]]],lon,lat,proj=prj))
}
rm(rgbindx,b,dname,prj,ncfile,rgbnames)

# Read Date  
imgdate <- as.Date(substr(ncatt_get(ncin, 0, "start_date")[[2]],1,11),"%d-%b-%Y")
imgdate <- format(imgdate, format="%Y_%m_%d")

  # if(is.null(raster::intersect(extent(l2prod[[ncfile[[i]]]]), iextent)))
  # { #message(paste0("\t",ncfile[[i]]," is out of bounds therefore, deleting ... "))
  #   file.remove(ncfile[[i]])
  #   l2prod[[ncfile[[i]]]] <- NULL
  #   ncfile[[i]] <- NULL
  # } else
  # { #message(paste0("\tCropping to the desired extent: ",round(iextent,3)))
  #   l2prod[[ncfile[[i]]]] <- raster::crop(l2prod[[ncfile[[i]]]], iextent)
  #   i <- i+1
  # }

# close netCDF file.
nc_close(ncin)
rm(ncin)


#bckup <- rgb

for (b in 1:length(rgb))
{ k <- min(getValues(rgb[[b]]),na.rm = T)
  if (k<0) 
    stop(paste0("Minimum value for ",names(rgb[b]), " band is ",k," which is less than 0. Exiting ..."))  
  rgb[[b]] <- log(rgb[[b]]/0.01)/log(1/0.01)
  message(paste0("Minimum values for ",names(rgb[b])," band is ",k))
  rgb[[b]][which(getValues(rgb[[b]]) < 0)]=0
}
rm(b,k)
rgb <- stack(rgb)

#plotRGB(rgb*255, r=1, g=2, b=3)
#rgb <- bckup

# Writing stuff
fname <- paste0(sensor,"_",imgdate,"_rgb.nc")
message(paste0("Saving rasters to file:",fname))

# Getting lat and long for the rasters
nx <- length(lon)
ny <- length(lat)

# define dimensions
londim <- ncdim_def("Longitude","degrees_east",as.double(lon))
latdim <- ncdim_def("Latitude","degrees_north",as.double(lat))
rm(lat,lon)

# define variables
fillvalue <- -999.0
zname <- as.list(names(rgb))
var_def <- sapply(1:length(zname), FUN = function(x){ncvar_def(name = zname[[x]],
                                                               units = "dimensionless", 
                                                               dim = list(londim,latdim),
                                                               missval = fillvalue,
                                                               longname = paste0(zname[[x]]," band"),
                                                               prec="single")},
                  simplify = FALSE, USE.NAMES = TRUE)
rm(londim, latdim)

# Replacing NAs with fillvalue
message(paste0("Replacing NAs with ", fillvalue))
idx <- sapply(names(rgb), FUN = function(x) {is.na(raster::values(rgb[[x]]))},
              simplify = FALSE, USE.NAMES = TRUE)
for (i in 1:nlayers(rgb))
  raster::values(rgb[[i]])[idx[[i]]] <- fillvalue
rm(idx, i, fillvalue)

# create netCDF file and put arrays
ncout <- nc_create(fname,var_def,force_v4=TRUE)

# put variables
dummy <- sapply(1:length(zname), FUN = function(x){ncvar_put(ncout,var_def[[x]], raster2matrix(rgb[[x]]),
                                                             start=c(1,1), count=c(nx,ny))},
                simplify = FALSE, USE.NAMES = TRUE)
rm(dummy,zname, var_def, rgb, nx, ny)

# put additional attributes into dimension and data variables
ncatt_put(ncout,"Longitude","axis","X") #,verbose=FALSE) #,definemode=FALSE)
ncatt_put(ncout,"Latitude","axis","Y")

# add global attributes
ncatt_put(ncout,0,"Title",paste0("RGB bands for GMT on ",imgdate))
ncatt_put(ncout,0,"Institution","Université du Québec à Rimouski")
ncatt_put(ncout,0,"Image Source","Ocean Biology Processing Group (OBPG), NASA-GSFC")
ncatt_put(ncout,0,"History",paste("Rakesh Kumar Singh", date(), sep=", "))
ncatt_put(ncout,0,"Software","SeaDASv7.5")

# close the file, writing data to disk
nc_close(ncout)
message(paste0("Rasters saved to ",fname," successfully."))
unlink(tempdir(), recursive = T)

