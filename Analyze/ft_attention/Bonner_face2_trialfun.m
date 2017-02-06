function [trl cfg] = Bonner_face2_trialfun(cfg)

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

cfg.faces = [2 3 9 10 13 16 20 22 25 28 31 32 38 40 43 46 49 51 56 58 62 63 68 70 73 75 79 80 87 88 92 93 97 100 103 104 109 111 115 117];
cfg.scenes = [1 4 7 8 14 15 19 21 26 27 33 34 37 39 44 45 50 52 55 57 61 64 67 69 74 76 81 82 85 86 91 94 98 99 105 106 110 112 116 118];        
cfg.exl = [2 3 8 14 15 36 38 45 51 64 65 68 69 76 81 86 95 120];

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




