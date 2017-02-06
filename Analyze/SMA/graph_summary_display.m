function [] = graph_summary_display()

inDir = 'D:\Projects\Data\Vant\Figures\Manuscript\';
eDir = get_export_path_SMA();

load([inDir 'All Graphs.mat']);

% In data: rows = cond(sheets), cols = atype(files)


[ncond, natypes] = size(summary);
[nfreq,ndcol] = size(summary{1,1}.data);

for i=1:ncond
    for j=1:nfreq
        for k = 1:natypes
            plotdata(k,:) = summary{i,k}.data(j,1:2);
        end
        ratio(:,j,i) = plotdata(:,1)./plotdata(:,2);
%         plotdata(:,2) = plotdata(:,2)/sum(plotdata(:,2));
%         %plotdata(:,2) = abs((plotdata(:,2)-(57*56/2)))/(57*56/2);
%         bar(ratio');
%         axis([0 4 0 10]);
%         title(summary{i,k}.textdata(j+2,1));
    end
end

h = figure(1);
set(h, 'Name', 'Graph Summary');

for i=1:natypes
    pd = ratio(i,:,:);
    pd = reshape(pd, nfreq, ncond);
    subplot(2,2,i);
    bar(pd(:,1:(end-1)));
    switch i
        case 1
            axis([0 7 0 10]);
        otherwise
           axis([0 7 0 0.15]); 
    end
    title(atypes(i));
    legend('aloud', 'quiet', 'rest_eo');
end

save_figure(h,eDir, 'Graph Summary');
