% burst connectivity analysis

clear all;
close all;
cf = pwd;
%% get the spike_matrix and the respective NetworkBurst file

[spike_file,spike_path] = uigetfile('*.mat','Select the Spike Matrix File');
[netburst_file, netburst_path] = uigetfile('*.mat','Select the Network Burst File');
save_path = uigetdir('Select the save path');

%% get the parameters from the user
prompt = {'Enter Bin Size in ms','Enter Threshold','Enter the lag in ms'};
dlg_title = 'Input Parameters';
num_lines = 1;
def = {'10','0.3','100'};
answer = inputdlg(prompt,dlg_title,num_lines,def);
bin_size = str2double(char(answer{1}));
threshold = str2double(char(answer{2}));
lag = str2double(char(answer{3}));


%% load the .mat files

load(strcat(spike_path,'/',spike_file));
load(strcat(netburst_path,'/',netburst_file));

%% pick up the 10 longest bursts

netBursts = sortrows(netBursts,4,'descend'); % sort rows of the burst matrix in the descending order of burst durations
burst_start = netBursts(1:10,1); % get the starting samples of the bursts
burst_end = netBursts(1:10,2); % get the ending samples of the bursts
burst_dur = netBursts(1:10,4); % get the burst durations

%% iterate across the bursts and compute the connectivity matrices
lag_norm = lag / bin_size;
title = 'Connectivity Graph';
burst_ctv_maps = [];
for i = 1 : 10
    disp(sprintf('Analyzing burst %d',i));
    maxlength = ceil(burst_dur(i)/20000*1000);
    % during burst
    during_burst = spike_matrix(burst_start(i):burst_end(i), :);
    sp_data = GenerateSpikeTimesInNanoSecs(during_burst, 20000);
    xc_bin = spikes3_mod(sp_data,bin_size,lag,maxlength);
    adj_matrix = create_AdjMatrix(xc_bin,0,lag_norm);
    W_nrm = weight_conversion(adj_matrix, 'normalize');
    W_nrm(W_nrm < threshold) = 0;
    burst_ctv_maps(i).during_burst = W_nrm;
    h = graph_viz(W_nrm,title);
    cd(save_path);
    saveas(gcf,strcat(sprintf('during_burst_%d',i),'.jpg')); % uncomment if you need to save the figures
    close;
    cd(cf);
    
    % pre burst
    pre_burst = spike_matrix(burst_start(i)-burst_dur(i)-1:burst_start(i), :);
    sp_data = GenerateSpikeTimesInNanoSecs(pre_burst, 20000);
    xc_bin = spikes3_mod(sp_data,bin_size,lag,maxlength);
    adj_matrix = create_AdjMatrix(xc_bin,0,lag_norm);
    W_nrm = weight_conversion(adj_matrix, 'normalize');
    W_nrm(W_nrm < threshold) = 0;
    burst_ctv_maps(i).pre_burst = W_nrm;
    h = graph_viz(W_nrm,title);
    cd(save_path);
    saveas(gcf,strcat(sprintf('pre_burst_%d',i),'.jpg')); % uncomment if you need to save the figures
    close;
    cd(cf);
    
    % post burst
    post_burst = spike_matrix(burst_end(i):burst_end(i)+burst_dur(i)+1, :);
    sp_data = GenerateSpikeTimesInNanoSecs(post_burst, 20000);
    xc_bin = spikes3_mod(sp_data,bin_size,lag,maxlength);
    adj_matrix = create_AdjMatrix(xc_bin,threshold,lag_norm);
    W_nrm = weight_conversion(adj_matrix, 'normalize');
    W_nrm(W_nrm < threshold) = 0;
    burst_ctv_maps(i).post_burst = W_nrm;
    h = graph_viz(W_nrm,title);
    cd(save_path);
    saveas(gcf,strcat(sprintf('post_burst_%d',i),'.jpg')); % uncomment if you need to save the figures
    close;
    cd(cf);
end
   
cd(save_path);
save('bursts_analysis_results.mat','burst_ctv_maps');
cd(cf);


