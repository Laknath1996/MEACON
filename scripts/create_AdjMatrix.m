function adj_matrix = create_AdjMatrix(xc_bin, threshold, lag_norm)
% define some useful params 

n = size(xc_bin,2);
adj_matrix = zeros(n,n); % define an empty matrix

for i = 1:n
    for j = i+1:n
        % the metric to be computed from the cross covriance vector
        %adj_matrix(i,j) = mean(xc{i,j});
        temp = xc_bin{i,j};
        pos_lags = temp(1:lag_norm);
        neg_lags = temp(lag_norm+2:lag_norm*2+1);
        adj_matrix(i,j) = max(pos_lags);
        adj_matrix(j,i) = max(neg_lags);
    end
end

adj_matrix(isnan(adj_matrix)) = 0; % replace the NaN elements with zeros

% threshold the matrix
%adj_matrix = adj_matrix > threshold;
adj_matrix = double(adj_matrix);
adj_matrix(adj_matrix < threshold) = 0;

end



