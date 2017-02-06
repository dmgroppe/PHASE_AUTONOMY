function [] = RunMcAnalysis(test, cond)

params = get_default_params();

params.ana.subjectname = 'Mc';
params.ana.test = test;
params.ana.cond = cond;
trig_plot = '';

[params] = set_file_names(params);
%params.ana.chlist = [1 9 16];
params.ana.chlist = [1 9 16];

params.export.export_results = 1;

if (strcmp(params.ana.test, 'enc'))
    
    if (strcmp(params.ana.cond, 'sH'))
        % This is his sH epochs
        params.ana.epoch_list = [1 2 3 5 8 11 12 16 24 25 31 33 34 35 36 37 38 39 40 41 42 44 47 48 49 50 53 60];
    else
        % These are his R epochs
        params.ana.epoch_list = [7 10 13 14 15 18 19 20 21 22 23 26 27 28 29 30 32 43 45 46 51 52 54 55 56 57 58 59];
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
        params.ana.epoch_list = [1 3 4 5 8 12 14 16 24 29 30 31 32 33 34 37 38 43 44 45 46 47 48 49 50 55 56 58];
    else
        % These are his R epochs
        params.ana.epoch_list = [2 7 9 10 11 13 15 17 18 20 21 22 26 27 28 35 36 39 40 41 42 51 52 53 54 57 59 60];
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