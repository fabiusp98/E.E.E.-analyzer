%E.E.E.-analyzer - MAIN by Fabio Pinciroli
%Copyright 2016 Fabio Pinciroli DISTRIBUTED UNDER GPL V3 LICENSE
%TODO:
%<26>vedere per problema di certificati sul sito web dqm
%<48>mettere apposto label file report

[fName, fDir] = uigetfile('*.csv', 'Seleziona file');                      %chiedi nome file
tic();
mkdir(fDir, fName(1: length(fName) - 4));                                  %fai cartella col nome del file
movefile(fullfile(fDir, fName), strcat(fDir,strcat('/', fName(1: length(fName) - 4))));    %muovici detro il file csv

fDir = strcat(fDir, strcat(fName(1: length(fName) - 4), '\'));             %aggiorna fDir alla locazione attuale

fRep = fopen(fullfile(fDir, 'REPORT.txt'), 'wt');                          %apri file report numerico

%importa dati--------------------------------------------------------------
dati = csvread(fullfile(fDir, fName));                                     

%estrai nome telescopio, giorno, mese, anno--------------------------------
tName = fName(1: length(fName) - 21);                                      

tYear = fName(length(fName) - 19: length(fName) - 16);

tMonth = fName(length(fName) - 14: length(fName) - 13);

tDay = fName(length(fName) - 11: length(fName) - 10);

tDate = fName(length(fName) - 19: length(fName) - 10);

%salva report dqm----------------------------------------------------------
%websave([fDir 'dqmReport'], strcat('https://www1.cnaf.infn.it/eee/monitor//dqmreport/', strcat(tName, strcat('/', strcat(tDate, '/')))));
%FIXARE PROBLEMA DEI CERTIFICATI!!!
%http://dotbootstrap.x2q.net/java-default-keystore-password-cacerts/
%http://it.mathworks.com/matlabcentral/answers/92506-can-i-force-urlread-and-other-matlab-functions-which-access-internet-websites-to-open-secure-websi http://it.mathworks.com/matlabcentral/answers/39563-managing-public-key-certificates-in-matlab

format long;                                                               %imposta display a piena risoluzione

%Statistiche di base X, Y, Z, chi^2, TOF, e lunghezza traccia--------------
GraphStats(fRep, fDir, dati, 7, 'X', 0);
GraphStats(fRep, fDir, dati, 8, 'Y', 0);
GraphStats(fRep, fDir, dati, 9, 'Z', 0);
GraphStats(fRep, fDir, dati, 10, 'Chi^2', 0);
GraphStats(fRep, fDir, dati, 11, 'TOF', 0);
GraphStats(fRep, fDir, dati, 12, 'Track lenght', 0);

%Differenza colonne tempi--------------------------------------------------
[varA, varB] = size(dati);                                                 %calcola dimensioni array
fprintf(fRep, '\nRun duration in senconds: %f\n', dati(varA, 4) - dati(1, 4)); 
fprintf(fRep, '!!!VAL_COL_5: %f\n', dati(varA, 5) - dati(1, 5));
fprintf(fRep, '!!!VAL_COL_6: %f\n', dati(varA, 6) - dati(1, 6));

%Conta quanti chi^2 maggiori di 10-----------------------------------------
tot = 0;
for cnt = 1:1:varA
    if dati(cnt, 10) > 10
        tot = tot + 1;
    end
end
fprintf(fRep, '\nHits with Chi^2 > 10: %f\n', tot);

%Conta TOF negativi--------------------------------------------------------
tot = 0;
for cnt = 1:1:varA
    if dati(cnt, 11) < 0
        tot = tot + 1;
    end
end
fprintf(fRep, '\nNegative TOF: %f\n', tot);

%Conta TOF 0 e metti in array----------------------------------------------
tot = 0;
for cnt = 1:1:varA
    if dati(cnt, 11) == 0
        tot = tot + 1;
        negTof(tot) = cnt;                                                 %#ok<SAGROW> %aggiungi indirizzo di ogni TOF negativo all'array                                   
    end
end
fprintf(fRep, 'Null TOF: %f\n', tot);

%Statistiche raggruppate di X Y e Z----------------------------------------
figure('Name', 'Coordinates Stats');

yy(1, 1) = min(dati(:,7));
yy(1, 2) = mean(dati(:,7));
yy(1, 3) = max(dati(:,7));

yy(2, 1) = min(dati(:,8));
yy(2, 2) = mean(dati(:,8));
yy(2, 3) = max(dati(:,8));

yy(3, 1) = min(dati(:,9));
yy(3, 2) = mean(dati(:,9));
yy(3, 3) = max(dati(:,9));

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

%Calcoli angoli------------------------------------------------------------
for cnt = 1:1:varA 
    dati(cnt, 13) = acos(dati(cnt, 9)); 
end

for cnt = 1:1:varA 
    dati(cnt, 14) = dati(cnt, 8)/dati(cnt, 7); 
end

for cnt = 1:1:varA 
    dati(cnt, 15) = atan(dati(cnt, 8)); 
end

for cnt = 1:1:varA 
    dati(cnt, 16) = radtodeg(dati(cnt, 13)); 
end

for cnt = 1:1:varA 
    dati(cnt, 17) = radtodeg(dati(cnt, 15)); 
end

GraphStats(fRep, fDir, dati, 16, 'Radius (deg)', 0);
GraphStats(fRep, fDir, dati, 17, 'Azimuth (deg)', 0);

fclose(fRep);
disp('DONE');
toc();









