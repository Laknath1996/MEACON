function [xc1000] = spikes3( sp_data,bin_size,lag )

if ( ~exist( 'num_std' ) )
    num_std = 5;
end

if ( ~exist('sp_data') )
    load( sprintf( 'sp%d_data', num_std ) );
end

% define some useful parameters
overlap_window = bin_size*0.2;

%spiketrains 1ms bins - Bin spikes into 1ms bins
nchannels = size(sp_data,1);
maxlength = 599000; % window size in miliseconds (fixed atm)

sp=zeros(nchannels,maxlength); %no. of channels and samples
for i = 1:nchannels
    % disp(['i=' num2str(i)])
    spike_times = round(sp_data{i}*1000);  % convert to miliseconds             % better to round() than to ceil()
    for j = 1:length(spike_times)
       % disp(['j=' num2str(j)])
       % disp(spike_times(j))
       index = spike_times(j);
       if index == 0
           index = 1;
       end
      sp(i,index) = sp(i,index) + 1;  % account for double spikes
    end
end

%spiketrains 10ms bins - group them into 10ms bins, then add 2ms windows
%around edges and divide spikes in edges evenly - a bit bodgy but shouldn't
%effect the overall spike statistics - so basically 4-6-4ms, the first one
%is 2-6-4ms as there is no previous overlapping window

% sp1000=zeros(nchannels, maxlength/10);
% for i=1:maxlength/10
%     min_i = max( i*10-11, 1 );
%     max_i = min( i*10+2, 10000 );
%     sp1000(:,i) = sum( sp(:,i*10-7:i*10-2), 2 ) + ...
%                   0.5*sum( sp(:,[ min_i:i*10-8 i*10-1:max_i ]), 2 );
% end

sp1000=zeros(nchannels, maxlength/bin_size);
for i=1:maxlength/bin_size
    min_i = max( i*bin_size-(bin_size + 1), 1 );
    max_i = min( i*bin_size+(overlap_window), maxlength ); % check again about maxlength
    sp1000(:,i) = sum( sp(:,i*bin_size-(bin_size - overlap_window - 1):i*bin_size-overlap_window), 2 ) + ...
                  0.5*sum( sp(:,[ min_i:i*bin_size-(bin_size-overlap_window) i*bin_size-overlap_window+1:max_i ]), 2 );
end

xc_len = lag;  %This is the maximum lag as input into xcov in miliseconds
nodes = 1:nchannels;

% xc=cell(nchannels);
% for i = 1:length(nodes)
%   ChA = nodes(i);
%   disp( sprintf( 'Computing xc{%d,:}', ChA ) );    
%   for j = 1:length(nodes)
%       if i == j 
%           continue;
%       end
%       ChB = nodes(j);
%       xc{ChA,ChB} = xcov( sp(ChA,:), sp(ChB,:), xc_len );
%   end
% end

xc1000=cell(nchannels);
for i = 1:length(nodes)
  ChA = nodes(i);
  disp( sprintf( 'Computing xc1000{%d,:}', ChA ) );      
  for j = 1:length(nodes)
      if i == j 
          continue;
      end
      ChB = nodes(j);
      xc1000{ChA,ChB} = xcov( sp1000(ChA,:), sp1000(ChB,:), xc_len/bin_size,'coeff' );
  end
end

% save( sprintf( 'xc%d_data', num_std ), 'sp', 'sp1000', 'xc', 'xc1000' );

return;