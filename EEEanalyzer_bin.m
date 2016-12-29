%E.E.E.-analyzer - MAIN by Fabio Pinciroli
%Copyright 2016 Fabio Pinciroli DISTRIBUTED UNDER GPL V3 LICENSE
%TODO:
%Finish setting up the report
%Finish TOF calculations

%EXPERIMENTAL
figSaveMode = 'png'; %this changes the way figures are saved, it supports all the things that saveas does

%Get component paths-------------------------------------------------------
[fName, fDir] = uigetfile('*.bin', 'Seleziona file');	%get file name
[wGetName, wGetDir] = uigetfile('*.exe', 'Seleziona file');	%get path to wget
[v20Name, v20Dir] = uigetfile('*.exe', 'Seleziona file');	%get path to eee_v20

%Create working folder and convert file------------------------------------
mkdir(fDir, fName(1: length(fName) - 4));	%create working folder
movefile(fullfile(fDir, fName), strcat(fDir,strcat('/', fName(1: length(fName) - 4))));	%move the file to the working folder

fDir = strcat(fDir, strcat(fName(1: length(fName) - 4), '\'));	%update fDir pointer to new file location

%comA = strcat('cd "', strcat(fDir, strcat('" &&', strcat('"', strcat(v20Dir, strcat(v20Name, strcat('" "', strcat(fName, strcat('" "', strcat(fDir, '"'))))))))));	%run eee_v20 on file, to current directory
comA = strcat('cd "',fDir,'" &&','"',v20Dir,v20Name,'" "',fName,'" "',fDir, '"');
system(comA);

fName = strcat(fName(1: length(fName) - 3), 'out');	%update data file name to the converted one

fRep = fopen(fullfile(fDir, 'REPORT.txt'), 'wt');	%open report file

%Data import---------------------------------------------------------------
comA = ['powershell -Command "(get-content ''', fDir, fName, ''') | foreach-object {$_ -replace ''\s{3,}'', '',''} | Set-Content ''', fDir, fName, '''"'];  %change from tabulated separation to comma separation
system(comA); %Done on powershell for speed

comA = ['powershell -Command "(get-content ''', fDir, fName, ''') | select -Skip 1 | Set-Content ''', fDir, fName, '''"']; %remove first line of data file(description)
system(comA);

dati = csvread(fullfile(fDir, fName));  %import data      

[dataLenght, varB] = size(dati); %calculate array size

%Extract Telescope name, acquisition date----------------------------------
tName = fName(1: length(fName) - 21);                                      

tYear = fName(length(fName) - 19: length(fName) - 16);

tMonth = fName(length(fName) - 14: length(fName) - 13);

tDay = fName(length(fName) - 11: length(fName) - 10);

tDate = fName(length(fName) - 19: length(fName) - 10);

%download and save the dqm Report------------------------------------------
%Downloads done with wget instead of the matlab comand because the dqm site has a broken SSL certificate, and the matlab comand refuses to work.
%comA = strcat('cd "', strcat(fDir, strcat('" &&', strcat('"', strcat(wGetDir, strcat(wGetName, strcat('" -p -nd --no-check-certificate', strcat(' https://www1.cnaf.infn.it/eee/monitor//dqmreport/', strcat(tName, strcat('/', strcat(tDate, '/'))))))))))); %Get the page
comA = strcat('cd "',fDir,'" &&','"',wGetDir,wGetName,'" -p -nd --no-check-certificate',' https://www1.cnaf.infn.it/eee/monitor//dqmreport/',tName,'/',tDate, '/');
system(comA);

comA = strcat('cd "',fDir,'" &&','"',wGetDir,wGetName,'"  -r -a png -nd --no-check-certificate',' https://www1.cnaf.infn.it/eee/monitor//dqmreport/',tName,'/',tDate, '/');
%comA = strcat('cd "', strcat(fDir, strcat('" &&', strcat('"', strcat(wGetDir, strcat(wGetName, strcat('"  -r -a png -nd --no-check-certificate', strcat(' https://www1.cnaf.infn.it/eee/monitor//dqmreport/', strcat(tName, strcat('/', strcat(tDate, '/'))))))))))); %Get the images
system(comA);

format long;                                                               %Set full decimal resolution

%Count hits with chi^2 > 10------------------------------------------------
tot = 0;    %counter
for cnt = 1:1:dataLenght    %pass all the data
    if dati(cnt, 9) > 10    %if hit found
        tot = tot + 1;  %advance counter
    end
end
fprintf(fRep, 'Hits with Chi^2 > 10: %f\n', tot);

%Remove entries with chi^2 > %10-------------------------------------------
cnt = 1;    %arrays in matlab start at 1 ??? – – – :-)

while cnt < dataLenght %for loop done with while because for in matlab doesn't care about upper limit updates ??? – – – :-)
    if dati(cnt, 9) > 10 %if erroneous entry found   
         dati(cnt,:) = [];  %delete row
         dataLenght = dataLenght - 1;   %decrease array size because a row has been deleted
         cnt = cnt - 1; %recheck same line because everything above the current position shifted back one row
    end
    cnt = cnt + 1 ; %advance to the next row
end

%Min max avg and distribution of X, Y, Z, chi^2, TOF and track lenght------
GraphStats(fRep, fDir, dati, 6, 'X', 0, figSaveMode);
GraphStats(fRep, fDir, dati, 7, 'Y', 0, figSaveMode);
GraphStats(fRep, fDir, dati, 8, 'Z', 0, figSaveMode);
GraphStats(fRep, fDir, dati, 9, 'Chi^2', 0, figSaveMode);
GraphStats(fRep, fDir, dati, 10, 'TOF', 0, figSaveMode);
GraphStats(fRep, fDir, dati, 11, 'Track lenght', 0, figSaveMode);

%TO REVISE-----------------------------------------------------------------
fprintf(fRep, '\nRun duration in senconds: %f\n', dati(dataLenght, 3) - dati(1, 3)); 
fprintf(fRep, '!!!VAL_COL_5: %f\n', dati(dataLenght, 4) - dati(1, 4));
fprintf(fRep, '!!!VAL_COL_6: %f\n', dati(dataLenght, 5) - dati(1, 5));

%Count negative flight times-----------------------------------------------
tot = 0;
for cnt = 1:1:dataLenght
    if dati(cnt, 10) < 0
        tot = tot + 1;
    end
end
fprintf(fRep, '\nNegative TOF: %f\n', tot);

%Count zero flight times and prepare separate array array------------------
tot = 0;
for cnt = 1:1:dataLenght
    if dati(cnt, 9) == 0
        tot = tot + 1;
        negTof(tot) = cnt;                                   
    end
end
fprintf(fRep, 'Null TOF: %f\n', tot);

%gropued statistics for X Y e Z----------------------------------------
figure('Name', 'Coordinates Stats');

yy(1, 1) = min(dati(:,6));
yy(1, 2) = mean(dati(:,6));
yy(1, 3) = max(dati(:,6));

yy(2, 1) = min(dati(:,7));
yy(2, 2) = mean(dati(:,7));
yy(2, 3) = max(dati(:,7));

yy(3, 1) = min(dati(:,8));
yy(3, 2) = mean(dati(:,8));
yy(3, 3) = max(dati(:,8));

bar(yy);

xx = {'X', 'Y', 'Z'};
set(gca, 'XTick', 1:4, 'XTickLabel', xx);


l = cell(1,3);
l{1} = 'Min';
l{2} = 'Avg';
l{3} = 'Max';
legend(l);

clear xx;
clear yy;

saveas(gcf, [fDir 'XYZ Stats.png']);                                       %Save image to directory

ko = 0; %DEBUG!!!
if ko == 0                                                                 %automatic close graph windows
 close();
end

%Angular statistics--------------------------------------------------------
for cnt = 1:1:dataLenght 
    dati(cnt, 12) = acos(dati(cnt, 8)); 
end

for cnt = 1:1:dataLenght 
    dati(cnt, 13) = dati(cnt, 8)/dati(cnt, 6); 
end

for cnt = 1:1:dataLenght 
    dati(cnt, 14) = atan(dati(cnt, 7)); 
end

for cnt = 1:1:dataLenght 
    dati(cnt, 15) = rad2deg(dati(cnt, 12)); 
end

for cnt = 1:1:dataLenght 
    dati(cnt, 16) = rad2deg(dati(cnt, 14)); 
end

GraphStats(fRep, fDir, dati, 15, 'Radius (deg)', 0, figSaveMode);
GraphStats(fRep, fDir, dati, 16, 'Azimuth (deg)', 0, figSaveMode);

fclose(fRep);   %close report

disp('DONE');