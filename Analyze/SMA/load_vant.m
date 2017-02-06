function [EEG] = load_vant()

global DATA_PATH;

if isempty(DATA_PATH)
    fpath = 'D:\Projects\Data\Vant\EEG1kcf_180notch.mat';
else
    fpath = [DATA_PATH 'Vant\EEG1kcf_180notch.mat'];
    
end

if exist(fpath, 'file')
    load(fpath);
    EEG = eval('EEG1kcf_180notch');
else
    display('Data file can not be found.');
    EEG = [];
end