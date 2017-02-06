function [] = RunPrAnalysis(test, cond)

params = get_default_params();

params.ana.subjectname = 'Pr';
params.ana.test = test;
params.ana.cond = cond;
trig_plot = '';

[params] = set_file_names(params);
%params.ana.chlist = [1 7 9];
params.ana.chlist = [1 7 9];

params.export.export_results = 1;

if (strcmp(params.ana.test, 'enc'))
    
    if (strcmp(params.ana.cond, 'sH'))
        % This is his sH epochs
        params.ana.epoch_list = [2 3 6 10 13 17 19 20 21 27 30 31 35 36 38 41 44 45 48 49 50 51 52 53 55 57 58 59 60];
    else
        % These are his R epochs
        params.ana.epoch_list = [4 5 7 9 11 12 14 15 16 18 22 23 24 25 26 28 29 32 33 34 37 39 40 42 43 46 47 54 56];
    end
    
    params.trig.get_from_file = 0;
    params.trig.dir = 'pos';
    params.trig.offset = 1;
    params.trig.baseline = 100;
    params.trig.threshold = 1.0e5;
    params.trig.plot = trig_plot;
    
else

    if (strcmp(params.ana.cond, 'Hits'))
        % This is his sH epochs
        params.ana.epoch_list = [1 3 4 8 16 20 21 36 39 41 43 45 47 49 50 51 55 57 58 59];
    else
        % These are his R epochs
        params.ana.epoch_list = [2 5 7 15 17 18 22 25 26 30 31 32 34 38 40 44 52 53 56 60];
    end
    
    params.trig.get_from_file = 0;
    params.trig.dir = 'pos';
    params.trig.offset = 1;
    params.trig.baseline = 100;
    params.trig.threshold = 1.0e5;
    params.trig.plot = trig_plot;
end

params.ana
params.trig

if (params.debug.prompt)
    if (continue_prompt())
        analyze(params);
    else
        display('Aborting.');
    end
else
    analyze(params);
end