params = get_default_params();

clear;

%% Encoding

test = 'enc';
cond = 'sH';

% RunAsAnalysis(test, cond);
% RunCuAnalysis(test, cond);
% RunMcAnalysis(test, cond);
% RunPrAnalysis(test, cond);
% RunSaAnalysis(test, cond);
% RunSiAnalysis(test, cond);
% RunStAnalysis(test, cond);
RunDeAnalysis(test, cond);

% Excluded analysis
% RunLyAnalysis();

test = 'enc';
cond = 'R';

% RunAsAnalysis(test, cond);
% RunCuAnalysis(test, cond);
% RunMcAnalysis(test, cond);
% RunPrAnalysis(test, cond);
% RunSaAnalysis(test, cond);
% RunSiAnalysis(test, cond);
% RunStAnalysis(test, cond);
RunDeAnalysis(test, cond);

%RunLyAnalysis();

%% Recognition
test = 'rec';
cond = 'Hits';

% RunAsAnalysis(test, cond);
% RunCuAnalysis(test, cond);
% RunMcAnalysis(test, cond);
% RunPrAnalysis(test, cond);
% RunSaAnalysis(test, cond);
% RunSiAnalysis(test, cond);
% RunStAnalysis(test, cond);
RunDeAnalysis(test, cond);

%RunLyAnalysis();

test = 'rec';
cond = 'CR';

% RunAsAnalysis(test, cond);
% RunCuAnalysis(test, cond);
% RunMcAnalysis(test, cond);
% RunPrAnalysis(test, cond);
% RunSaAnalysis(test, cond);
% RunSiAnalysis(test, cond);
% RunStAnalysis(test, cond);
RunDeAnalysis(test, cond);

%RunLyAnalysis();
