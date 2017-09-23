%E.E.E.-analyzer - MAIN by Fabio Pinciroli
%Copyright 2016-2017 Fabio Pinciroli DISTRIBUTED UNDER GPL V3 LICENSE

function EEEanalyzer_bin(figSaveMode, fName, fDir, v20Name, v20Dir, doDqm, doStats)
    
    wbar = waitbar(0/10, 'Setting up folders');    %set progress bar
    wbar.WindowStyle = 'modal';
    
    %Create working folder and convert file------------------------------------
    mkdir(fDir, fName(1: length(fName) - 4));	%create working folder
    movefile(fullfile(fDir, fName), strcat(fDir,'/', fName(1: length(fName) - 4)));	%move the file to the working folder

    fDir = strcat(fDir, strcat(fName(1: length(fName) - 4), '\'));	%update fDir pointer to new file location
    
    if doDqm
        mkdir(fDir, 'DQM');	%create dqm folder
    end
    
    waitbar(1/11, wbar, 'Converting data');    %update progress bar
    
    comA = strcat('cd "',fDir,'" &&','"',v20Dir,v20Name,'" "',fName,'" "',fDir, '"'); %run eee_v20 on file, to current directory
    system(comA);

    fName = strcat(fName(1: length(fName) - 3), 'out');	%update data file name to the converted one
    
    fRep = fopen(fullfile(fDir, 'STATISTICS REPORT.txt'), 'wt');	%open report file

    %Data import---------------------------------------------------------------
    waitbar(2/11, wbar, 'Prepairing data for import');    %update progress bar
    
    comA = ['sed -i "s/\s\{3,\}/,/g" "', fDir, fName,'"'];
    system(comA); %Done with sed for cross platform compatibility and is faster that powershell
    
    comA = ['sed -i "1d" "', fDir, fName, '"'];
    system(comA);
    
    waitbar(3/11, wbar, 'Importing data');    %update progress bar
    
    format long;                                                               %Set full decimal resolution
    
    dati = csvread(fullfile(fDir, fName));  %import data      
    
    [dataLenght, ~] = size(dati); %calculate array size
    
    %Folder cleanup--------------------------------------------------------
    delete(strcat(fDir, fName(1: length(fName) - 3), 'out'));
    delete(strcat(fDir, fName(1: length(fName) - 3), '2tt'));
    delete(strcat(fDir, fName(1: length(fName) - 3), 'sum'));
    delete(strcat(fDir, fName(1: length(fName) - 3), 'tim'));
    delete(strcat(fDir, 'eee_calib.txt'));
    
   %{
    *=calcualted field
    |1         |2                   |3                     |4          |5                              |6       |7       |8       |9    |10 |11          |12*             |13*       |14*       |15*            |
    |RUN NUMBER|TELESCOPE HIT NUMBER|SECONDS SINCE 1/1/2007|NANOSECONDS|MICROSECONDS SINCE STARD OF RUN|VECTOR X|VECTOR Y|VECTOR Z|CHI^2|TOF|TRACK LENGHT|EFFECTIVE NUMBER|THETA(RAD)|THETA(DEG)|0-360 DIRECTION|
    %}

    %Extract Telescope name, acquisition date----------------------------------
    tName = fName(1: length(fName) - 21);                                      

    tYear = fName(length(fName) - 19: length(fName) - 16);

    tMonth = fName(length(fName) - 14: length(fName) - 13);

    tDay = fName(length(fName) - 11: length(fName) - 10);

    tDate = fName(length(fName) - 19: length(fName) - 10);

    %download and save the dqm Report------------------------------------------
    %Downloads done with wget instead of the matlab comand because the dqm site has a broken SSL certificate, and the matlab comand refuses to work.
    
    if doDqm
        waitbar(4/11, wbar, 'Downloading DQM data');    %update progress bar

        %comA = strcat('cd "',strcat(fDir, '\DQM\'),'" &&','"',wGetDir,wGetName,'" -p -nd --no-check-certificate',' https://www1.cnaf.infn.it/eee/monitor//dqmreport/',tName,'/',tDate, '/'); %Get the page
        comA = strcat('wget -nd --no-check-certificate https://www1.cnaf.infn.it/eee/monitor//dqmreport/',tName,'/',tDate,'/ -P "',fDir,'\DQM\');
        system(comA);

        %comA = strcat('cd "',strcat(fDir, '\DQM\'),'" &&','"',wGetDir,wGetName,'"  -r -a png -nd --no-check-certificate',' https://www1.cnaf.infn.it/eee/monitor//dqmreport/',tName,'/',tDate, '/'); %Get the images
        comA = strcat('wget -r -a png -nd --no-check-certificate https://www1.cnaf.infn.it/eee/monitor//dqmreport/',tName,'/',tDate,'/ -P "',fDir,'\DQM\');
        system(comA);
    end
    
    %!!!TODO basic data----------------------------------------------
    %header
    waitbar(5/11, wbar, 'Doing report');    %update progress bar
    fprintf(fRep, 'E.E.E. packet automatic analysis report\nGenerated by E.E.E. analyzer by Fabio Pinciroli (https://github.com/fabiusp98/E.E.E.-analyzer)\n');
    
    %telescope
    fprintf(fRep, 'Telescope: %s \n', tName);
    
    %Start time
    epoch = datetime(2007,1,1,0,0,0);   %start epoch(1/1/2007 00:00:00)
    
    fprintf(fRep, 'Run start: %s s\n', datestr(epoch + seconds(dati(1,3))));
    
    %Stop time
    fprintf(fRep, 'Run end: %s s\n', datestr(epoch + seconds(dati(dataLenght,3))));
    
    %run duration in seconds
    fprintf(fRep, 'Run duration: %f s\n', dati(dataLenght,3) - dati(1,3));
    
    %run duration in minutes
    fprintf(fRep, 'Run duration: %f m\n', (dati(dataLenght,3) - dati(1,3)) / 60);
    
    
    %Add other columns to working dataset--------------------------
    waitbar(6/11, wbar, 'Calculating entry angle');    %update progress bar
    tot = 0; %counter, init to 0
    
    for cnt = 1:1:dataLenght    %pass all the data
        %effective number
        dati(cnt, 12) = tot; %save counter do column
        tot = tot + 1;  %update counter
                
        %theta(rad)
        dati(cnt, 13) = asin(dati(cnt, 8));
        
        %theta(deg)
        dati(cnt, 14) = rad2deg(dati(cnt, 13));
        
        %0-360 direction
        if(dati(cnt, 6) < 0)
            dataOut = 180 + rad2deg(atan((dati(cnt, 7) / dati(cnt, 6))));
        else
            if(dati(cnt, 7) > 0)
                dataOut = rad2deg(atan((dati(cnt, 7) / dati(cnt, 6))));
            else
                dataOut = 360 + rad2deg(atan((dati(cnt, 7) / dati(cnt, 6))));
            end
        end      
        
        dati(cnt, 15) = dataOut;
        
    end
    
    %save effective number
    fprintf(fRep, 'Hits: %f \n', tot);
    
    waitbar(7/11, wbar, 'Calculating distribution');    %update progress bar
    %statistics of dirty dataset--------------------
    %heading
    fprintf(fRep, '\nDIRTY DATA STATISTICS:\n');
    
    %no hit events
    fprintf(fRep, 'no hit events: %f\n', dati(dataLenght,2) - dati(dataLenght,12)); 
    
    %save dirty data do first excel file--------------------------
    csvwrite(strcat(fDir, '/dirty data.csv'), dati);
    
    %Stats for track lenght----------------------------------------------
    fprintf(fRep, 'Track lenght max: %f \n', max(dati(:,11)));
    fprintf(fRep, 'Track lenght max: %f \n', min(dati(:,11)));
    fprintf(fRep, 'Track lenght mean: %f \n', mean(dati(:,11)));
    fprintf(fRep, 'Track lenght mode: %f \n', mode(dati(:,11)));
    fprintf(fRep, 'Track lenght median: %f \n', median(dati(:,11)));
    
    %Distribution--------------------------------------------------------   
    if doStats
        set(0,'DefaultFigureVisible','off');    %Turn off figure visibility
        GraphStats(dati, 'DIRTY DATA - angular distribution', fDir, figSaveMode);
        set(0,'DefaultFigureVisible','on'); %Turn figs back on
    end
   
    %count and move entries with chi^2 > %10-------------------------------------------
    waitbar(8/11, wbar, 'Filtering for chi^2');    %update progress bar
    
    cnt = 1;    %arrays in matlab start at 1 ??? � � � :-)
    tot = 0;    %chi2 entries total
    
    while cnt < dataLenght %for loop done with while because for in matlab doesn't care about upper limit updates ??? � � � :-)
        if dati(cnt, 9) > 10 %if erroneous entry found
             tot = tot + 1; %update count
             chiArray(tot + 1,:) = dati(cnt,:); %save data to other array (position is counter + 1 because matlab arrays suck and start at 1)
             %dati(cnt,:) = [];  %delete row in main array
             %cnt = cnt - 1; %recheck same line because everything above the current position shifted back one row
        end
        cnt = cnt + 1 ; %advance to the next row
    end
    
    fprintf(fRep, 'Hits with Chi^2 > 10: %f\n', tot);   %save chi2 count to report
    
    csvwrite(strcat(fDir, '/chi2.csv'), chiArray);  %save excel file for chi2 rejects
    
    %count entries with chi^2 > 10 and tof < 0-------------------------------------------    
    cnt = 1;    %arrays in matlab start at 1 ??? � � � :-)
    tot = 0;    %entries total
    
    while cnt < dataLenght %for loop done with while because for in matlab doesn't care about upper limit updates ??? � � � :-)
        if (dati(cnt, 9) > 10) && (dati(cnt, 10) < 0) %if erroneous entry found
             tot = tot + 1; %update count
        end
        cnt = cnt + 1 ; %advance to the next row
    end
    
    fprintf(fRep, 'Hits with Chi^2 > 10 and TOF < 0: %f\n', tot);   %save count to report
    
    
    %count and move entries with tof < 0-------------------------------------------
    waitbar(9/11, wbar, 'Filtering for TOF');    %update progress bar
    
    cnt = 1;    %arrays in matlab start at 1 ??? � � � :-)
    tot = 0;    %tof entries total
    
    while cnt < dataLenght %for loop done with while because for in matlab doesn't care about upper limit updates ??? � � � :-)
        if dati(cnt, 10) < 0 %if erroneous entry found
             tot = tot + 1; %update count
             tofArray(tot + 1,:) = dati(cnt,:); %save data to other array (position is counter + 1 because matlab arrays suck and start at 1)
             dati(cnt,:) = [];  %delete row in main array
             dataLenght = dataLenght - 1;   %decrease array size because a row has been deleted
             cnt = cnt - 1; %recheck same line because everything above the current position shifted back one row
        end
        cnt = cnt + 1 ; %advance to the next row
    end
    
    fprintf(fRep, 'TOF < 0: %f\n', tot);   %save tof count to report
    
    csvwrite(strcat(fDir, '/tof.csv'), tofArray);  %save excel file for tof rejects
    
    %clean back up for chi^2 > 0 (previously counted and capoed, but not deleted to not hinder the stats for the TOF)---------------
    cnt = 1;    %arrays in matlab start at 1 ??? � � � :-)
    
    while cnt < dataLenght %for loop done with while because for in matlab doesn't care about upper limit updates ??? � � � :-)
        if dati(cnt, 9) > 10 %if erroneous entry found
             dati(cnt,:) = [];  %delete row in main array
             dataLenght = dataLenght - 1;   %decrease array size because a row has been deleted
             cnt = cnt - 1; %recheck same line because everything above the current position shifted back one row
        end
        cnt = cnt + 1 ; %advance to the next row
    end
    
    csvwrite(strcat(fDir, '/clean data.csv'), dati);  %save excel file for tof rejects
    
    %Clean data header
    fprintf(fRep, '\nCLEAN DATA STATISTICS\n');
    waitbar(10/11, wbar, 'Calculating distribution');    %update progress bar
    %Stats for track lenght----------------------------------------------
    fprintf(fRep, 'Track lenght max: %f \n', max(dati(:,11)));
    fprintf(fRep, 'Track lenght max: %f \n', min(dati(:,11)));
    fprintf(fRep, 'Track lenght mean: %f \n', mean(dati(:,11)));
    fprintf(fRep, 'Track lenght mode: %f \n', mode(dati(:,11)));
    fprintf(fRep, 'Track lenght median: %f \n', median(dati(:,11)));
    
    %Distribution----------------------------------------------------------
    if doStats
        set(0,'DefaultFigureVisible','off');    %Turn off figure visibility
        GraphStats(dati, 'CLEAN DATA - angular distribution', fDir, figSaveMode);
        set(0,'DefaultFigureVisible','on'); %Turn figs back on
    end
    
    fclose(fRep);   %close report
    disp('DONE');
    
    delete('sed*'); %temporary fix: sed leaves a temp file in the matlab executable folder for some reason, this cleans it up. Otherwise the temp files accumulate> memory leak
    delete('png');
    
    delete(wbar);   %close waitbar
end