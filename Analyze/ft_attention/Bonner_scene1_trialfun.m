function [trl cfg] = Bonner_scene1_trialfun(~)

cfg = [];
fn = 'D:\Projects\Data\Attention\Bonner\Scene1 tags.txt';
display('Loading tag file - Scene1 tags.txt');
tags = load_tags(fn);

cfg.tagfile = fn;
cfg.dataset = 'D:\Projects\Data\Attention\Bonner\Scene1 BP 0.1 250 Dec500.cnt';
hdr = ft_read_header(cfg.dataset);

cfg.trialdef.prestim = .2; % In s
cfg.trialdef.poststim = .8; % In s;

% There are two channels in this so just loop over half to get the triggers
trl = [];

faces = [1 2 7 9 13 16 21 22 25 27 32 34 37 38 45 46 49 51 55 57 62 64 68 69 74 76 80 81 86 88 91 92 99 100 104 105 110 111 115 116];
scenes = [3 4 8 10 14 15 19 20 26 28 31 33 39 40 43 44 50 52 56 58 61 63 67 70 73 75 79 82 85 87 93 94 97 98 103 106 109 112 117 118];        

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




