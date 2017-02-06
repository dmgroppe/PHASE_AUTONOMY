function [dphi] = phase_analysis(EEG, ch, frange, cond, peaks, widths, tol)

%eDir = 'D:\Projects\Data\Vant\Figures\Phase Histograms\';

[tstart tend] = get_trange(cond, 60);
subr = get_subregion(EEG, tstart, tend);

% Create the filter
%Hd = bpfilter(frange(1), frange(2), EEG.srate);

% h1 = hilbert(tfilter(subr(ch(1),:), Hd));
% h2 = hilbert(tfilter(subr(ch(2),:), Hd));

h1 = hilbert(eegfilt(double(subr(ch(1),:)),EEG.srate, frange(1), frange(2)));
h2 = hilbert(eegfilt(double(subr(ch(2),:)),EEG.srate, frange(1), frange(2)));

dphi = (angle(h1) - angle(h2))/2;
dphi = phase_diff(dphi).*sign(dphi);

%[pval ~] = circ_rtest(dphi+pi);
%fprintf('\nRayleigh test: p = %7.5f, mean angle = %6.4f degrees\n', pval, angle(sum(exp(1i*dphi)))/(2*pi)*360);

npeaks = length(peaks);
nwidths = length(widths);
npoints = length(h1);

if (npeaks ~= nwidths)
    display('Number of peaks does not equal number of widths.')
    return;
end

% h = figure(1);
%plot(unwrap(udphi));

udphi = unwrap(dphi);

h = figure(1);
set(h, 'Name', 'Length distrribution: Monotonically increasing');
[~, mi_lengths, mi_segments] = get_segments(udphi, @mi_rule, 2, tol);
hist(mi_lengths,1:40);


h = figure(2);
set(h, 'Name', 'Montonically decreasing: length distribution');
[~, md_lengths, md_segments] = get_segments(udphi, @md_rule, 2, tol);
hist(md_lengths,1:40);

h = figure(3);
set(h, 'Name', 'Constant: length distribution ');
[~, c_lengths, c_segments] = get_segments(udphi, @md_rule, 2, tol);
hist(c_lengths,1:40);






% [selected] = segments_of_length(segments, lengths, 17);
% figure(1);
% hold on;
% for i=1:length(selected)
%     plot(selected(:,i), udphi(selected(:,i)), 'or');
% end
% hold off



function [nlcount, lengths, segments] = get_segments(dphi, rule, minpts, tol)
pcount = 2;
nlcount = 0;
lcount = 0;
npoints = length(dphi);
while pcount < npoints
    if rule(dphi(pcount-1), dphi(pcount), tol)
        if ~lcount
            sstart = pcount-1;
        end
        lcount = lcount + 1;
    else
        if (lcount >= minpts)
            nlcount = nlcount + 1;
            lengths(nlcount) = lcount;
            send = sstart + lcount;
            segments(:,nlcount) = [sstart, send];
        end
        lcount = 0;
    end
    pcount = pcount + 1;
end

function [r] = md_rule(p1, p2, tol)

if (p1 - p2) >= tol
    r = 1;
else
    r = 0;
end

function [r] = mi_rule(p1, p2, tol)

if (p2 - p1) >= tol
    r = 1;
else
    r = 0;
end

function [r] = const_rule(p1, p2, tol)

if abs(p1 - p2) < tol
    r = 1;
else
    r = 0;
end

function [selected] = segments_of_length(segments, slengths, slength)

scount = 0;
for i = 1:length(segments)
    if (slengths(i) == slength)
        scount = scount + 1;
        selected(:,scount) = segments(:,i);
    end
end

function [] = plot_segments(segments, udphi)

for i=1:length(segments)
    zsegments = udphi(segments(:,i) - segments(1,i));
end

segmean = mean(zsegments,2);






