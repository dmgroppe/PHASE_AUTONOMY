function get_clinical_onset(sub,day,szr)

if ismac,
    in_path='/Users/dgroppe/Desktop/Dropbox/TWH_INFO/ONSET_TIMES_CLINICAL/';
else
    error('Taufik, you need to specify the path to the onset files.');
end

in_fname=fullfile(in_path,[sub '_clinical_onset_offset.csv']);
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
elseif szr_id<0,
    warning('Clinical onset time is uncertain for %s_d%d_sz%d\n', ...
        sub,day,szr);
end

fprintf('Found it!\n');
disp(szr_id);