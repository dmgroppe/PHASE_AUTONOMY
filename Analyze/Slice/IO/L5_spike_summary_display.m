function [all_cells list alist] = L5_spike_summary_display(do_analysis, dosave)

if nargin < 1; do_analysis = false; end;
if nargin < 2; dosave = 0; end;


% Lihua's L5 directory
list(1).path = 'Lihua\human\IV traces\IV\Spike_Analysis';
list(1).fn = [];
list(1).desc = [];

% Unhealthy
list = add_exclusion(list, '13709012', 'Gliia?  No spikes');
list = add_exclusion(list, '13o08001', 'Unhealthy');
%list = add_exclusion(list, '13725016', ''); % Reviewed Feb 23 - looks okay
%list = add_exclusion(list, '14127300', ''); % % Reviewed Feb 23 - looks okay


list = add_exclusion(list, '13d11300', 'Unhealthy, few ugly spikes');
%list = add_exclusion(list, '13003000', 'few spikes in burst'); % Does not
%exist in directory

% Bursting neuron
list = add_exclusion(list, '13003000', 'Bursting, few spikes');
list = add_exclusion(list, '13d03303', 'Bursting, few spikes, large ADP');
list = add_exclusion(list, '13d02306', 'Bursting, few spikes'); % used for figure
list = add_exclusion(list, '13d02300', 'Bursting cell, triplet - nice for figure'); 

% Strongly accomodating wuth plateau, rapidly spiking
list = add_exclusion(list, '13o08020', 'Strong accomodation and attenuation of spikes');
list = add_exclusion(list, '13d11344', 'Strong accomodation and attenuation of spikes');

% Interneurons
list = add_exclusion(list, '14127339', 'Interneuron');
list = add_exclusion(list, '13429017', 'Interneuron');

% Few spikes, no burst
list = add_exclusion(list, '13O08011', 'Few spikes, no burst');
list = add_exclusion(list, '14127380', 'Few spikes, no burst');
list = add_exclusion(list, '13O08000', 'Few spikes, no burst');
list = add_exclusion(list, '13O08019', 'Few spikes, no burst');
list = add_exclusion(list, '13o03016', 'Few spikes, no burst');


% Homeira's L5 directory

list(2).path = 'Homeira\IV\Spike_Analysis';
list(2).fn = {};
list(2).desc = {};

%Burst
list(2) = add_exclusion(list(2), '13d02022', 'Burst, few spikes');

%Techinical problem
list(2) = add_exclusion(list(2), '13o21005', 'Gains screwed up');

% Unhealthy
list(2) = add_exclusion(list(2), '13o21040', 'Unhealthy, depolarized');
list(2) = add_exclusion(list(2), '13n21007', 'Unhealthy, depolarized');
list(2) = add_exclusion(list(2), '13n05000', 'Unhealthy, depolarized');

% Duplicates
list(2) = add_exclusion(list(2), '13d02002', 'Duplicate');
list(2) = add_exclusion(list(2), '13d06001', 'Duplicate');
list(2) = add_exclusion(list(2), '13d06009', 'Duplicate');
list(2) = add_exclusion(list(2), '13d060017', 'Duplicate');
list(2) = add_exclusion(list(2), '13d060010', 'Duplicate');
list(2) = add_exclusion(list(2), '13o21024', 'Duplicate');
list(2) = add_exclusion(list(2), '13d060018', 'Duplicate');
list(2) = add_exclusion(list(2), '13d03029', 'Duplicate');
list(2) = add_exclusion(list(2), '13d03044', 'Duplicate');

[all_cells alist] = all_cells_collect({list.path}, {list.fn});

% Do the analysis
if do_analysis
    [all_features] = spike_summary(all_cells, alist, dosave);
end


