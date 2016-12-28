%E.E.E.-analyzer - MAIN by Fabio Pinciroli
%Copyright 2016 Fabio Pinciroli DISTRIBUTED UNDER GPL V3 LICENSE
%TODO:
%Finish setting up the report
%Finish TOF calculations
%identified problem with auto import: remove header, change from tab separation to comma separation(regexp: s{3,} to ,), columns fixed

%Get component paths-------------------------------------------------------
[fName, fDir] = uigetfile('*.bin', 'Seleziona file');	%get file name
[wGetName, wGetDir] = uigetfile('*.exe', 'Seleziona file');	%get path to wget
[v20Name, v20Dir] = uigetfile('*.exe', 'Seleziona file');	%get path to eee_v20

tic();  %PROFILING TIMER

%Create working folder and convert file------------------------------------
mkdir(fDir, fName(1: length(fName) - 4));	%create working folder
movefile(fullfile(fDir, fName), strcat(fDir,strcat('/', fName(1: length(fName) - 4))));	%move the file to the working folder

fDir = strcat(fDir, strcat(fName(1: length(fName) - 4), '\'));	%update fDir pointer to new file location

comA = strcat('cd "', strcat(fDir, strcat('" &&', strcat('"', strcat(v20Dir, strcat(v20Name, strcat('" "', strcat(fName, strcat('" "', strcat(fDir, '"'))))))))));	%run eee_v20 on file, to current directory
system(comA);

fName = strcat(fName(1: length(fName) - 3), 'out');	%update data file name to the converted one

fRep = fopen(fullfile(fDir, 'REPORT.txt'), 'wt');	%open report file

%Data import---------------------------------------------------------------
%comA = strcat('powershell -Command "(get-content ', ' ' ,fDir, fName, ') | foreach-object {$_ -replace ''\s{3,}'', '',''} | Set-Content ', ' ' ,fDir, fName, '"');	%Replace spaces with commas in data file
comA = ['powershell -Command "(get-content ''', fDir, fName, ''') | foreach-object {$_ -replace ''\s{3,}'', '',''} | Set-Content ''', fDir, fName, '''"'];
system(comA);

%comA = strcat('powershell -Command "(get-content ', ' ' ,fDir, fName, ') | select -Skip 1 | set-content ', ' ', fDir, fName, '"');  %remove first line in file
comA = ['powershell -Command "(get-content ''', fDir, fName, ''') | select -Skip 1 | Set-Content ''', fDir, fName, '''"'];
system(comA);

dati = csvread(fullfile(fDir, fName));  %import data                              

%Extract Telescope name, acquisition date----------------------------------
tName = fName(1: length(fName) - 21);                                      

tYear = fName(length(fName) - 19: length(fName) - 16);

tMonth = fName(length(fName) - 14: length(fName) - 13);

tDay = fName(length(fName) - 11: length(fName) - 10);

tDate = fName(length(fName) - 19: length(fName) - 10);

%download and save the dqm Report------------------------------------------
comA = strcat('cd "', strcat(fDir, strcat('" &&', strcat('"', strcat(wGetDir, strcat(wGetName, strcat('" -p -nd --no-check-certificate', strcat(' https://www1.cnaf.infn.it/eee/monitor//dqmreport/', strcat(tName, strcat('/', strcat(tDate, '/')))))))))));
system(comA);
comA = strcat('cd "', strcat(fDir, strcat('" &&', strcat('"', strcat(wGetDir, strcat(wGetName, strcat('"  -r -a png -nd --no-check-certificate', strcat(' https://www1.cnaf.infn.it/eee/monitor//dqmreport/', strcat(tName, strcat('/', strcat(tDate, '/')))))))))));
system(comA);

format long;                                                               %Set full decimal resolution

%Count hits with chi^2 > 10------------------------------------------------
tot = 0;
for cnt = 1:1:varA
    if dati(cnt, 9) > 10
        tot = tot + 1;
    end
end
fprintf(fRep, '\nHits with Chi^2 > 10: %f\n', tot);

%Min max avg and distribution of X, Y, Z, chi^2, TOF and track lenght------
GraphStats(fRep, fDir, dati, 6, 'X', 0);
GraphStats(fRep, fDir, dati, 7, 'Y', 0);
GraphStats(fRep, fDir, dati, 8, 'Z', 0);
GraphStats(fRep, fDir, dati, 9, 'Chi^2', 0);
GraphStats(fRep, fDir, dati, 10, 'TOF', 0);
GraphStats(fRep, fDir, dati, 11, 'Track lenght', 0);

%TO REVISE-----------------------------------------------------------------
[varA, varB] = size(dati);                                                 %calcola dimensioni array
fprintf(fRep, '\nRun duration in senconds: %f\n', dati(varA, 3) - dati(1, 3)); 
fprintf(fRep, '!!!VAL_COL_5: %f\n', dati(varA, 4) - dati(1, 4));
fprintf(fRep, '!!!VAL_COL_6: %f\n', dati(varA, 5) - dati(1, 5));

%Count negative flight times-----------------------------------------------
tot = 0;
for cnt = 1:1:varA
    if dati(cnt, 10) < 0
        tot = tot + 1;
    end
end
fprintf(fRep, '\nNegative TOF: %f\n', tot);

%Count zero flight times and prepare separate array array------------------
tot = 0;
for cnt = 1:1:varA
    if dati(cnt, 9) == 0
        tot = tot + 1;
        negTof(tot) = cnt;                                                 %#ok<SAGROW> %aggiungi indirizzo di ogni TOF negativo all'array                                   
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

saveas(gcf, [fDir 'XYZ Stats.jpg']);                                       %salva in directory attuale con nome corretto in jpeg

ko = 0; %DEBUG!!!
if ko == 0                                                                 %se persistenza off chiudi finestre
 close();
end

%Angular statistics--------------------------------------------------------
for cnt = 1:1:varA 
    dati(cnt, 12) = acos(dati(cnt, 8)); 
end

for cnt = 1:1:varA 
    dati(cnt, 13) = dati(cnt, 8)/dati(cnt, 6); 
end

for cnt = 1:1:varA 
    dati(cnt, 14) = atan(dati(cnt, 7)); 
end

for cnt = 1:1:varA 
    dati(cnt, 15) = rad2deg(dati(cnt, 12)); 
end

for cnt = 1:1:varA 
    dati(cnt, 16) = rad2deg(dati(cnt, 14)); 
end

GraphStats(fRep, fDir, dati, 15, 'Radius (deg)', 0);
GraphStats(fRep, fDir, dati, 16, 'Azimuth (deg)', 0);

fclose(fRep);   %close report

disp('DONE');   %display end of run message
toc();  %DEBUG profiling timer