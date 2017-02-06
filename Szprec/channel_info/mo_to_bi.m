clear all
close all
clc
fnames = dir(fullfile('/home/ymei/EEG_raw/IM/*.txt'));
numfids = length(fnames);
group_end_index=[64 68 72 76 80 88 96];
for K = 1:numfids
    fileID = fopen(fullfile('/home/ymei/EEG_raw/IM/',fnames(K).name));
    [path, name, extension] = fileparts(fnames(K).name);
    load(['/home/ymei/EEG_raw/IM/mo/' name '_original.mat']);
    name
   
    B = circshift(matrix_mo,[0,-1]);
    matrix_bi=matrix_mo-B;
    %matrix_bi(:,group_end_index(end)+1:end)=[];
    matrix_bi(:,group_end_index)=[];
    output_name = ['/home/ymei/EEG_raw/IM/bi/', name, '.mat'];
    save(output_name,'matrix_mo','matrix_bi','Sf');
end