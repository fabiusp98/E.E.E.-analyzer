%E.E.E.-analyzer - GRAPH ENGINE by Fabio Pinciroli
%Copyright 2016 Fabio Pinciroli DISTRIBUTED UNDER GPL V3 LICENSE
%TODO: NONE

function GraphStats(dati, name, fDir, figSaveMode)
    %define edges (now every 1 degrees)
    edges = 0:1:365;
    
    %do bins
    dist = histcounts (dati, edges);
    
    %apply correction factor
    %{
    correction = ???
    [edgeNum, ~] = size(dist);
    for cnt = 1:1:edgeNum
        dist(cnt) = dist(cnt) * correction(cnt);
    end
    %}
    
    figure('Name', name);
    plot(dist);
    title(name);
    grid on;
    saveas(gcf, [fDir, name], figSaveMode);
    close();
end