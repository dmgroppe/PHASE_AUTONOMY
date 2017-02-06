function [f] = run_convert()

f(1).dir = 'D:\Projects\Data\Tick\Block1\';
f(1).file = 'EP_D1';
f(2).dir = 'D:\Projects\Data\Tick\Block1\';
f(2).file = 'EP_D2';
f(3).dir = 'D:\Projects\Data\Tick\Block1\';
f(3).file = 'EP_D3';

f(4).dir = 'D:\Projects\Data\Tick\Block2\';
f(4).file = 'EP_D4';
f(5).dir = 'D:\Projects\Data\Tick\Block2\';
f(5).file = 'EP_D5';
f(6).dir = 'D:\Projects\Data\Tick\Block2\';
f(6).file = 'EP_D6';

f(7).dir = 'D:\Projects\Data\Tick\Block3\';
f(7).file = 'EP_D7';
f(8).dir = 'D:\Projects\Data\Tick\Block3\';
f(8).file = 'EP_D8';
f(9).dir = 'D:\Projects\Data\Tick\Block3\';
f(9).file = 'EP_D9';

for i=1:length(f)
    cnt_to_mat(f(i).dir, f(i).file);
end



