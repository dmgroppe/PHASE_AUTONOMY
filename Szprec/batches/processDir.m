function [] = processDir(sdir, cfg)

global DATA_DIR;

if nargin < 2; cfg = cfg_default(); end;

dp = fullfile(DATA_DIR,'Szprec', sdir, 'Data');
f = dir(fullfile(dp, '*.mat'));
cfg.bigmem = 1;
use_parfor = 1;

% Make some patient specific alterations
switch sdir
   case 'SV'
       matlabpool close;
       matlabpool 5;
       cfg.bigmem = 0;
   case 'IM'
       matlabpool close;
       matlabpool 5;
       cfg.bigmem = 0;
       use_parfor = 0;
   case 'CJ'
       matlabpool close;
       matlabpool 5;    
       cfg.bigmem = 0;
   case 'AV'
       matlabpool close;
       matlabpool 5;
       cfg.bigmem = 0;
   case 'SK'
%        matlabpool close;
%        matlabpool 5;
       cfg.bigmem = 0;
       use_parfor = 0;
end

if cfg.bigmem
    % Use the internal parfors to speed things up
    for i=1:numel(f)
        dfile = fullfile(dp, f(i).name);
        if exist(dfile, 'file')
            processSingle(f(i).name(1:end-4), cfg,1);
        end 
    end
else
   % Run the analysis 
   if use_parfor
       parfor i=1:numel(f)
            dfile = fullfile(dp, f(i).name);
            if exist(dfile, 'file')
                processSingle(f(i).name(1:end-4), cfg, 0);
            end 
       end
   else
       for i=1:numel(f)
            dfile = fullfile(dp, f(i).name);
            if exist(dfile, 'file')
                processSingle(f(i).name(1:end-4), cfg, 0);
            end 
       end
   end
end

% Restart the local comfiguration
matlabpool close;
matlabpool;
