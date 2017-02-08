function [onset_tpt, onset_tpt_bnd]=get_clinical_onset(sub,day,szr)
%function [onset_tpt, onset_tpt_bnd]=get_clinical_onset(sub,day,szr)
%
% Author: DG

global ONSET_DIR;

if isempty(ONSET_DIR)
    error('You need define global var ONSET_DIR where clinical onset csv files are stored.');
end


in_fname=fullfile(ONSET_DIR,[sub '_clinical_onset_offset.csv']);
csv=csv2Cell_phase_aut(in_fname,',',1);

n_szrs=size(csv,1);
szr_id=NaN;
for a=1:n_szrs,
    if str2num(csv{a,1})==day && str2num(csv{a,2})==szr,
        szr_id=a;
        break;
    end
end

if isnan(szr_id),
    warning('Could not find a clinical onset time entry for %s_d%d_sz%d\n', ...
        sub,day,szr);
    onset_tpt=NaN;
elseif isempty(csv{szr_id,12})
    warning('Could not find a clinical onset time entry for %s_d%d_sz%d\n', ...
        sub,day,szr);
    onset_tpt=NaN;
else
    onset_tpt=str2num(csv{szr_id,12})+1;
    if onset_tpt<0;
        warning('Negative clinical onset time entry for %s_d%d_sz%d\n', ...
            sub,day,szr);
        onset_tpt=NaN;
    end
end

if isnan(onset_tpt)
    onset_tpt_bnd=[NaN, NaN];
else
    fs=str2num(csv{szr_id,8});
    onset_tpt_bnd=onset_tpt+[-1, 1]*fs;
end

