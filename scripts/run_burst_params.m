%% Network analysis for MEA data using BCT

% Miao Cao

% 11/09/2018

%% reset Matlab workspace

clc % clear the command window
clear % clear up the workspace
close all % close all the figure windows


%% Add toolbox path

% add Brain Connectivity Toolbox
% BCT_path = '***';
% addpath(genpath(BCT_path));

%% Data paths

[file,path] = uigetfile('Select the burst results file');
load(strcat(path,'/',file));
base_result_data_folder = uigetdir('Select the folder to save the results');

n = numel(burst_ctv_maps);

%% network analysis parameters

% thresholding proportion

threshold_list = [1.00, 0.05, 0.10, 0.15];

% graph analysis measure switchs

switch_degree_similarity = 1; % degree and similarity
switch_density = 1; % density and rentian scaling
switch_clustering_community_structure = 1; % clustering and community structure
switch_paths_distances = 0; % not applicable to functional network
switch_efficiency_diffusion = 0; % not applicable to functional networks
switch_centrality = 1;

keys = {'during_burst','pre_burst','post_burst'};

for key_ID = 1 : 3
    for selector_threshold = 1 : length(threshold_list)
        
        graph_degree = zeros(n,120);
        graph_strength = zeros(n,120);
        graph_density = zeros(n,1);
        graph_clustering_coefficient = zeros(120,n);
        graph_local_efficiency = zeros(120,n);
        graph_global_efficiency = zeros(n,1);
        graph_modularity = zeros(120,n);
        graph_transitivity = zeros(n,1);
        graph_betweenness_centrality = zeros(120,n);
        graph_edge_betweenness_centrality = {};
        
        % get a threhold
        thresholding_proportion = threshold_list(selector_threshold);

        if thresholding_proportion == 1
            str_thresholding_proportion = '100';
        else
            str_thresholding_proportion = num2str(thresholding_proportion);
        end

        disp(['Using threshold: ' str_thresholding_proportion '.']);
        
        
        %% create result folder to save data
     
        result_data_folder = [base_result_data_folder '/' keys{key_ID} '/' str_thresholding_proportion '/'];

        if ~exist(result_data_folder, 'dir')
            mkdir(result_data_folder)
        end
        
        
        for burst_ID = 1 : n
            
            if key_ID == 1
                adj_matrix = burst_ctv_maps.during_burst;
            end
            if key_ID == 2
                adj_matrix = burst_ctv_maps.pre_burst;
            end
            if key_ID == 3
                adj_matrix = burst_ctv_maps.post_burst;
            end

