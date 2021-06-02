set "PATH=C:\Program Files\HEC\HEC-HMS\4.8\bin\gdal;%PATH%"
set "GDAL_DRIVER_PATH=C:\Program Files\HEC\HEC-HMS\4.8\bin\gdal\gdalplugins"
set "GDAL_DATA=C:\Program Files\HEC\HEC-HMS\4.8\gdal\bin\gdal-data"
set "PROJ_LIB=C:\Program Files\HEC\HEC-HMS\4.8\gdal\bin\projlib"
set "CLASSPATH=C:\Program Files\HEC\HEC-HMS\4.8\hms.jar;C:\Program Files\HEC\HEC-HMS\4.8\lib\*"
C:\jython2.7.1\bin\jython -Djava.library.path="C:\Program Files\HEC\HEC-HMS\4.8\bin;C:\Program Files\HEC\HEC-HMS\4.8\bin\gdal" HMScompute_current.py