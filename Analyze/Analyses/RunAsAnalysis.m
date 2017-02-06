function [] = RunAsAnalysis(test, cond)

params = get_default_params();

params.ana.subjectname = 'As';
params.ana.test = test;
params.ana.cond = cond;
trig_plot = '';

[params] = set_file_names(params);
%params.ana.chlist = [2 7 9];
params.ana.chlist = [2 7 9];

params.export.export_results = 1;

if (strcmp(params.ana.test, 'enc'))
    
    if (strcmp(params.ana.cond, 'sH'))
        % This is his sH epochs
        params.ana.epoch_list = [5 6 7 10 12 13 15 23 28 30 36 38 39 42 43 55 60];
    else
        % These are his R epochs
        params.ana.epoch_list = [2 3 17 18 19 20 25 27 32 37 40 41 46 48 49 54 59];
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
        params.ana.epoch_list = [2 3 8 14 16 25 30 31 32 36 47 48 49 52 56 57];
    else
        % These are his R epochs
        params.ana.epoch_list = [6 9 12 19 22 26 33 34 37 38 41 43 44 46 59 60];
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