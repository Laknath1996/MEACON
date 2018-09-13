function sp_data = GenerateSpikeTimesInNanoSecs(data, Fs)
% 'data' is an n by 120 channel array data. It contains ones and zeros,
% where ones correspond to the occurrrence of spikes.
% 'Fs' is the sampling rate. That is, the time interval between the
% elements of 'data' is 1/Fs.
t_interval = 1/Fs; % Fs = 20,000 Hz, so t_interval = 50 ns.
nchannels = size(data,2); % 120 channels of data.

sp_data = cell(nchannels,1);
for n = 1:nchannels
    Index = find(data(:,n) == 1);
    sp_data{n} = Index * t_interval;
end