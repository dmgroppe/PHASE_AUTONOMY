function [] = make_noise(fs, npoints, fname)

% Generates a custom Axon wavefile containing gaussian white noise with
% noise variance of 1, and mean of 0

y = randn(1,npoints);
T = (1:npoints)/fs;

fid = fopen(fname,'wt');
fprintf(fid,'ATF \t 1.0\n');
fprintf(fid,'1 \t 3\n');
fprintf(fid,'"Comments: fs=%d"\n',fs);
fprintf(fid,'"time (s)"   "amplitude (pA)"   "comment ()"\n');
for i = 1:length(y)
    fprintf(fid,'%f \t %8.6f \t ""\n',T(i),y(i));
end

fclose(fid);