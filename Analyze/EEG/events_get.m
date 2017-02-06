function [ev_index ev_loc] = events_get(EEG, event_type)

ev_type = [EEG.event(:).type];
ev_locations = [EEG.event(:).latency];
ev_index = find(ev_type == event_type);
ev_loc = ev_locations(ev_index);
