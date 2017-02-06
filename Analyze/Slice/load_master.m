function [infra supra] = load_master()

Dir = 'D:\Projects\Data\Human Recordings\Files for First paper\Spreadsheets\';
fname = 'Carlos Analysis_Reviewed';  
[infra supra] = reload_carlos_analysis(Dir, fname);
