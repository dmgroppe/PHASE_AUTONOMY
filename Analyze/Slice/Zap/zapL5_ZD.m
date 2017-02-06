function [R] = zapL5_ZD()

global DATA_DIR;

 count = 0;
 %Subthreshold RMP preZD
 dDir = fullfile(DATA_DIR, '\Human Recordings\ZAP function\ZD\Layer 5. ZAP function.Raw data\Sub threshold, hold RMP, before ZD7288\');
 for i=1:4
    count = count + 1;
    Dir{count} = dDir;
    fn{count} = sprintf('cell_%d', i);
end
 
 %Subthreshold RMP postZD

% dDir = fullfile(DATA_DIR, 'Human Recordings\ZAP function\ZD\Layer 5. ZAP function.Raw data\Sub threshold  hold RMP, after ZD7288');
% for i=1:4
%     count = count + 1;
%     Dir{count} = dDir;
%     fn{count} = sprintf('cell_%d', i);
% end

dolist = 1:count;

R = zap_run(Dir, fn, dolist, 1);
save(fullfile(dDir, 'zapAnalysis.mat'));


