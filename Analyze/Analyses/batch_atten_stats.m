function []  = batch_atten_stats()

aparams1 = get_default_params();

alpha = 0.05;
nsurr = 2000;
channel1 = 27;
channel2 = 27;

aparams1.ana.nsurr = nsurr;
aparams1.ana.subjectname = 'Bonner';
aparams1.ana.atten_channel = channel1;
aparams2 = aparams1;
aparams2.ana.atten_channel = channel2;

% 'norm_baseline', 'sub_baseline', 'zero_mean', '';
aparams1.ana.norm = 'norm_baseline';

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  SCENES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% % Attend > Suppress
aparams1.ana.test = 'scene';
aparams1.ana.cond = 'scene';  % Can be face or scene
aparams1.ana.test_index = [1 2];

aparams2.ana.test = 'face';
aparams2.ana.cond = 'scene';  % Can be face or scene
aparams2.ana.test_index = [1 2];

display_analysis(aparams1);
display_analysis(aparams2);

atten_stats(alpha, 1, aparams1, aparams2);

%% Suppress > Attend
aparams1.ana.test = 'face';
aparams1.ana.cond = 'scene';  % Can be face or scene
aparams1.ana.test_index = [1 2];

aparams2.ana.test = 'scene';
aparams2.ana.cond = 'scene';  % Can be face or scene
aparams2.ana.test_index = [1 2];

atten_stats(alpha, 3, aparams1, aparams2);

% Passive > Supress
aparams1.ana.test = 'passive';
aparams1.ana.cond = 'scene';  % Can be face or scene
aparams1.ana.test_index = [1 2];

aparams2.ana.test = 'face';
aparams2.ana.cond = 'scene';  % Can be face or scene
aparams2.ana.test_index = [1 2];
aparams1.ana.normtobl = 1;

atten_stats(alpha, 5, aparams1, aparams2);

%% Suppress > Passive
aparams1.ana.test = 'face';
aparams1.ana.cond = 'scene';  % Can be face or scene
aparams1.ana.test_index = [1 2];

aparams2.ana.test = 'passive';
aparams2.ana.cond = 'scene';  % Can be face or scene
aparams2.ana.test_index = [1 2];
aparams1.ana.normtobl = 1;

atten_stats(alpha, 7, aparams1, aparams2);

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  FACES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Attend > Supress
aparams1.ana.test = 'face';
aparams1.ana.cond = 'face';  % Can be face or scene
aparams1.ana.test_index = [1 2];

aparams2.ana.test = 'scene';
aparams2.ana.cond = 'face';  % Can be face or scene
aparams2.ana.test_index = [1 2];

atten_stats(alpha, 9, aparams1, aparams2);

%% Supress > Attend
aparams1.ana.test = 'scene';
aparams1.ana.cond = 'face';  % Can be face or scene
aparams1.ana.test_index = [1 2];

aparams2.ana.test = 'face';
aparams2.ana.cond = 'face';  % Can be face or scene
aparams2.ana.test_index = [1 2];


atten_stats(alpha, 11, aparams1, aparams2);

% Passive > Supress
aparams1.ana.test = 'passive';
aparams1.ana.cond = 'face';  % Can be face or scene
aparams1.ana.test_index = [1 2];

aparams2.ana.test = 'scene';
aparams2.ana.cond = 'face';  % Can be face or scene
aparams2.ana.test_index = [1 2];

atten_stats(alpha, 13, aparams1, aparams2);

%% Suppress > Passive
aparams1.ana.test = 'scene';
aparams1.ana.cond = 'face';  % Can be face or scene
aparams1.ana.test_index = [1 2];

aparams2.ana.test = 'passive';
aparams2.ana.cond = 'face';  % Can be face or scene
aparams2.ana.test_index = [1 2];

atten_stats(alpha, 15, aparams1, aparams2);

function [] = display_analysis(aparams)

display(sprintf('Subject name = %s',aparams.ana.subjectname));
display(sprintf('Channel = %d',aparams.ana.atten_channel));
display(sprintf('Test = %s',aparams.ana.test));
display(sprintf('Cond = %s',aparams.ana.cond));
display(' ');






