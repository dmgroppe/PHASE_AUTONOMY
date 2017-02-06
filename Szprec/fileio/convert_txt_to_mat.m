clear all 
close all
clc
fnames = dir(fullfile('/home/ymei/EEG_raw/RO/*.txt'));
numfids = length(fnames);
% vals = cell(1,numfids);
for K = 1:numfids
    fnames(K).name
    fileID = fopen(fullfile('/home/ymei/EEG_raw/RO/',fnames(K).name));
    numberofheaderlines=9;% hea
    channelnumbers=122;
    format = ['%*s%*s%*s' repmat('%s', [1 channelnumbers]) '%*[^\n]'];
    c = textscan(fileID,format,'HeaderLines', numberofheaderlines);
    temp=c{1,1};
    matrix_mo=zeros(size(temp),channelnumbers);
    tempname=strrep(fnames(K).name,'.txt','');
    for i=1:channelnumbers    
        mono=c{1,i};
        matrix_mo(:,i)=str2double(mono);
    end
    fclose(fileID);
    
    fileID = fopen(fullfile('/home/ymei/EEG_raw/RO/',fnames(K).name));
    format = ['%s%s%s' repmat('%f', [1 1]) '%*[^\n]'];
    Sf = textscan(fileID,format,'HeaderLines', 1);
    Sf = Sf{4}(1)
    fclose(fileID);   
    save(fullfile('/home/ymei/EEG_raw/RO/',[tempname '_original.mat']),'Sf','matrix_mo');
%     clear matrix_mo;
%     clear Sf;
end

