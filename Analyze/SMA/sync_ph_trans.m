function [] = sync_ph_trans(EEG, channels, ptname, cond, frange)

% Computes the Gamma function according to the paper by Battaglia 2012 that
% is the phase-space description of the dphi as measure of
% symmetry-breaking activity between two populations of neurons

ap = sync_params();
ap.sync.lowcut = frange(1);
ap.sync.highcut = frange(2);


x = data_retrieve(EEG, cond, ap.length, ptname);
x = x(channels,:);
xh = hilberts(x, EEG.srate, ap);
xa = angle(xh);

% Compute the phase differences
dphi = phase_diff(xa(1,:) - xa(2,:));

% Point-by-point derivative of the phase differences - might have to do
% something more sophisticated here like a linear fit to a number of points
dpdt = dphi(3:end) - dphi(2:end-1);
dphi = dphi(3:end);

w = ap.phtrans.dwin; % Number of points over which t 
X = [ones(1,ap.phtrans.dwin)', (1:w)'];

for i=1:length(dphi)-w
    y = dphi(i:i+w-1);
    [b,~,~,~,~] = regress(y',X);
    dpdt(i) = b(2);
end

[bins, xbins] = make_phase_bins(ap.phtrans.nbins);

for i=1:length(bins)
    k = find(dphi >= bins(1,i) & dphi < bins(2,i));
    dpdt_vals{i} = dpdt(k);
    dpdt_means(i) = mean(dpdt(k));
end

figure(1);
plot(xbins, dpdt_means, '.', 'MarkerSize', 15);
xlabel('dphi (rads)');
ylabel('Gamma(dphi)');

figure(2);
plot(dphi, dpdt,'.', 'MarkerSize', 2);
ylabel('dpdt');
xlabel('dphi');








