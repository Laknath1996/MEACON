function plot_xc( nodelist, xc_len, threshold, num_std, fig )
% nodelist is a 5-digit integer [row1|row2|row3|row4|row5] that plots rowX
% if rowX is non-zero; or a list of nodes [ node1 node2 ... ] e.g. 25:64
% if not specified, 11 nodes from first and last row will be plotted.
% can pass [] or omit other params to use default values.

if (~exist('fig') || isempty(fig) )
    fig = 570;
end
figure(fig); clf; set(fig,'DoubleBuffer','on') %Flash-free rendering

if (~exist('num_std') || isempty(num_std) )
    num_std = 5;
end
load( sprintf( 'xc%d_data', num_std ) );

if (~exist('threshold') || isempty(threshold) )
    threshold = 4;
end

if (~exist('xc_len') || isempty(xc_len) )
    xc_len = 50;
end
xc1000_len = xc_len/10;

noderow{1} = [ 25 26 27 30 31 ];
noderow{2} = [ 35 36 ];
noderow{3} = [ 41 43 44 46 ];
noderow{4} = [ 49 50 51 52 54 ];
noderow{5} = [ 57 58 59 60 63 64 ];
if ( exist('nodelist') && length(nodelist) )    % exists and non-empty
    if ( length(nodelist) == 1 )
        nodes = [];
        for i = 1:5
            if ( mod( floor(nodelist/10^(5-i)), 10) )
                nodes = [ nodes noderow{i} ];
            end
        end
    else
        nodes = nodelist;
    end
else
    nodes = [ noderow{1} noderow{5} ];
end

clear channel_pairs;
k = 0;
for i = 1:length(nodes)-1
  ChA = nodes(i);
  for j = i+1:length(nodes)
      ChB = nodes(j);
      k = k + 1;
      channel_pairs( k, 1 ) = ChA;
      channel_pairs( k, 2 ) = ChB;      
  end
end
channel_pairs = sortrows( channel_pairs );

nRows = round( sqrt(length(channel_pairs)) );
nCols = ceil( sqrt(length(channel_pairs)) );

for pair = 1:size(channel_pairs,1)
        subplot( nRows, nCols, pair )
        ChA = channel_pairs( pair, 1 );
        ChB = channel_pairs( pair, 2 );
        my_xc = xc{ChA,ChB}; 
        my_xc_len = floor( length(my_xc)/2 );
        my_xc = my_xc( my_xc_len+1-xc_len : my_xc_len+1+xc_len );   % get only the window that we want
        my_xc( xc_len-1 : xc_len+3 ) = 0;                   % zero out the 5 values around lag=0
        plot( -xc_len:xc_len, my_xc, 'b.-' ); hold on;

        my_xc = xc1000{ChA,ChB};
        my_xc_len = floor( length(my_xc)/2 );
        my_xc = my_xc( my_xc_len+1-xc1000_len : my_xc_len+1+xc1000_len );
        my_xc( xc1000_len : xc1000_len+2 ) = 0;             % zero out the 3 values around lag=0
        plot( 10*(-xc1000_len:xc1000_len), my_xc, 'g.-' );
        
        axis tight;
        AX = axis;
        plot( [AX(1) AX(2)], [threshold threshold], 'r' );
        [maxL,maxLi] = max( my_xc(1:xc1000_len) );
        [maxR,maxRi] = max( my_xc(xc1000_len+2:end) );
        if ( maxL > threshold )
            plot( [AX(1) AX(1)], [AX(3) AX(4)], 'm', 'linewidth', 6 );
        end
        if ( maxR > threshold )
            plot( [AX(2) AX(2)], [AX(3) AX(4)], 'm', 'linewidth', 6 );
        end
        tx = text( 0.7*AX(1)+0.3*AX(2), 0.1*AX(3)+0.9*AX(4), ...
           sprintf( 'xc(%d,%d)', ChA, ChB ) );

        set( tx, 'fontsize', 10, 'fontweight', 'bold' );
        drawnow;
end

return;