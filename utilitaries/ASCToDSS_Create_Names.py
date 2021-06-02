# ---------------------------------------------------------------------------
# ASCToDSS_Create_Names.py
# Created by Arturo Leon 
# ---------------------------------------------------------------------------
# Import arcpy module
import arcpy, os, re
from datetime import datetime

# Local variables:
my_path = os.path.abspath(os.path.dirname(__file__))
my_path_one_dir_up = os.path.dirname(my_path) #This is to go one directory above



inDir = os.path.join(my_path, "..\RainAcquire\Persiann\ASCII")
openBATfile = my_path  + "\Batch_ASCIIToDSS.bat"

first_line1 = 'set PATH = ' 
#first_line2 = '\hecexe\;%PATH%'
first_line2 = '\RainAcquire\Persiann\UTMASCII\;%PATH%'

text_1 = "asc2DSSGrid INPUT="
text_2 = " DSS=Persiann.dss PATH=/UTM14/Cypress/Precip/"
#text_2 = " DSS=Persiann.dss PATH=/SHG/Cypress/Precip/"
text_3 = "00/"
dots_fill = ":"
text_4 = "00/PROJECTED/ GRIDTYPE=UTM ZONE=14N DUNITS=mm DTYPE=PER-CUM" 



# Open and Write to file1  
file1 = open(openBATfile,"w") 
#first_line = first_line1 + my_path + first_line2
first_line = first_line1 + my_path_one_dir_up + first_line2
file1.write(first_line +  "\r\n")


print "first_line", first_line

#asc2DSSGrid INPUT=CDR_19930601z.asc DSS=Persiann.dss PATH=/UTM48/Cypress/Precip/01JUN1993:0000/01JUN1993:2400/PROJECTED/ GRIDTYPE=UTM ZONE=48N DUNITS=mm DTYPE=PER-CUM
namefiles = None 
for namefiles in os.listdir(inDir):
      if namefiles.lower().endswith(".asc"): 
                  # print namefiles
                  # strDate = "19930601"
                  try:
                         #For day time step
                         #strDate = re.search('1h(.+?)', namefiles).group(1)



                        #The Name of the ascii file can not be longer than 13 characters.
                        #The Name of the ascii file can not be longer than 13 characters.
                        #The Name of the ascii file can not be longer than 13 characters.
                        #The Name of the ascii file can not be longer than 13 characters.
                        #The Name of the ascii file can not be longer than 13 characters. 

                        

                         #For hours
                         strDate = re.search('1h(.+).asc', namefiles).group(1)
                         find_hour = strDate[-2:]
                         find_year_month_day = strDate[0:8]
                         number_hour = int(find_hour)                                                
                         if number_hour > 22:
                            last_hour = 24
                            str_first_hour = str(last_hour -1)
                            str_last_hour = str(last_hour)                              
                         elif number_hour > 8: #this means nine. Last hour will be 10. It is not necessary to add 0                            
                            last_hour = number_hour + 1
                            str_first_hour = str(last_hour -1)
                            str_last_hour = str(last_hour)
                         else:
                            last_hour = number_hour + 1
                            str_first_hour = '0' + str(last_hour -1)
                            str_last_hour = '0' + str(last_hour)
                  except AttributeError:
                         continue 
                  objDate = datetime.strptime(find_year_month_day, '%Y%m%d')
                  converted_date = datetime.strftime(objDate,'%d%b%Y')
                  
                  # full_text = os.path.join(text_1, "string_namefiles", text_2, converted_date, text_3, converted_date, text_4) 
                  full_text = text_1 + namefiles + text_2 + converted_date + dots_fill + str_first_hour + text_3 + converted_date + dots_fill + str_last_hour + text_4
                  print "full_text", full_text
                  # print full_text
                  file1.write(full_text + "\r\n")
      else:
                  continue      
file1.close() #to close file   
