function [EEG] = EEG_to_connectome(EEGin, ptname, cond)

ap = sync_params();

switch ptname
    case 'vant'
        channels = [60 8 16 49];
        EEG.labels{1} = 'SMA';
        EEG.labels{2} = 'FMC1';
        EEG.labels{3} = 'FMC2';
        EEG.labels{4} = 'MTG';
    case 'nourse'
        channels = [4 5 8 16];
        EEG.labels{1} = 'B2';
        EEG.labels{2} = 'B1';
        EEG.labels{3} = 'FMC1';
        EEG.labels{4} = 'FMC2';
end
       

[tstart tend] = get_trange(cond, ap.length, ptname);
subr = get_subregion(EEGin, tstart, tend);

% remove the unwanted channels;
subr = subr(channels,:);
[nchan, npoints] = size(subr);

% Normalize by, removing <1Hz oscillaions, subtracting mean and normalizing
% by the variance

% d = window_FIR(0.0001, 2, EEGin.srate);
% N = d.Numerator;
% display('Filtering the time series to remove < 2 Hz drifts');
% parfor i=1:nchan
%     xfilt(i,:) = filtfilt(N,1,subr(i,:));
% end
xfilt = subr;
means = mean(xfilt,2);
means = repmat(means, 1, npoints);
xfilt = xfilt - means;
stds = std(xfilt,1,2);
stds = repmat(stds, 1, npoints);
xfilt = xfilt./stds;


%ntrials = fix(npoints/tsize);
% bs = zeros(tsize,nchan,ntrials);
% 
% for i=1:nchan
%     for j = 1:ntrials
%         dstart = (j-1)*tsize+1;
%         dend = j*tsize;
%         bs(:,i,j) = subr(i,dstart:dend);
%     end
% end

EEG.name = sprintf('%s %s', upper(ptname), upper(cond));
EEG.type = 'ECOG';
EEG.nbchan = nchan;
EEG.points = npoints;
EEG.srate = EEGin.srate;
EEG.labeltype = 'customized';

% for i=1:nchan
%     if (max(i ~= chtoexl) == 0)
%         EEG.labels{i} = sprintf('%d',i);
%     end
% end

EEG.data = xfilt;

locs = [-6.416393 	-2.349331 	 70.829765 
-46.446080 	-9.622824 	 55.205412 
-35.365557 	7.514674 	 57.960555 
-63.715915 	-9.476447 	 -3.752021];

for i=1:4
    EEG.locations(i).X = locs(i,1);
    EEG.locations(i).Y = locs(i,2);
    EEG.locations(i).Z = locs(i,3);
end

EEG.marks = [0.0771   82.4618  -22.3071
  -75.3947  -11.9550  -38.2822
   74.4050  -11.7866  -37.1746];

% Make the locations
% count = 0;
% for i=1:8
%     for j=1:8
%         count = count + 1;
%         if count <= nchan;
%             EEG.locations(count).X = (i-1)*6;
%             EEG.locations(count).Y = (j-1)*6;
%             EEG.locations.(count).Z = 0;
%         end
%     end
% end

EEG.unit = 'uV';
EEG.size = [2 2];
EEG.vidx = 1:4;
EEG.bad = [];
EEG.start = 1;
EEG.end = 1;
EEG.dispchans = 1;
EEG.min = min(min(subr));
EEG.max = max(max(subr));

ECOG = EEG;

[outDir] = DTF_dir(ptname);
fname = sprintf('DTF Data %s %s.mat', upper(ptname), upper(cond));
save([outDir fname], 'ECOG');
        


