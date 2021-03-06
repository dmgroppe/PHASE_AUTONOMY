% USAGE: [epochs, nchannel] = get_epochs(R)
%
%   Gets the raw epoch traces from the 'R' cell array.  Each cell contains
%   the data for a single channel.  MAy be different number of epochs per
%   channel
%
%   Input:  R - cell array of channel data
%   Output:
%       epochs:     Cell of matricies of epochs, and spectra
%       nchannel:   Number of channels processed
%
%   Copyright (C) Taufik A Valiante

function [epochs, num_channel] = get_epochs(R)

nfiles = size(R,2);
nchannel = size(R{1},2);

epochs = cell(1,nchannel);

for i=1:nchannel
    total_epochs = 0;
    for j=1:nfiles
        % Number of rows = number of epochs
        nepochs = size(R{j}(i).data,1);
        last_total = total_epochs;
        total_epochs = total_epochs + nepochs;
        epochs{i}.data((last_total+1):total_epochs,:) = R{j}(i).data;
        epochs{i}.padded_data((last_total+1):total_epochs,:) = R{j}(i).padded_data;
        epochs{i}.spectra(:,:,(last_total+1):total_epochs) = R{j}(i).spectra;
        
    end
end

% Return the number of channels is variable is passed
if (nargout == 2)
    num_channel = nchannel;
end