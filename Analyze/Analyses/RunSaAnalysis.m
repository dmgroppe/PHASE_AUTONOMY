function [] = RunSaAnalysis(test, cond)

params = get_default_params();

params.ana.subjectname = 'Sa';
params.ana.test = test;
params.ana.cond = cond;
trig_plot = '';

[params] = set_file_names(params);

params.export.export_results = 1;

if (strcmp(params.ana.test, 'enc'))
    %params.ana.chlist = [20 23 27];
    params.ana.chlist = [20 23 27];
    
    if (strcmp(params.ana.cond, 'sH'))
        % This is his sH epochs
        params.ana.epoch_list = [2 8 10 13 15 17 18 20 21 22 23 24 26 27 39 44 45 53 55];
    else
        % These are his R epochs
        params.ana.epoch_list = [4 5 12 16 19 28 29 31 40 41 42 46 47 49 50 52 57 58 59];
    end
    
    params.trig.get_from_file = 0;
    params.trig.dir = 'pos';
    params.trig.offset = 1;
    params.trig.baseline = 100;
    params.trig.threshold = 1.0e5;
    params.trig.plot = trig_plot;
    
else
    
    %params.ana.chlist = [20 23 29];
    params.ana.chlist = [20 23 29];

    if (strcmp(params.ana.cond, 'Hits'))
        % This is his sH epochs
        params.ana.epoch_list = [1 10 11 13 18 24 28 29 33 35 36 37 40 42 45 47 51 56 60];
    else
        % These are his R epochs
        params.ana.epoch_list = [5 6 7 9 12 14 19 20 22 23 41 43 46 48 52 54 55 57 58];
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