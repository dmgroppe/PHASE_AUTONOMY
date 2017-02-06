function [trl cfg] = Bonner_passive2_trialfun(~)

cfg = [];
fn = 'D:\Projects\Data\Attention\Bonner\Passive2 tags.txt';
display('Loading tag file - Passive2 tags.txt');
tags = load_tags(fn);

cfg.tagfile = fn;
cfg.dataset = 'D:\Projects\Data\Attention\Bonner\Passive2 BP 0.1 250 Dec500.cnt';
hdr = ft_read_header(cfg.dataset);

cfg.trialdef.prestim = .2; % In s
cfg.trialdef.poststim = .8; % In s;

% There are two channels in this so just loop over half to get the triggers
trl = [];

faces = [1 4 7 8 14 15 20 22 25 26 33 34 38 39 43 46 49 50 55 57 62 63 68 70 73 75 81 82 86 87 91 93 99 100 103 106 110 112 115 116];
scenes = [2 3 9 10 13 16 19 21 27 28 31 32 37 40 44 45 51 52 56 58 61 64 67 69 74 76 79 80 85 88 92 94 97 98 104 105 109 111 117 118];        

stim_type = zeros(1,numel(tags)/2);
stim_type(faces) = 1;  % 1 for faces
stim_type(scenes) = 2; % 2 for scences

for i=1:numel(tags)/2
    begsample = tags{i}.limits(1)/1000*hdr.Fs - cfg.trialdef.prestim*hdr.Fs;
    endsample = tags{i}.limits(1)/1000*hdr.Fs + cfg.trialdef.poststim*hdr.Fs;
    offset        = -cfg.trialdef.prestim*hdr.Fs;
    trigger = tags{i}.limits(1)/1000*hdr.Fs;
    trl(end+1, :) = [round([begsample endsample offset])  trigger stim_type(i)]; 
end




