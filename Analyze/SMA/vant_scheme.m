function [S] = vant_scheme()

count = 0;
for i=1:4
    for j=1:8
        count = count + 1;
        S.E{1}(i,j) = count;
    end
end

S.E{2} = 33:36;
S.E{3} = 37:40;
S.E{4} = 41:44;
S.E{5} = 45:50;
S.E{6} = 51:56;
S.E{7} = 57:64;

S.Names = {'Grid', 'OFC', 'FP', 'AIH', 'PTL', 'MIH', 'PIH'};