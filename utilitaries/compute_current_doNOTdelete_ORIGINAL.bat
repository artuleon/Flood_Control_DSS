set "PATH=C:\Program Files\HEC\HEC-HMS\4.7.1\bin\gdal;%PATH%"
set "GDAL_DRIVER_PATH=C:\Program Files\HEC\HEC-HMS\4.7.1\bin\gdal\gdalplugins"
set "GDAL_DATA=C:\Program Files\HEC\HEC-HMS\4.7.1\gdal\bin\gdal-data"
set "PROJ_LIB=C:\Program Files\HEC\HEC-HMS\4.7.1\gdal\bin\projlib"
set "CLASSPATH=C:\Program Files\HEC\HEC-HMS\4.7.1\hms.jar;C:\Program Files\HEC\HEC-HMS\4.7.1\lib\*"
C:\jython2.7.1\bin\jython -Djava.library.path="C:\Program Files\HEC\HEC-HMS\4.7.1\bin;C:\Program Files\HEC\HEC-HMS\4.7.1\bin\gdal" HMScompute_current.py