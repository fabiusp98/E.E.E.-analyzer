%E.E.E.-analyzer - GRAPH ENGINE by Fabio Pinciroli
%Copyright 2016 Fabio Pinciroli DISTRIBUTED UNDER GPL V3 LICENSE
%TODO: NONE

function GraphStats(repFile, path, dati, col, name, ko, saveMode)

figure('Name', strcat(name, ' stats'));                                    %make window

TOFmin = min(dati(:,col));                                                 %do statistics
TOFmax = max(dati(:,col));
TOFmedian = median(dati(:,col));
TOFmode = mode(dati(:,col));
TOFavg = mean(dati(:,col));

fprintf(repFile, '%s min: %f\n', name, TOFmin);                            %add statistics to the report
fprintf(repFile, '%s max: %f\n', name, TOFmax);
fprintf(repFile, '%s avg: %f\n', name, TOFavg);
fprintf(repFile, '%s mode: %f\n', name, TOFmode);
fprintf(repFile, '%s median: %f\n\n', name, TOFmedian);

plot(dati(:,col),'+');                                                     %make legend
title(name);                                                               
xlabel('Event number');
ylabel(name);
lMax = refline(0,TOFmax);                                                  %setup statistics lines
lMax.Color = 'r';                                                          %color
lMax.LineStyle = '--';                                                     %style 
lMin = refline(0,TOFmin);                                                  %repeat for the other stats
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
saveas(gcf, [path strcat(name, 'Stats')], saveMode);                                 %save                                            

if ko == 0                                                                 %if persistency off, close the window
 close();
end

figure('Name', strcat(name, ' distribution'));                             %make window
pd = fitdist(dati(:,col), 'Normal');                                       %calculate distribution
assX = TOFmin:0.00001:TOFmax;                                              %setup axes
plot(assX, pdf(pd, assX));                                                 %plot curve
title(strcat(name, ' distribution'));                                      %setup axes name
clear assX;                                                                %delete index
saveas(gcf, [path strcat(name, 'Distribution')], saveMode);                          %save
if ko == 0
 close();
end