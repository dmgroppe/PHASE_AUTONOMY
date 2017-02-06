function [trl cfg] = Bonner_scene2_trialfun(~)

cfg = [];
fn = 'D:\Projects\Data\Attention\Bonner\Scene2 tags.txt';
display('Loading tag file - Scene2 tags.txt');
tags = load_tags(fn);

cfg.tagfile = fn;
cfg.dataset = 'D:\Projects\Data\Attention\Bonner\Scene2 BP 0.1 250 Dec500.cnt';
hdr = ft_read_header(cfg.dataset);

cfg.trialdef.prestim = .2; % In s
cfg.trialdef.poststim = .8; % In s;

% There are two channels in this so just loop over half to get the triggers
trl = [];

faces = [3 4 7 8 13 15 20 22 27 28 31 33 37 40 44 45 50 51 56 57 62 64 67 69 73 76 79 82 85 88 91 92 97 99 103 104 110 112 116 118];
scenes = [1 2 9 10 14 16 19 21 25 26 32 34 38 39 43 46 49 52 55 58 61 63 68 70 74 75 80 81 86 87 93 94 98 100 105 106 109 111 115 117];        

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




