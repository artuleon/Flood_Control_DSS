from hec.script import *
from hec.heclib.dss import *
from hec.dataTable import *
import java


#  Open the file and get the data
try:  
  dssFile = HecDss.open("C:\Arturo_final\SOFTWARE_FINAL\DSS_Flood_2022\DSSWetland_Metric\RAS_HMS_Original_project\CypressHMS\CypressHMS.dss")
  elev = dssFile.get("//Table 420/ELEVATION-STORAGE///TABLE/")
except java.lang.Exception, e :
  #  Take care of any missing data or errors
   MessageBox.showError(e.getMessage(), "Error reading data")

#  Add Data
datasets = java.util.Vector()
datasets.add(elev)

#  For this code, jython sees a List before a Vector
#list = java.awt.List()
list = []
list.append(datasets)

table = HecDataTableToExcel.newTable()

#  If you want to run Excel with a specific name and not a temp name:
# table.runExcel(list, "C:\DSSTest_Wetland_optimization\HMS_RAS\Wetlands_RAS_Optimization\RAS_HMS_folders\Cypress1\CypressHMS\wetland_mass_balance.xls")
#  Or, if you would just rather create an Excel file, but not run it:
table.createExcelFile(list, "C:\Arturo_final\SOFTWARE_FINAL\DSS_Flood_2022\DSSWetland_Metric\RAS_HMS_Original_project\CypressHMS\Table 420.xls")
