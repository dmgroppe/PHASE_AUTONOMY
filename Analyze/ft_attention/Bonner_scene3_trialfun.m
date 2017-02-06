function [trl cfg] = Bonner_scene3_trialfun(~)

cfg = [];
fn = 'D:\Projects\Data\Attention\Bonner\Scene3 tags.txt';
display('Loading tag file - Scene3 tags.txt');
tags = load_tags(fn);

cfg.tagfile = fn;
cfg.dataset = 'D:\Projects\Data\Attention\Bonner\Scene3 BP 0.1 250 Dec500.cnt';
hdr = ft_read_header(cfg.dataset);

cfg.trialdef.prestim = .2; % In s
cfg.trialdef.poststim = .8; % In s;

% There are two channels in this so just loop over half to get the triggers
trl = [];

faces = [1 2 7 9 15 16 21 22 25 26 31 34 38 39 43 44 50 52 55 57 61 64 69 70 73 76 81 82 86 87 92 94 97 99 104 106 109 112 115 116];
scenes = [3 4 8 10 13 14 19 20 27 28 32 33 37 40 45 46 49 51 56 58 62 63 67 68 74 75 79 80 85 88 91 93 98 100 103 105 110 111 117 118];        

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




