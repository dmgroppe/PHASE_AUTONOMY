function [] = DTF_batch()

EEG = load_vant();

fprintf('\nStarting: %s\n',datestr(now));
dtf_sig(EEG, [8 16 60 49], 'vant', 'rest_eo', 50:250,1);
fprintf('\nStarting: %s\n',datestr(now));
dtf_sig(EEG, [8 16 60 49], 'vant', 'quiet', 50:250,1);
fprintf('\nStarting: %s\n',datestr(now));
dtf_sig(EEG, [8 16 60 49], 'vant', 'aloud', 50:250,1);

EEG = load_nourse();

fprintf('\nStarting: %s\n',datestr(now));
dtf_sig(EEG, [4 5 8 16], 'nourse', 'rest_eo', 50:250,1);
fprintf('\nStarting: %s\n',datestr(now));
dtf_sig(EEG, [4 5 8 16], 'nourse', 'aloud', 50:250,1);
fprintf('\nStarting: %s\n',datestr(now));
dtf_sig(EEG, [4 5 8 16], 'nourse', 'quiet', 50:250,1);