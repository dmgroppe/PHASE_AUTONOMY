function [all_cells list alist all_features] = L23_spike_summary_display(do_analysis, dosave)

if nargin < 1; do_analysis = false; end;
if nargin < 2; dosave = 0; end;


% Lihua's L5 directory
list(1).path = 'L23data\Spike_Analysis';
list(1).fn = [];
list(1).desc = [];

list = add_exclusion(list, '11n100380', 'Appears leaky and lots of spont activity');
list = add_exclusion(list, '11o20008', 'Artifactual, very odd AHP');
list = add_exclusion(list, '11o27021', 'Artifactual, very odd AHP');
list = add_exclusion(list, '11o27026', 'Artifactual, very odd AHP');
list = add_exclusion(list, '12109000', 'Artifactual, very odd AHP');
list = add_exclusion(list, '12109015', 'Gain in screwed up');
list = add_exclusion(list, '12112000', 'No spikes');
list = add_exclusion(list, '12112000', 'No spikes');
list = add_exclusion(list, '12202102', 'No spikes');
list = add_exclusion(list, '12206037', 'Appears unhealthy');
list = add_exclusion(list, '12206037', 'Appears unhealthy');
list = add_exclusion(list, '12213018', 'Unhealthy cell');
list = add_exclusion(list, '12326006', 'Unhealthy cell');
list = add_exclusion(list, '12503004', 'Broad action potentials, Unhealthy cell');
list = add_exclusion(list, '12503005', 'Broad action potentials, Unhealthy cell');
list = add_exclusion(list, '12503006', 'Broad action potentials, Unhealthy cell');
list = add_exclusion(list, '12524017', 'Looks like same cell as 12524012');
list = add_exclusion(list, '12607002', 'Looks unhealthy');
list = add_exclusion(list, '12614030', 'Very depolarized');
list = add_exclusion(list, '11n10025', 'Very depolarized, only two traces with spiking activity');
list = add_exclusion(list, '13307001', 'Same cell as 13307000 - looks unhealthy');
list = add_exclusion(list, '13401000', 'Looks unhealthy');
list = add_exclusion(list, '12206038', 'Looks unhealthy, low resting membrane potential, ugly spikes');

%Inter-neurons
list = add_exclusion(list, '12524002', 'inter-neuron');
list = add_exclusion(list, '13207004', 'Interneuron');
list = add_exclusion(list, '13321000', 'Interneuron');
list = add_exclusion(list, '13321008', 'Interneuron');
list = add_exclusion(list, '12614009', 'Looks like inter-neuron in some aspects and neuron in other (sag)');


% Bursting cells
list = add_exclusion(list, '12213009', 'Bursting cell');
list = add_exclusion(list, '12202000', 'Bursting cell, with few spikes'); % Really good example of bursting
list = add_exclusion(list, '12206008', 'Bursting cell, with few spikes'); % Really good example of bursting
list = add_exclusion(list, '12206026', 'Bursting cell, with few spikes'); % Really good example of bursting
list = add_exclusion(list, '12206039', 'Bursting cell, with few spikes'); % 
%list = add_exclusion(list, '12206041', 'Bursting cell, with few spikes');
%% Undeleted upon review
list = add_exclusion(list, '12213010', 'Bursting cell');
list = add_exclusion(list, '12209023', 'Bursting cel');
list = add_exclusion(list, '12209023', 'Bursting neuron');
list = add_exclusion(list, '12213000', 'Bursting neuron');
%list = add_exclusion(list, '12232600', 'Bursting neuron'); % Doesn't
%appear to exist
list = add_exclusion(list, '13402012', 'Bursting neuron');
list = add_exclusion(list, 'c12605011', 'Bursting neuron, lots of spikes maybe due to extent of depolarization');

% Few spikes non-bursting
list = add_exclusion(list, '12209013', 'Very few spikes, no burst');
list = add_exclusion(list, '12202109', 'Too few spikes, non bursting');
list = add_exclusion(list, '12202235', 'Too few spikes, No ADP or large burst potential');

% Strong accomodation - large Ih,and post rebound burst, high firing rates
% (? interneuron of same fashion)
% Maybe just too large current steps?
list = add_exclusion(list, '13221001', 'Stringly accomodating - mayeb too alrge a depo');
list = add_exclusion(list, '13221008', 'Strongly accomodating - mayeb too alrge a depo');
list = add_exclusion(list, '13228000', 'Stringly accomodating   mayeb too alrge a depo');
list = add_exclusion(list, '13228001', 'Strongly accomodating   mayeb too alrge a depo');
list = add_exclusion(list, '13228006', 'Strongly accomodating   mayeb too alrge a depo');

[all_cells alist] = all_cells_collect({list.path}, {list.fn});

if do_analysis
    [all_features] = spike_summary(all_cells, alist, dosave);
end


function [list] = add_exclusion(list, fn, desc)

n = numel(list.fn);
list.fn{n+1} = fn;
list.desc{n+1} = desc;


