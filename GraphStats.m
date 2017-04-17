%E.E.E.-analyzer - GRAPH ENGINE by Fabio Pinciroli
%Copyright 2016 Fabio Pinciroli DISTRIBUTED UNDER GPL V3 LICENSE
%TODO: NONE

function GraphStats(dati, name, fDir, figSaveMode)
    %define edges (now every 1 degrees)
    edges = 0:1:365;
    
    %do bins
    dist = histcounts (dati(:,15), edges);
    
    %apply correction factor
    %{
    correction = ???
    [edgeNum, ~] = size(dist);
    for cnt = 1:1:edgeNum
        dist(cnt) = dist(cnt) * correction(cnt);
    end
    %}
    
    %{
    %polar plot 
    figure('Name', strcat(name, ' - polar'));
    polarplot(dist);
    title(strcat(name, ' - POLAR'));
    view(90, -90);
    saveas(gcf, [fDir, strcat('POLAR - ', name)], figSaveMode);
    close();
    %}
    
    figure('Name', name);
    plot(dist);
    title(name);
    grid on;
    saveas(gcf, [fDir, name], figSaveMode);
    close();
end