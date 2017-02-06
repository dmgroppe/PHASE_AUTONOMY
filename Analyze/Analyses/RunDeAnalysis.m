function [] = RunDeAnalysis(test, cond)

params = get_default_params();

params.ana.subjectname = 'De';
params.ana.test = test;
params.ana.cond = cond;
trig_plot = '';

[params] = set_file_names(params);
%params.ana.chlist = [2 7 9];
params.ana.chlist = [20 27 25];

params.export.export_results = 1;

if (strcmp(params.ana.test, 'enc'))
    
    if (strcmp(params.ana.cond, 'sH'))
        % This is his sH epochs
        params.ana.epoch_list = [1 7 8 13 15 16 17 18 22 23 24 25 28 29 32 33 38 39 40 45 46 54 56 57 58 59 60];
    else
        % These are his R epochs
        params.ana.epoch_list = [2 3 4 6 9 10 11 12 19 20 21 26 27 31 34 35 36 37 41 42 43 44 47 48 49 50 51 52 53 55];
    end
    
    params.trig.get_from_file = 0;
    params.trig.dir = 'pos';
    params.trig.offset = 1;
    params.trig.baseline = 100;
    params.trig.threshold = 1.0e5;
    params.trig.plot = trig_plot;
    
else

    if (strcmp(params.ana.cond, 'Hits'))
        % This is his Hits
        params.ana.epoch_list = [2 3 7 9 10 12 13 14 20 21 26 30 32 35 38 42 43 44 45 47 50 52 53 54 55 56 57];
    else
        % These are his CR
        params.ana.epoch_list = [1 4 5 6 8 16 18 19 22 23 24 25 27 28 29 31 33 34 36 37 39 40 41 46 48 49 51 58 59 60];
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