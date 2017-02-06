function [] = time_evolution(EEG, ch, normcond)

ap = sync_params();
scales = linear_scale(ap.freqs, EEG.srate);

x = EEG.data(ch,:);
npoints = length(x);

[tstart tend] = get_trange(normcond, ap.length);
subr = get_subregion(EEG, tstart, tend);
xnormcond = subr(ch,:);
xncwt = twt(xnormcond, EEG.srate, scales, ap.wnumber);
ncavg = mean(abs(xncwt),2);
%ncstd = std(abs(xncwt),1, 2);

T = ((1:npoints)-1)/EEG.srate*1000; % Time in ms

wt = twt(x, EEG.srate, scales, ap.wnumber);
sgram = abs(wt)./repmat(ncavg,1, npoints);

h = figure(1);
set(gcf, 'Renderer', 'zbuffer');
colormap hot;
%sgram = 10*log10(sgram);

%for i=1:length(ap.freqs);
%    sgram(i,:) = smooth(sgram(i,:),500);
%end

surf(T,ap.freqs,sgram);
shading interp;
if ~isempty(ap.yaxis)
    axis([0 T(end) ap.freqs(1) ap.freqs(end) ap.yaxis]);
else
    ymax = max(max(sgram));
    ymin = min(min(sgram));
    axis([0 T(end) ap.freqs(1) ap.freqs(end) ymin ymax]);
end
    
view(0,90);
colorbar;

fprintf('\nMax =%e, Min = %e\n', ymax, ymin);



 
