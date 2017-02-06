function [matrix_bi] = mono_to_bipolar(matrix_mo, group_end_index) 

B = circshift(matrix_mo,[0,-1]);
matrix_bi=matrix_mo-B;
matrix_bi(:,group_end_index)=[];