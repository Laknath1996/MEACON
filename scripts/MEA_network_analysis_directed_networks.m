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

connecitivy_matrix_path = uigetdir('Select the Connectivity Matrix Path')

% parameter string/data folder name

base_result_data_folder = [connecitivy_matrix_path '/network_analysis_results/'];

if ~exist(base_result_data_folder, 'dir')
    mkdir(base_result_data_folder);
end

%% experiment list


% experiment list

experiment_list = {'mutant1', 'mutant2', 'mutant3', 'mutant4', 'mutant5', 'mutant6', 'wildtype1', 'wildtype2', 'wildtype3', 'wildtype4', 'wildtype5', 'wildtype6'};


%% network analysis parameters


% thresholding proportion

threshold_list = [1.00, 0.05, 0.10, 0.15];



% graph analysis measure switchs

switch_degree_similarity = 1; % degree and similarity

switch_density = 1; % density and rentian scaling

switch_clustering_community_structure = 1; % clustering and community structure

switch_paths_distances = 0; % not applicable to functional networks

switch_efficiency_diffusion = 0; % not applicable to functional networks

switch_centrality = 1;




%% network analysis
% cycle through experiments



for selector_experiment = 1 : length(experiment_list)
    
    experiment_ID = experiment_list{selector_experiment};
    
    disp(['Experiment: ' experiment_ID])
    
    
    %% load connectivity matrix
    
    disp('loading connectivity matrix...')
    
    load([connecitivy_matrix_path '/' experiment_ID '_results.mat']);
    
    disp('connectivity matrix loaded.')
    

    % cycle through different thresholds
    
    for selector_threshold = 1 : length(threshold_list)
        
        % get a threhold
        
        thresholding_proportion = threshold_list(selector_threshold);
        
        if thresholding_proportion == 1
            
            str_thresholding_proportion = '100';
            
        else
            
            str_thresholding_proportion = num2str(thresholding_proportion);
            
        end
        
        disp(['Using threshold: ' str_thresholding_proportion '.']);
        
        %% create result folder to save data
        
        result_data_folder = [base_result_data_folder experiment_ID '/' str_thresholding_proportion '/'];
        
        if ~exist(result_data_folder, 'dir')
            mkdir(result_data_folder)
        end
        
        %% check connection distributions before applying thresholding
        
        disp('plot histogram of connectivity matrix/connections')
        
        fig = figure();
        
        num_connections = size(adj_matrix, 1);
        
        total_num_conn = num_connections*num_connections;
        
        x = 0 : 0.1 : 1;
        
        y = histc(adj_matrix(:), x);
        
        y = y / total_num_conn;
        
        bar(x, y);
        
        title([experiment_ID ', number of connections: ' num2str(total_num_conn) ', threshold: ' str_thresholding_proportion]);
        
        
        %% thresholding the adjacency matrices
        
        thres_adjacency_matrix = threshold_proportional(adj_matrix, thresholding_proportion);
        
        disp('applying threshold to adjacency matrix')
        
        %% degree and similarity, methods: degree, strength
        
        if switch_degree_similarity
            
            disp('computing degree and similarity, methods: degree, strength')
            
            graph_degree = [];
            
            graph_strength = [];
            
            
            
            %weighted_adja_mat_iTW = squeeze(EEGNET_adjacency_matrix(i_time_window, :, :));
            
            
            
            % compute graph degree
            
            [~, ~, graph_degree] = degrees_dir(thres_adjacency_matrix);
            
            
            
            % compute graph strength
            
            %graph_strength = strengths_und(weighted_adja_mat_iTW);
            
            [~, ~, graph_strength] = strengths_dir(thres_adjacency_matrix);
            
            
            % save results
            
            disp(['saving results to ' result_data_folder])
            
            save([result_data_folder experiment_ID '_results_graph_degree_similarity.mat'], 'graph_degree', 'graph_strength', 'thresholding_proportion');
            
        end
        
        
        
        %% density and rentian scaling, methods: density
        
        if switch_density
            
            disp('computing density and rentian scaling, methods: density')
            
            graph_density = [];
            
            % compute graph density
            
            graph_density = density_dir(thres_adjacency_matrix);
            
            % save results
            
            disp(['saving results to ' result_data_folder])
            
            save([result_data_folder experiment_ID '_results_graph_density.mat'], 'graph_density', 'thresholding_proportion');
            
        end
        
        
        
        %% clustering and community structure, methods: clustering coefficient, local efficiency, global efficiency, modularity (classic)
        
        if switch_clustering_community_structure
            
            disp('computing clustering and community structure, methods: clustering coefficient, local efficiency, global efficiency, modularity (classic)')
            
            graph_clustering_coefficient = [];
            
            graph_local_efficiency = [];
            
            graph_global_efficiency = [];
            
            graph_modularity = [];
            
            graph_transitivity = [];
            
            
            % compute graph clustering coefficient
            graph_clustering_coefficient = clustering_coef_wd(thres_adjacency_matrix);
            
            
            % compute local efficiency
            
            graph_local_efficiency = efficiency_wei(thres_adjacency_matrix, 2);
            
            
            % compute global efficiency
            
            graph_global_efficiency = efficiency_wei(thres_adjacency_matrix, 0);
            
            
            % compute modularity (classic)
            
            graph_modularity = modularity_dir(thres_adjacency_matrix, 1);
            
            
            % compute transitivity
            graph_transitivity = transitivity_wd(thres_adjacency_matrix);
            
            % save results
            
            disp(['saving results to ' result_data_folder])
            
            save([result_data_folder experiment_ID '_results_graph_clustering_community_structure.mat'], 'graph_transitivity', 'graph_clustering_coefficient', 'graph_local_efficiency', 'graph_global_efficiency', 'graph_modularity', 'thresholding_proportion');
            
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
            
            graph_betweenness_centrality = [];
            
            graph_edge_betweenness_centrality = [];
            
            
            
            % get connection length matrix
            
            conn_len_mat = 1 ./ thres_adjacency_matrix;
            
            % compute graph betweenness centrality
            
            graph_betweenness_centrality = betweenness_wei(conn_len_mat);
            
            
            
            % compute graph edge betweenness centrality
            
            graph_edge_betweenness_centrality = edge_betweenness_wei(thres_adjacency_matrix);
            
            
            
            % save results
            
            disp(['saving results to ' result_data_folder])
            
            save([result_data_folder experiment_ID '_results_graph_centrality.mat'], 'graph_betweenness_centrality', 'graph_edge_betweenness_centrality', 'thresholding_proportion');
            
        end
        
    end
    
end

