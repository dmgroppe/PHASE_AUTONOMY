function [EEG] = load_nourse()

load('D:\Projects\Data\Nourse\EEG1kcf_notched.mat');

EEG = eval('EEG1kcf_notched');