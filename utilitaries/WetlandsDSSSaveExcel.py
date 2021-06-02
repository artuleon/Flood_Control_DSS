from hec.script import *
from hec.heclib.dss import *
from hec.dataTable import *
import java


#  Open the file and get the data
try:  
  dssFile = HecDss.open("C:\DSSTest_Wetland_optimization\HMS_RAS\Wetlands_RAS_Optimization\RAS_HMS_folders\Cypress1\CypressHMS\Run_1.dss")
  elev = dssFile.get("//WL-410/ELEVATION/01JAN2018/1HOUR/RUN:RUN 1/")  
  inflow = dssFile.get("//WL-410/FLOW-COMBINE/01JAN2018/1HOUR/RUN:RUN 1/")  
  stor = dssFile.get("//WL-410/STORAGE/01JAN2018/1HOUR/RUN:RUN 1/")
  totalOutflow = dssFile.get("//WL-410/FLOW/01JAN2018/1HOUR/RUN:RUN 1/")
  releaseMain = dssFile.get("//WL-410-RELEASE/FLOW/01JAN2018/1HOUR/RUN:RUN 1/")
  spillOvertopping = dssFile.get("//WL-410-SPILL-1/FLOW/01JAN2018/1HOUR/RUN:RUN 1/")
except java.lang.Exception, e :
  #  Take care of any missing data or errors
   MessageBox.showError(e.getMessage(), "Error reading data")

#  Add Data
datasets = java.util.Vector()
datasets.add(elev)
datasets.add(inflow)
datasets.add(stor)
datasets.add(totalOutflow)
datasets.add(releaseMain)
datasets.add(spillOvertopping)

#  For this code, jython sees a List before a Vector
#list = java.awt.List()
list = []
list.append(datasets)

table = HecDataTableToExcel.newTable()

#  If you want to run Excel with a specific name and not a temp name:
# table.runExcel(list, "C:\DSSTest_Wetland_optimization\HMS_RAS\Wetlands_RAS_Optimization\RAS_HMS_folders\Cypress1\CypressHMS\wetland_mass_balance.xls")
#  Or, if you would just rather create an Excel file, but not run it:
table.createExcelFile(list, "C:\DSSTest_Wetland_optimization\HMS_RAS\Wetlands_RAS_Optimization\RAS_HMS_folders\Cypress1\CypressHMS\wetland_mass_balance.xls")




