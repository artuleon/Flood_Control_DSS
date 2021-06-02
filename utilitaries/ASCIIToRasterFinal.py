# Name: ASCIIToRasterFinal.py 
# Description: Converts an ASCII file representing raster data to a raster dataset
# Written by Arturo Leon 
  
# Import system modules  
import arcgisscripting, os, arcpy

# Paths
my_path = os.path.abspath(os.path.dirname(__file__))
# inDir = r"C:\temp\Gridded_Workshop_FINAL_MATLAB\After_MATLAB\Persiann\ASCII"  
# OutRaster = "C:/temp/Gridded_Workshop_FINAL_MATLAB/After_MATLAB/Persiann/Raster"    
inDir = os.path.join(my_path, "..\RainAcquire\Persiann\ASCII")
OutRaster = os.path.join(my_path, "..\RainAcquire\Persiann\Raster")

# Set local variables  
InAsciiFile = None 
for InAsciiFile in os.listdir(inDir):  
    if InAsciiFile.rsplit(".")[-1] == "asc":  
        print InAsciiFile  
        # Process: ASCIIToRaster_conversion  
        arcpy.ASCIIToRaster_conversion(os.path.join(inDir,InAsciiFile), os.path.join(OutRaster,InAsciiFile.rsplit(".")[0]), "FLOAT") 
    else:
        continue   










