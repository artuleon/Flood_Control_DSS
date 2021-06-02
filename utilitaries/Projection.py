# Load required toolboxes
import arcgisscripting, os, arcpy
from shutil import copyfile

# Local variables:
# Paths
my_path = os.path.abspath(os.path.dirname(__file__))

# inDir = "C:\\temp\\Gridded_Workshop_FINAL_MATLAB\\After_MATLAB\\Persiann\\Raster"
# inDir = r"C:\temp\Gridded_Workshop_FINAL_MATLAB\After_MATLAB\Persiann\Raster"  
inDir = os.path.join(my_path, "..\RainAcquire\Persiann\Raster")

namefiles = None 
for namefiles in os.listdir(inDir):
       try:
             pathfile = os.path.join(inDir,namefiles)	     
             if os.path.isdir(pathfile):  
                  print("\nIt is a directory")  
                  first_file = namefiles
		  break  
             else:  
                  continue                                            
       except Exception:
             continue

# The First following line is WGS84 
arcpy.DefineProjection_management(os.path.join(inDir,first_file), "GEOGCS['GCS_WGS_1984',DATUM['D_WGS_1984',SPHEROID['WGS_1984',6378137.0,298.257223563]],PRIMEM['Greenwich',0.0],UNIT['Degree',0.0174532925199433]]")
source = os.path.join(inDir,first_file,"prj.ADF")
	
namefiles = None 
for namefiles in os.listdir(inDir): 
     try:  
          pathfile = os.path.join(inDir,namefiles)	     
          if os.path.isdir(pathfile):  
                  # This is a directory
                  if namefiles == first_file:
                      continue 
                  else:
                     destinat = os.path.join(inDir,namefiles,"prj.ADF")
                     copyfile(source, destinat)

          else:  
                  continue
     except Exception:
           continue
