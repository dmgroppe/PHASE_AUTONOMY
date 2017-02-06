exp_info.test = 'enc';
exp_info.anat_loc = 'HP';
exp_info.analysis = 'ps';               % 'tf', 'comod', 'ps'
exp_info.pschannels = {'HP'; 'EC'};
exp_info.incl_pl_calcs = 1;
exp_info.tfshow = 'pl';

if(strcmp(exp_info.test, 'enc'))
    exp_info.cond1 = 'sH';
    exp_info.cond2 = 'R';
else
    exp_info.cond1 = 'Hits';
    exp_info.cond2 = 'CR';
end


exp_info
exp_info.pschannels(:)
if (continue_prompt())
    scene_stats(exp_info);
end