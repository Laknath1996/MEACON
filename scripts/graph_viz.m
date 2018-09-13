% graph visualizer

function h = graph_viz(adj_mat,name)
    n = size(adj_mat,1);
    rm = {[1,1],[1,2],[1,3],[2,1],[2,2],[3,1],[10,1],[11,1],[11,2],[12,1],...
            [12,2],[12,3],[1,10],[1,11],[1,12],[2,11],[2,12],[3,12],...
            [10,12],[11,11],[11,12],[12,10],[12,11],[12,12]};
    % define the node locations
    nodes = {};
    for i = 1:12
        for j = 1:12
            nodes{i,j} = [i,j];
        end
    end
    for i = 1:numel(rm)
        nodes{rm{i}(1),rm{i}(2)} = [0,0];
    end
    Loc = zeros(120,2);
    nodes = reshape(nodes,[144,1]);
    k = 1;
    for i = 1:144
        if (nodes{i}(1) ~= 0 && nodes{i}(2) ~= 0)
        Loc(k,1) = nodes{i}(1);
        Loc(k,2) = nodes{i}(2);
        k = k + 1;
        end
    end
    
    % Determine node locations:
    %Loc=rand(length(adj_mat),2);
    weight=nonzeros(adj_mat);
    
    % Create the digraph, and modify plot parameters
    G=digraph(adj_mat);
    h=plot(G);
    colormap([[0 0 0];jet(256)]);          % select color palette 
    h.EdgeCData=weight;    % define edge colors
    h.MarkerSize = 4;
    h.XData=Loc(:,1);      % place node locations on plot
    h.YData=Loc(:,2);
    colorbar
    % hide axes:
    set(gca,'XTickLabel',{' '})
    set(gca,'YTickLabel',{' '})
    set(gca,'YTick',[])
    set(gca,'XTick',[])
    % title(name);
    
end