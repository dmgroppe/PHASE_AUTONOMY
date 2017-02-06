function [] = run_all()

io_homeira();
io_lihua();

Dir = 'D:\Projects\Data\L23data\';
eDir = 'D:\Projects\Data\IOCurvesL23\';
run_io(Dir, eDir,1);