function BetweenTimes_HMS(filenameinput, RASORHMS)
global Number_hours_simu_HECHMS
global Number_hours_simu_RAS
fid = fopen (filenameinput, 'rt'); %Open file for reading  
if fid == -1
  error('Author:Function:OpenFile', 'Cannot open file: %s', filenameinput);
end

if RASORHMS ==1 
        while ~feof(fid);     
                strTextLine = fgetl(fid); %To read one additional line 
                if strfind(strTextLine,'Start Date') 
                    start_date = strTextLine;
                elseif strfind(strTextLine,'Start Time'); 
                    start_time = strTextLine;
                elseif strfind(strTextLine,'End Date'); 
                    end_date = strTextLine;
                elseif strfind(strTextLine,'End Time'); 
                    end_time = strTextLine;
                end
        end
elseif RASORHMS == 2
        while ~feof(fid);     
                strTextLine = fgetl(fid); %To read one additional line 
                if strfind(strTextLine,'Simulation Date') 
                    DateRAS = strTextLine;
                end
        end
else
    error('BetweenTimes_HMS is not HMS or RAS'); 
end
fclose (fid); %Close the text file

if RASORHMS == 1 
        C1 = strsplit(start_date);
        C2 = strsplit(start_time);
        t1 = [C1{4} '-' C1{5} '-' C1{6} ' ' C2{4}];
        t1 = datestr(t1);
        howmanyelem = strsplit(t1);
        [m,n1] = size(howmanyelem);
        C1 = strsplit(end_date);
        C2 = strsplit(end_time);
        t2 = [C1{4} '-' C1{5} '-' C1{6} ' ' C2{4}];
        t2 = datestr(t2);
        howmanyelem = strsplit(t2);
        [m,n2] = size(howmanyelem);
        if n1 ==1
            t1 = datetime(t1,'InputFormat','dd-MMM-yyyy');
        else
            t1 = datetime(t1,'InputFormat','dd-MMM-yyyy HH:mm:ss');
        end

        if n1 ==1
            t2 = datetime(t2,'InputFormat','dd-MMM-yyyy');
        else
            t2 = datetime(t2,'InputFormat','dd-MMM-yyyy HH:mm:ss');
        end;
        HMS_simu_time = between(t1,t2,'Time');
        [m,d,t] = split(HMS_simu_time,{'months','days','time'});
        Number_hours_simu_HECHMS = hours(t);
elseif RASORHMS == 2
    C1 = strsplit(DateRAS,'=');
    C1 = char(C1(2));
    C1 = strsplit(C1,',');
    C1A = char(C1(1)) ; 
    
    D1A =  char(C1(2));
    D1A = regexp(D1A,'\d','match')';
    t1A = char(D1A);
    t1 = [C1A ' ' t1A(1) t1A(2) ':' t1A(3) t1A(4)];    
    t1 = datestr(t1);
    
    C1B = char(C1(3));
    C1B = datestr(C1B);
    D1A =  char(C1(4));
    D1A = regexp(D1A,'\d','match')';
    t1A = char(D1A);
    t2 = [C1B ' ' t1A(1) t1A(2) ':' t1A(3) t1A(4)];    
    t2 = datestr(t2);
    
    howmanyelem = strsplit(t1);
        [m,n1] = size(howmanyelem);
    howmanyelem = strsplit(t2);
        [m,n2] = size(howmanyelem);
        if n1 ==1
            t1 = datetime(t1,'InputFormat','dd-MMM-yyyy');
        else
            t1 = datetime(t1,'InputFormat','dd-MMM-yyyy HH:mm:ss');
        end

        if n1 ==1
            t2 = datetime(t2,'InputFormat','dd-MMM-yyyy');
        else
            t2 = datetime(t2,'InputFormat','dd-MMM-yyyy HH:mm:ss');
        end;
    RAS_simu_time = between(t1,t2,'Time');
    [m,d,t] = split(RAS_simu_time,{'months','days','time'});
    Number_hours_simu_RAS = hours(t);
else 
   error('BetweenTimes_HMS is not HMS or RAS'); 
end
end