function [trl cfg] = Bonner_passive1_trialfun(~)

cfg = [];
fn = 'D:\Projects\Data\Attention\Bonner\Passive1 tags.txt';
display('Loading tag file - Passive1 tags.txt');
tags = load_tags(fn);

cfg.tagfile = fn;
cfg.dataset = 'D:\Projects\Data\Attention\Bonner\Passive1 BP 0.1 250 Dec500.cnt';
hdr = ft_read_header(cfg.dataset);

cfg.trialdef.prestim = .2; % In s
cfg.trialdef.poststim = .8; % In s;

% There are two channels in this so just loop over half to get the triggers
trl = [];

faces = [1 2 7 8 15 16 19 21 26 27 32 34 37 39 43 46 49 50 57 58 62 64 68 69 74 76 80 81 86 88 93 94 97 99 103 106 109 111 115 118];
scenes = [3 4 9 10 13 14 20 22 25 28 31 33 38 40 44 45 51 52 55 56 61 63 67 70 73 75 79 82 85 87 91 92 98 100 104 105 110 112 116 117];        

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




