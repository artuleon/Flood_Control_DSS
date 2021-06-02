# ---------------------------------------------------------------------------
# UTMToASCII.py
# ---------------------------------------------------------------------------
# Import arcpy module
import arcpy, os
from shutil import copyfile

# Local variables:
#Name = "cdr_19930930z"
#cdr_19930601z = "C:\\temp\\Gridded_Workshop_FINAL_MATLAB\\After_MATLAB\\Persiann\\UTM\\cdr_19930930z"
#v_name__ASC = "C:\\temp\\Gridded_Workshop_FINAL_MATLAB\\After_MATLAB\\Persiann\\UTMASCII\\%name%.ASC"

# Paths
my_path = os.path.abspath(os.path.dirname(__file__))
InputFile  = os.path.join(my_path, "..\RainAcquire\Persiann\UTM")
OutputFile  = os.path.join(my_path, "..\RainAcquire\Persiann\UTMASCII")
path_BAT_file = my_path
path_file = os.path.join(my_path, "\hecexe")
# path_BAT_file = "C:\\temp\\Gridded_Workshop_FINAL_MATLAB\\utilitaries"
# path_file = "C:\\temp\\Gridded_Workshop_FINAL_MATLAB\\utilitaries\\hecexe"


namefiles = None 
for namefiles in os.listdir(InputFile):
       pathfile = os.path.join(InputFile,namefiles)	     
       if os.path.isdir(pathfile):  
               suffix = '.ASC'
               File2 = os.path.join(OutputFile, namefiles + suffix)
               # Process: Raster to ASCII
               try: 
                     arcpy.RasterToASCII_conversion(pathfile, File2)  
               except Exception:
                     continue
       else:
               continue


# This is to copy the Batch_ASCIIToDSS.BAT file from the utilitaries folder to the UTMASCII folder
source = os.path.join(path_BAT_file,"Batch_ASCIIToDSS.BAT")
destinat = os.path.join(OutputFile,"Batch_ASCIIToDSS.BAT")                     
copyfile(source, destinat)



# This is to copy the asc2dssGrid.exe file from the \hecexe folder to the UTMASCII folder
source = os.path.join(my_path,"asc2dssGrid.exe")
destinat = os.path.join(OutputFile,"asc2dssGrid.exe")                     
copyfile(source, destinat)
