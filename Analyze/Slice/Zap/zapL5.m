function [R] = zapL5(aType)

global DATA_DIR;
global DATA_PATH;
count = 0;
prefix = 'R_L5_';

 
switch aType
    case 'sub_rmp'
        %%Subthreshold RMP
        dDir = fullfile(DATA_PATH, '\Human recordings\ZAP function\Homeira\Layer 5. ZAP function.Raw data\Subthreshold holding RMP\');
        for i=1:9
            count = count + 1;
            Dir{count} = dDir;
            fn{count} = sprintf('cell_%d', i);
        end
        

        dDir = fullfile (DATA_DIR, '\Human recordings\ZAP function\Lihua\Lihua data. Layer 5, ZAP function, Raw Data.Last version\Sub threshold hold RMP');
        for i=3:25
            count = count + 1;
            Dir{count} = dDir;
            fn{count} = sprintf('cell_%d', i);
        end
    case 'sub_80'
         %%Subthreshold -80
        dDir = fullfile(DATA_PATH, '\Human recordings\ZAP function\Homeira\Layer 5. ZAP function.Raw data\Subthreshold holding RMP');
        for i=1:9
            count = count + 1;
            Dir{count} = dDir;
            fn{count} = sprintf('cell_%d', i);
        end
        
        dDir = fullfile(DATA_PATH, '\Human recordings\ZAP function\Lihua\Lihua data. Layer 5, ZAP function, Raw Data.Last version\Sub threshold hold -80\');
        for i=1:11
            count = count + 1;
            Dir{count} = dDir;
            fn{count} = sprintf('cell_%d', i);
        end
    case 'supra_rmp'
         %%Suprathreshold RMP
        dDir = fullfile(DATA_PATH, '\Human recordings\ZAP function\Homeira\Layer 5. ZAP function.Raw data\Suprathreshold');
        for i=1:7
            count = count + 1;
            Dir{count} = dDir;
            fn{count} = sprintf('cell_%d', i);
        end
        
        dDir = fullfile(DATA_PATH, '\Human recordings\ZAP function\Lihua\Lihua data. Layer 5, ZAP function, Raw Data.Last version\Suprathreshold, hold RMP');
        for i=1:23
            count = count + 1;
            Dir{count} = dDir;
            fn{count} = sprintf('cell_%d', i);
        end
    case 'supra_80'     
        dDir = fullfile(DATA_PATH, '\Human recordings\ZAP function\Lihua\Lihua data. Layer 5, ZAP function, Raw Data.Last version');
        for i=1:3
            count = count + 1;
            Dir{count} = dDir;
            fn{count} = sprintf('cell_%d', i);
        end    
    otherwise
        display('That analysis type does not exist');
end

dolist = 1:count;
R = zap_run(Dir, fn, dolist, 1);
savePath = fullfile(DATA_DIR, '\Human recordings\ZAP function\Analyzed\');
if ~exist(savePath, 'dir')
    mkdir(savePath);
end
eval(sprintf('%s%s = R;', prefix, aType));
save(fullfile(DATA_DIR, '\Human recordings\ZAP function\Analyzed\',[prefix aType '.mat']), [prefix aType]);

