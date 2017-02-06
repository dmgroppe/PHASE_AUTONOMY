function [R] = io_lihua()

Dir = 'D:\Projects\Data\Lihua\human\IV traces\IV\';
eDir = 'D:\Projects\Data\IOCurves\';
R = run_io(Dir, eDir,1);