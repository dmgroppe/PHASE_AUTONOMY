function [] = Szprec_ph_fullanalysis(sz_list, pt_name)

% Runs analysis up to plotting on the schematic

if nargin < 2; pt_name = []; end;

for i=1:numel(sz_list)
    list_pt_name = strtok(sz_list{i}{1}, '_');
    
    % Just do a specific patient if specified
    if ~isempty(pt_name)
        if  strcmpi(list_pt_name,pt_name)
            do_analysis(sz_list{i}, pt_name)
        end
    else
        do_analysis(sz_list{i}, list_pt_name)
    end
end

function [] = do_analysis(sz_list, pt_name)

% Perform PH detection
display('Performing PH detection...');
Szprec_page_hinkley_process(sz_list,1);

% Do the stats and save them
display('Performing PH STATS...');
Szprec_ph_stats(sz_list, 'early', 1);

% Plot the schematic
display('Plotting on schematic...');
figure;clf;
Szprec_rank_on_schematic(pt_name, 'early');

