% custom plot

clear all;
close all;
cf = pwd;

%% get the file and path name from the user
path = uigetdir('Select the folder with adjacency matrices');
save_path = uigetdir('Select the folder to save the graphs');
prompt = {'Enter Weight Threshold'};
dlg_title = 'Weight Threshold';
num_lines = 1;
def = {'0.5'};
answer = inputdlg(prompt,dlg_title,num_lines,def);
threshold = str2double(char(answer));

%% get the names of the .mat files
folder_contents = dir(path);
names = {};
for i = 1 : numel(folder_contents)
    names{end+1} = char(folder_contents(i).name);
end
names = names(3:end);

%% iterate through the .mat files
for i = 1:numel(names)
    name = names{i};
    name = strsplit(name,'.');
    name = char(name{1});

     % load the file
    load(strcat(path,'/',name));
    
    % normalize the matrix
    %W_nrm = weight_conversion(adj_matrix, 'normalize');
    
    %W_nrm(W_nrm < threshold) = 0;
    W_nrm = threshold_proportional(adj_matrix, threshold);
    
    % plot the graph
    h = graph_viz(W_nrm,name);
    
    %% save the results and graphs
    % save_name = strcat(name,'_','results');
    cd(save_path);
    % save(save_name, 'adj_matrix','xc_bin','graph_params');
    saveas(gcf,strcat(name,'.jpg')); % uncomment if you need to save the figures
    close;
    cd(cf);
end
