from hms.model import Project
from hms import Hms

myProject = Project.open("C:\Arturo_final\SOFTWARE_FINAL\DSS_Flood_2022\DSSWetland_Metric\RAS_HMS_folders\Cypress1\CypressHMS\CypressHMS.hms")
myProject.computeRun("Run 1")
myProject.close() #Saves all components, then closes project

Hms.shutdownEngine()
