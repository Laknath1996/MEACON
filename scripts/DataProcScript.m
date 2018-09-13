clear all;
close all;

%% define some useful parameters
Fs = 20000; % sampling freuency
cf = pwd; % current folder path

%% get the file and path name from the user
path = uigetdir('Select the folder with spike matrices');
save_path = uigetdir('Select the folder to save the spike matrices');

%% get the input parameters from the user
prompt = {'Enter Bin Size in ms','Enter Threshold','Enter Window Size in s','Enter the lag in ms'};
dlg_title = 'Input Parameters';
num_lines = 1;
def = {'10','5','0,599','100'};
answer = inputdlg(prompt,dlg_title,num_lines,def);
bin_size = str2double(char(answer{1}));
threshold = str2double(char(answer{2}));
window = str2double(strsplit(char(answer{3}),','));
lag = str2double(char(answer{4}));

%% get the names of the .mat files
folder_contents = dir(path);
names = {};
for i = 1 : numel(folder_contents)
    names{end+1} = char(folder_contents(i).name);
end
names = names(3:end);

% define the window
window = [max(1,window(1)*Fs) window(2)*Fs];


%% iterate through the .mat files
for i = 1:numel(names)
    name = names{i};
    name = strsplit(name,'.');
    name = char(name{1});

    disp(strcat('Analysing_',name,'...'));
    
    % load the file
    load(strcat(path,'/',name));

    % select the specified window
    
    %spike_matrix = full(spike_matrix);
    spike_matrix = spike_matrix(window(1):window(2), :);

    sp_data = GenerateSpikeTimesInNanoSecs(spike_matrix, 20000); % spike_matrix is the data Mark provided. Sampling rate = 20,000 Hz. Alan wrote this function to generate the data in the form that is required by the MIT spikes3.m function.
    % sp_data = sp_data(1:25,:); % This line should be commented out to run the full data set. Alan reduced the 120 channels of data to 25 to quickly confirm that it works.
    xc_bin = spikes3(sp_data,bin_size,lag); % A quickly modified version of the MIT spikes3.m function.
    % Data is stored in 'xc5_data.mat'. Load it to review the results.
    
    %% create the adjacency matrix and plot the graph
    lag_norm = lag / bin_size;
    adj_matrix = create_AdjMatrix(xc_bin,threshold,lag_norm);
    title = strcat('connectivity_graph_',name);
    h = graph_viz(adj_matrix,title);
    
    %% compute the graph parameters (avg path length, clustering
    % coefficient)
    W_nrm = weight_conversion(adj_matrix, 'normalize');
    graph_params.avg_clustering_coeff = mean(clustering_coef_wd(W_nrm));
    
    % compute the distance matrix
    % dist_M = distance_wei(inv);
    
    %% save the results and graphs
    save_name = strcat(name,'_','results');
    cd(save_path);
    save(save_name, 'adj_matrix','xc_bin','graph_params');
    saveas(gcf,strcat(title,'.jpg')); % uncomment if you need to save the figures
    close;
    cd(cf);
end
