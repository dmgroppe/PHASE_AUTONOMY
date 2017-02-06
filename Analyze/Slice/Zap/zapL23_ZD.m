function [R] = zapL23_ZD()

global DATA_DIR;

count = 0;


% PreZD RMP
% dDir = fullfile(DATA_DIR, '\Human Recordings\ZAP function\ZD\Layer 2 and 3. ZAP function.Raw data\Sub threshold, hold RMP, before ZD7288');
% 
% for i=1:4
%     count = count + 1;
%     Dir{count} = dDir;
%     fn{count} = sprintf('cell_%d', i);
% end

% %POstZD RMP
% 
% dDir = fullfile(DATA_DIR, '\Human Recordings\ZAP function\ZD\Layer 2 and 3. ZAP function.Raw data\Sub threshold , hold RMP, after ZD7288\');
% 
% for i=1:4
%     count = count + 1;
%     Dir{count} = dDir;
%     fn{count} = sprintf('cell_%d', i);
% end


% % PreZD SUPRA
% 
% dDir = fullfile(DATA_DIR, '\Human Recordings\ZAP function\ZD\Layer 2 and 3. ZAP function.Raw data\Suprathreshold hold RMP, before ZD7288');
% 
% for i=1:4
%     count = count + 1;
%     Dir{count} = dDir;
%     fn{count} = sprintf('cell_%d', i);
% end

% POst ZD SUPRA

dDir = fullfile(DATA_DIR, '\Human Recordings\ZAP function\ZD\Layer 2 and 3. ZAP function.Raw data\Suprathreshold, hold RMP,  after ZD7288\');

for i=1:4
    count = count + 1;
    Dir{count} = dDir;
    fn{count} = sprintf('cell_%d', i);
end


% ---------------------------- ZD ----------------------------------------%



dolist = 1:count;

R = zap_run(Dir, fn, dolist, 1);
save(fullfile(dDir, 'zapAnalysis.mat'));