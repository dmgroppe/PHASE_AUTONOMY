function [] = doublePulse(p1start, p1dur, delay, rampDur, rampRatio, fs, fname, dosave)

% Function to generate double pulse protocol
% USAGE: doublePulse(p1start, p1dur, delay, rampDur, rampRatio, fs, fname)
%
% p1start   - time to start the square pulse of light
% p1dur     - duration of te square pulse
% delay     - time from first pulse to start of the ramp
% rampDur   - Duration of the ramp
% rampRatio - The ratio of the size of the ramp to the initial square
% pulse.  If this is negative the rap is increases with time.  If positive
% then decreases with time

% Example #1 -  doublePulse(100, 30, 5, 300, 0.5, 10000, 'double_pulse');
% Will plot the reuslting waveform.  The ramp is half the height of the
% initial pulse.
%
% Example #1 -  doublePulse(100, 30, 5, 300, 0.5, 10000, 'double_pulse', 1);
% Will save the cusom waveform to the file double_pulse.abf in the current
% working directory

if nargin < 8; dosave = false; end;

pts = fix([p1start p1dur delay, rampDur]/1000*fs);

y = zeros(1,sum(pts));

y((pts(1)+1):(sum(pts(1:2)))) = 1;

r = linspace(1,0,pts(4))*abs(rampRatio);

% Invert the ramp so that it is increasing with time
if rampRatio < 0
    r = fliplr(r);
end
y((sum(pts(1:3))+1):sum(pts)) = r;
T = (1:length(y))/fs;

if dosave
    fid = fopen([fname '.abf'],'wt');
    fprintf(fid,'ATF \t 1.0\n');
    fprintf(fid,'1 \t 3\n');
    fprintf(fid,'"Comments: fs=%d"\n',fs);
    fprintf(fid,'"time (s)"   "amplitude (V)"   "comment ()"\n');
    for i = 1:length(y)
        fprintf(fid,'%f \t %8.6f \t ""\n',T(i),y(i));
    end

    fclose(fid);
else
    plot(T*1000,y);
    xlabel('Time (ms)');
    ylabel('Arbitrary units');
end