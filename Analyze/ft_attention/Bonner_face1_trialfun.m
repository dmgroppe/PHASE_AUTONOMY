function [trl cfg] = Bonner_face1_trialfun(cfg)

if ~isfield(cfg, 'trialdef'), error('you must specify trialdefs'); end

% Load the header and the data
cfg.dataset = 'D:\Projects\Data\Attention\Bonner\Face1 BP 0.1 250 Dec500.cnt';
% cfg.datafile = 'D:\Projects\Data\Attention\Bonner\Face1 BP 0.1 250 Dec500.cnt';
% cfg.headerfile = 'D:\Projects\Data\Attention\Bonner\Face1 BP 0.1 250 Dec500.cnt';

hdr = ft_read_header(cfg.dataset);
data = ft_read_data(cfg.dataset);

% Detect the triggers
event = vft_get_triggers(data(end,:));

cfg.srate = hdr.Fs;

% There are two channels in this so just loop over half to get the triggers
trl = [];

cfg.faces = [1 3 7 9 15 16 19 22 26 28 31 34 39 40 44 45 50 52 56 57 62 63 68 70 75 76 81 82 85 86 92 93 97 98 103 105 109 110 115 116];        
cfg.scenes = [2 4 8 10 13 14 20 21 25 27 32 33 37 38 43 46 49 51 55 58 61 64 67 69 73 74 79 80 87 88 91 94 99 100 104 106 111 112 117 118];
cfg.exl = [17 23 24 51 52 53 58 64 83 102 107 117 118];

nevent = length(event);
stim_type = zeros(1,nevent);
stim_type(cfg.faces) = 1;  % 1 for faces
stim_type(cfg.scenes) = 2; % 2 for scences

for i=1:nevent
    begsample = event(i) - cfg.trialdef.prestim*hdr.Fs;
    endsample = event(i) + cfg.trialdef.poststim*hdr.Fs;
    offset        = -cfg.trialdef.prestim*hdr.Fs;
    trigger = event(i);
    %trl(end+1, :) = [round([begsample endsample offset])  trigger stim_type(i)]; 
    trl(end+1, :) = [round([begsample endsample offset]) trigger stim_type(i)];
end




