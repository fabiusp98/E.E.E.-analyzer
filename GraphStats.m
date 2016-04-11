%E.E.E.-analyzer - GRAPH ENGINE by Fabio Pinciroli
%Copyright 2016 Fabio Pinciroli DISTRIBUTED UNDER GPL V3 LICENSE
%TODO: NONE

function GraphStats(repFile, path, dati, col, name, ko)

figure('Name', strcat(name, ' stats'));                                    %spawna finestra

TOFmin = min(dati(:,col));                                                 %calcola valori statistici
TOFmax = max(dati(:,col));
TOFmedian = median(dati(:,col));
TOFmode = mode(dati(:,col));
TOFavg = mean(dati(:,col));

fprintf(repFile, '%s min: %f\n', name, TOFmin);
fprintf(repFile, '%s max: %f\n', name, TOFmax);
fprintf(repFile, '%s avg: %f\n', name, TOFavg);
fprintf(repFile, '%s mode: %f\n', name, TOFmode);
fprintf(repFile, '%s median: %f\n\n', name, TOFmedian);


plot(dati(:,col),'+');                                                     %stampa dati in ordine
title(name);                                                               %imposta scritte, etc
xlabel('Numero evento');
ylabel(name);
lMax = refline(0,TOFmax);                                                  %fai linea per il massimo
lMax.Color = 'r';                                                          %imposta colore
lMax.LineStyle = '--';                                                     %imposta stile  
lMin = refline(0,TOFmin);                                                  %ripeti per le altre statistiche
lMin.Color = 'b';
lMin.LineStyle = '--';
lMedian = refline(0,TOFmedian);
lMedian.Color = 'g';
lMedian.LineStyle = '--';
lMode = refline(0,TOFmode);
lMode.Color = 'magenta';
lMode.LineStyle = '--';
lAvg = refline(0,TOFavg);
lAvg.Color = 'cyan';
lAvg.LineStyle = '--';
legend('Dati', strcat('Max = ', 32, num2str(TOFmax)), strcat('Min = ', 32, num2str(TOFmin)), strcat('Median = ', 32, num2str(TOFmedian)), strcat('Mode = ', 32, num2str(TOFmode)), strcat('Average = ', 32, num2str(TOFavg)));
saveas(gcf, [path strcat(name, 'Stats.jpg')]);                             %salva in directory attuale con nome corretto in jpeg                                            

if ko == 0                                                                 %se persistenza off chiudi finestre
 close();
end

figure('Name', strcat(name, ' distribution'));                             %spawna finestra
pd = fitdist(dati(:,col), 'Normal');                                       %calcola distribuzione normale
assX = TOFmin:0.00001:TOFmax;                                              %genera indice asse x dal minimo valore al massimo e in step corretti
plot(assX, pdf(pd, assX));                                                 %stampa curva
title(strcat(name, ' distribution'));                                      %imposta scritte, etc
clear assX;                                                                %cancella indice
saveas(gcf, [path strcat(name, 'Distribution.jpg')]);                      %salva in directory attuale con nome corretto in jpeg 

if ko == 0
 close();
end