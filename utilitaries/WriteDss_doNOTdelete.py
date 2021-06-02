# name=WriteDss
# displayinmenu=true
# displaytouser=true
# displayinselector=true
from hec.script import *
from hec.heclib.dss import *
from hec.heclib.util import *
from hec.io import *
import java

try : 
  try :
    myDss = HecDss.open("C:\DSSTest\HMS_RAS\Wetlands_RAS_Optimization\RAS_HMS_Original_project\CypressHMS\WetlandOutflow9.dss")
    tsc = TimeSeriesContainer()
    tsc.fullName = "/BASIN/LOC/FLOW//1HOUR/OBS/"
    start = HecTime("01Jan2018", "0000")
    tsc.interval = 60
    flows = [0.0,29.3,1523.0,1826.6,717.4,229.6,231.4,1070.4,2487.3,48.4,350.8,7.0,535.4,2151.6,715.6,1444.9,395.3,212.0,1091.8,463.6,73.4,733.8,959.8,299.1,804.9,149.6,176.5,2221.2,336.6,1441.4,257.4,263.0,868.2,1985.1,1754.5,263.2,1561.2,2499.7,75.7,388.1,8.0,861.6,389.3,291.7,2143.0,871.1,1342.4,221.3,1458.2,1012.5,283.5,1425.6,869.5,359.4,918.9,2285.0,1582.1,948.1,882.9,1742.0,279.1,493.0,597.8,1112.2,27.0,926.1,453.5,495.5,492.7]
    times = []
    for value in flows :
      times.append(start.value())
      start.add(tsc.interval)
    tsc.times = times
    tsc.values = flows
    tsc.numberValues = len(flows)
    tsc.units = "CMS"
    tsc.type = "PER-AVER"
    myDss.put(tsc)
    
  except Exception, e :
    MessageBox.showError(' '.join(e.args), "Python Error")
  except java.lang.Exception, e :
    MessageBox.showError(e.getMessage(), "Error")
finally :
  myDss.close()