%             disp('plot histogram of connectivity matrix/connections')
%             fig = figure();
%             num_connections = size(adj_matrix, 1);
%             total_num_conn = num_connections*num_connections;
%             x = 0 : 0.1 : 1;
%             y = histc(adj_matrix(:), x);
%             y = y / total_num_conn;
%             bar(x, y);
%             title([keys{key_ID} ', number of connections: ' num2str(total_num_conn) ', threshold: ' str_thresholding_proportion]);


            %% thresholding the adjacency matrices
            thres_adjacency_matrix = threshold_proportional(adj_matrix, thresholding_proportion);
            disp('applying threshold to adjacency matrix')

            
            %% degree and similarity, methods: degree, strength
            if switch_degree_similarity

                disp('computing degree and similarity, methods: degree, strength')
                

                %weighted_adja_mat_iTW = squeeze(EEGNET_adjacency_matrix(i_time_window, :, :));

                % compute graph degree
                [~, ~, graph_degree(burst_ID,:)] = degrees_dir(thres_adjacency_matrix);


                % compute graph strength
                %graph_strength = strengths_und(weighted_adja_mat_iTW);
                [~, ~, graph_strength(burst_ID,:)] = strengths_dir(thres_adjacency_matrix);

                % save results

                % disp(['saving results to ' result_data_folder])
                % save([result_data_folder keys{key_ID} '_results_graph_degree_similarity.mat'], 'graph_degree', 'graph_strength', 'thresholding_proportion');

            end



            %% density and rentian scaling, methods: density

            if switch_density

                disp('computing density and rentian scaling, methods: density')
                

                % compute graph density
                graph_density(burst_ID) = density_dir(thres_adjacency_matrix);

                % save results
                % disp(['saving results to ' result_data_folder])

                % save([result_data_folder keys{key_ID} '_results_graph_density.mat'], 'graph_density', 'thresholding_proportion');

            end



            %% clustering and community structure, methods: clustering coefficient, local efficiency, global efficiency, modularity (classic)

            if switch_clustering_community_structure

                disp('computing clustering and community structure, methods: clustering coefficient, local efficiency, global efficiency, modularity (classic)')

                % compute graph clustering coefficient
                graph_clustering_coefficient(:,burst_ID) = clustering_coef_wd(thres_adjacency_matrix);


                % compute local efficiency
                graph_local_efficiency(:,burst_ID) = efficiency_wei(thres_adjacency_matrix, 2);


                % compute global efficiency
                graph_global_efficiency(burst_ID) = efficiency_wei(thres_adjacency_matrix, 0);


                % compute modularity (classic)
                graph_modularity(:,burst_ID) = modularity_dir(thres_adjacency_matrix, 1);


                % compute transitivity
                graph_transitivity(burst_ID) = transitivity_wd(thres_adjacency_matrix);

                % save results

                %disp(['saving results to ' result_data_folder])
                %save([result_data_folder keys{key_ID} '_results_graph_clustering_community_structure.mat'], 'graph_transitivity', 'graph_clustering_coefficient', 'graph_local_efficiency', 'graph_global_efficiency', 'graph_modularity', 'thresholding_proportion');

            end



            %% paths and distances, methods:

            % Not sure if it's relavent to functional connectivity...
            if switch_paths_distances

                %                 disp('computing  paths and distances, methods:')

                %                 graph_density_TW = [];

                %                 for i_time_window = 1 : size(EEGNET_adjacency_matrix, 1)

                %                     weighted_adja_mat_iTW = squeeze(EEGNET_adjacency_matrix(i_time_window, :, :));

                %                     thres_weighted_adja_mat_iTW = squeeze(thres_EEGNET_adjacency_matrix(i_time_window, :, :));

                %                     % compute graph density

                %                     graph_density = degrees_und(weighted_adja_mat_iTW);

                %                     graph_density_TW = [graph_density_TW; graph_density];

                %                 end

                %                 % save results

                %                 disp(['saving results to ' result_data_folder])

                %                 save([result_data_folder 'graph_paths_distances_results.mat'], 'graph_density_TW', 'thresholding_proportion');

            end



            %% efficiency and diffusion, methods:

            % Not sure if it's relavent to functional connectivity...

            if switch_efficiency_diffusion

                %                 disp('computing  efficiency and diffusion, methods:')

                %                 graph_density_TW = [];

                %                 for i_time_window = 1 : size(EEGNET_adjacency_matrix, 1)

                %                     weighted_adja_mat_iTW = squeeze(EEGNET_adjacency_matrix(i_time_window, :, :));

                %                     thres_weighted_adja_mat_iTW = squeeze(thres_EEGNET_adjacency_matrix(i_time_window, :, :));

                %                     % compute graph density

                %                     graph_density = degrees_und(weighted_adja_mat_iTW);

                %                     graph_density_TW = [graph_density_TW; graph_density];

                %                 end

                %                 % save results

                %                 disp(['saving results to ' result_data_folder])

                %                 save([result_data_folder 'graph_efficiency_diffusion_results.mat'], 'graph_density_TW', 'thresholding_proportion');

            end



            %% centrality, methods: betweenness centrality, eigenvector centrality

            if switch_centrality
                disp('computing centrality, methods: betweenness centrality, eigenvector centrality')
          

                % get connection length matrix
                conn_len_mat = 1 ./ thres_adjacency_matrix;

                % compute graph betweenness centrality
                graph_betweenness_centrality(:,burst_ID) = betweenness_wei(conn_len_mat);

                % compute graph edge betweenness centrality
                graph_edge_betweenness_centrality{burst_ID} = edge_betweenness_wei(thres_adjacency_matrix);

                % save results
                % disp(['saving results to ' result_data_folder])
                % save([result_data_folder keys{key_ID} '_results_graph_centrality.mat'], 'graph_betweenness_centrality', 'graph_edge_betweenness_centrality', 'thresholding_proportion');

            end

        end
        save([result_data_folder keys{key_ID} '_results_graph_degree_similarity.mat'], 'graph_degree', 'graph_strength', 'thresholding_proportion');
        save([result_data_folder keys{key_ID} '_results_graph_density.mat'], 'graph_density', 'thresholding_proportion');
        save([result_data_folder keys{key_ID} '_results_graph_clustering_community_structure.mat'], 'graph_transitivity', 'graph_clustering_coefficient', 'graph_local_efficiency', 'graph_global_efficiency', 'graph_modularity', 'thresholding_proportion');
        save([result_data_folder keys{key_ID} '_results_graph_centrality.mat'], 'graph_betweenness_centrality', 'graph_edge_betweenness_centrality', 'thresholding_proportion');
    end
end

