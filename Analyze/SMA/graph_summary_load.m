function [] = graph_summary_load()

sheets = {'Aloud', 'Quiet', 'EO', 'EC'};
inDir = 'D:\Projects\Data\Vant\Figures\Manuscript\';
filenames = {'IC Graph summary',...
             'PC Graph summary'...
             'Corr Graph summary'};
atypes = {'ic', 'pc', 'corr'};
conds = {'aloud', 'quiet', 'rest_eo', 'rest_ec'};
         

nfiles = size(filenames, 2);
nsheets = size(sheets, 2);

for i=1:nfiles
    for j=1:nsheets
        summary{j,i} = graph_summary_import([inDir filenames{i} '.xlsx'], sheets{j});
    end
end

save([inDir 'All Graphs.mat'], 'summary', 'conds', 'atypes');