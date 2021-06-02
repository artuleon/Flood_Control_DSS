# ---------------------------------------------------------------------------
# WGSToUTM_Resample.py
# Written by Arturo Leon
# Description: 
# ---------------------------------------------------------------------------
# Import arcpy module
import arcpy, os


# Local variables:
my_path = os.path.abspath(os.path.dirname(__file__))
my_path_one_dir_up = os.path.dirname(my_path) #This is to go one directory above


InputFile  = my_path_one_dir_up + "\RainAcquire\Persiann\Raster"
OutputFile = my_path_one_dir_up + "\RainAcquire\Persiann\UTM"


#InputFile  = os.path.join(my_path_one_dir_up, "\RainAcquire\Persiann\Raster")
#OutputFile  = os.path.join(my_path_one_dir_up, "\RainAcquire\Persiann\UTM")


print my_path
print my_path_one_dir_up
print InputFile
print OutputFile
print "XXXXXXXXXXXXXXXXXXXXXXXX"

namefiles = None
info = 'info' 
for namefiles in os.listdir(InputFile):
     print namefiles
     RasterFile = os.path.join(InputFile,namefiles)    
     if os.path.isfile(RasterFile): 
         continue
     elif namefiles == info:
         continue
     elif os.path.isdir(RasterFile):  
         try: 
             UTMFile = os.path.join(OutputFile,namefiles)
             print RasterFile
             print UTMFile             
             #This uses projection WGS_1984 and reprojects to WGS_1984_UTM_Zone_14N
             arcpy.ProjectRaster_management(RasterFile, UTMFile, "PROJCS['WGS_1984_UTM_Zone_14N',GEOGCS['GCS_WGS_1984',DATUM['D_WGS_1984',SPHEROID['WGS_1984',6378137.0,298.257223563]],PRIMEM['Greenwich',0.0],UNIT['Degree',0.0174532925199433]],PROJECTION['Transverse_Mercator'],PARAMETER['False_Easting',500000.0],PARAMETER['False_Northing',0.0],PARAMETER['Central_Meridian',-99.0],PARAMETER['Scale_Factor',0.9996],PARAMETER['Latitude_Of_Origin',0.0],UNIT['Meter',1.0]]", "BILINEAR", "2000 2000", "", "0 0", "GEOGCS['GCS_WGS_1984',DATUM['D_WGS_1984',SPHEROID['WGS_1984',6378137.0,298.257223563]],PRIMEM['Greenwich',0.0],UNIT['Degree',0.0174532925199433]]")

             #This uses projection WGS_1984 and reprojects to NAD_1983_UTM_Zone_14N
             #arcpy.ProjectRaster_management(RasterFile, UTMFile, "PROJCS['NAD_1983_UTM_Zone_14N',GEOGCS['GCS_North_American_1983',DATUM['D_North_American_1983',SPHEROID['GRS_1980',6378137.0,298.257222101]],PRIMEM['Greenwich',0.0],UNIT['Degree',0.0174532925199433]],PROJECTION['Transverse_Mercator'],PARAMETER['False_Easting',500000.0],PARAMETER['False_Northing',0.0],PARAMETER['Central_Meridian',-99.0],PARAMETER['Scale_Factor',0.9996],PARAMETER['Latitude_Of_Origin',0.0],UNIT['Meter',1.0]]", "BILINEAR", "2000 2000", "WGS_1984_(ITRF00)_To_NAD_1983", "0 0", "GEOGCS['GCS_WGS_1984',DATUM['D_WGS_1984',SPHEROID['WGS_1984',6378137.0,298.257223563]],PRIMEM['Greenwich',0.0],UNIT['Degree',0.0174532925199433]]")
         except Exception:
             print("It is producing error even though it is a folder")
             continue
     else:
             continue
