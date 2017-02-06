fs = 10000;
span = 20;
t = linspace(0,span,fs*span);

y = sin(2*pi*t.*t/2);

fid = fopen('zap0-20.atf','w');
fprintf(fid,'ATF \t 1.0\n');
fprintf(fid,'1 \t 3\n');
fprintf(fid,'"Comments: fs=%d"\n',fs);
fprintf(fid,'"time (s)"   "amplitude (pA)"   "comment ()"\n');
for i = 1:length(y)
    fprintf(fid,'%f \t %f \t ""\n',t(i),10*y(i));
end

fclose(fid);