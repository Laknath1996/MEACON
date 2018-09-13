function plot_graph(adj_matrix)

% define the coordinates of the nodes
[X,Y] = meshgrid(-2:2,-2:2); % change the values for a different number of channelsc
nodes = zeros(25,2);
k = 1;
for i = 1:5
    for j = 1:5
        nodes(k,1) = X(i,j);
        nodes(k,2) = Y(i,j);
        k = k + 1;
    end
end

% draw the graph
gplot(adj_matrix,nodes,'-*');set(gca,'XTickLabel','','YTickLabel','','Visible','off','color','w');
axis equal;hold on;
plot(X,Y,'ro');

end
