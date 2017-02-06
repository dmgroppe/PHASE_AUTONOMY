function [infra supra] = load_seizures()

Dir = 'D:\Projects\Data\Human Recordings\Files for First paper\Spreadsheets\';
fname = 'Seizures - TAV';
[infra supra] = reload_carlos_analysis(Dir, fname);
