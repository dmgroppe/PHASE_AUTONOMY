function [R] = RunBonnerAnalysis(aparams)

params = aparams;

params.ana.subjectname = 'Bonner';
%params.ana.test = test;
%params.ana.cond = cond;  % Can be face or scene
trig_plot = '';

[params] = atten_file_names(params);
params.ana.length = 800;

params.ana

%params.ana.chlist = [9 27];

params.export.export_results = 1;

params.ana.test = lower(params.ana.test);

if (strcmp(params.ana.test, 'face1'))
    
    if (strcmp(params.ana.cond, 'face'))
        params.ana.epoch_list = [2 4 8 10 13 14 20 21 25 27 32 33 37 38 43 46 49 51 55 58 61 64 67 69 73 74 79 80 87 88 91 94 99 100 104 106 111 112 117 118];
    else
        params.ana.epoch_list = [1 3 7 9 15 16 19 22 26 28 31 34 39 40 44 45 50 52 56 57 62 63 68 70 75 76 81 82 85 86 92 93 97 98 103 105 109 110 115 116];        
    end
    
elseif (strcmp(params.ana.test, 'face2'))

    if (strcmp(params.ana.cond, 'face'))
        params.ana.epoch_list = [2 3 9 10 13 16 20 22 25 28 31 32 38 40 43 46 49 51 56 58 62 63 68 70 73 75 79 80 87 88 92 93 97 100 103 104 109 111 115 117];
    else
        params.ana.epoch_list = [1 4 7 8 14 15 19 21 26 27 33 34 37 39 44 45 50 52 55 57 61 64 67 69 74 76 81 82 85 86 91 94 98 99 105 106 110 112 116 118];        
    end
elseif (strcmp(params.ana.test, 'scene1'))
    if (strcmp(params.ana.cond, 'face'))
        params.ana.epoch_list = [1 2 7 9 13 16 21 22 25 27 32 34 37 38 45 46 49 51 55 57 62 64 68 69 74 76 80 81 86 88 91 92 99 100 104 105 110 111 115 116];
    else
        params.ana.epoch_list = [3 4 8 10 14 15 19 20 26 28 31 33 39 40 43 44 50 52 56 58 61 63 67 70 73 75 79 82 85 87 93 94 97 98 103 106 109 112	117	118];        
    end
elseif (strcmp(params.ana.test, 'scene2'))
    if (strcmp(params.ana.cond, 'face'))
        params.ana.epoch_list = [3 4 7 8 13 15 20 22 27 28 31 33 37 40 44 45 50 51 56 57 62 64 67 69 73 76 79 82 85 88 91 92 97 99 103 104 110 112 116 118];
    else
        params.ana.epoch_list = [1 2 9 10 14 16 19 21 25 26 32 34 38 39 43 46 49 52 55 58 61 63 68 70 74 75 80 81 86 87 93 94 98 100 105 106 109 111 115 117];        
    end
elseif (strcmp(params.ana.test, 'scene3'))
    if (strcmp(params.ana.cond, 'face'))
        params.ana.epoch_list = [1 2 7 9 15 16 21 22 25 26 31 34 38 39 43 44 50 52 55 57 61 64 69 70 73 76 81 82 86 87 92 94 97 99 104 106 109 112 115 116];
    else
        params.ana.epoch_list = [3 4 8 10 13 14 19 20 27 28 32 33 37 40 45 46 49 51 56 58 62 63 67 68 74 75 79 80 85 88 91 93 98 100 103 105 110 111 117 118];        
    end
elseif (strcmp(params.ana.test, 'passive1'))
    if (strcmp(params.ana.cond, 'face'))
        params.ana.epoch_list = [1 2 7 8 15 16 19 21 26 27 32 34 37 39 43 46 49 50 57 58 62 64 68 69 74 76 80 81 86 88 93 94 97 99 103 106 109 111 115 118];
    else
        params.ana.epoch_list = [3 4 9 10 13 14 20 22 25 28 31 33 38 40 44 45 51 52 55 56 61 63 67 70 73 75 79 82 85 87 91 92 98 100 104 105 110 112 116 117];        
    end
elseif (strcmp(params.ana.test, 'passive2'))
    if (strcmp(params.ana.cond, 'face'))
        params.ana.epoch_list = [1 4 7 8 14 15 20 22 25 26 33 34 38 39 43 46 49 50 55 57 62 63 68 70 73 75 81 82 86 87 91 93 99 100 103 106 110 112 115 116];
    else
        params.ana.epoch_list = [2 3 9 10 13 16 19 21 27 28 31 32 37 40 44 45 51 52 56 58 61 64 67 69 74 76 79 80 85 88 92 94 97 98 104 105 109 111 117 118];        
    end  
end

% Trigger stiff which is not relevant here
params.trig.get_from_file = 0;
params.trig.dir = 'pos';
params.trig.offset = 1;
params.trig.baseline = 100;
params.trig.threshold = 1.0e5;
params.trig.plot = trig_plot;

params.ana
params.export.prefix
params.trig

if (params.debug.prompt)
    if (continue_prompt())
        R = analyze(params);
    else
        display('Aborting.');
    end
else
    R = analyze(params);
end
