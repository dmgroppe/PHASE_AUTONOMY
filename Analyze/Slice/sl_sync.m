function [pc phi] = sl_sync(wt, T, ap, dap, srate)

[nfreq, npoints, nchan] = size(wt);

if nchan < 2
    error('Not enough channels.');
end

tic
pdiff = exp(1i*(angle(wt(:,:,1)) - angle(wt(:,:,2))));

toc

wp = fix((1./(ap.wt.freqs))*ap.sync.ncycle*srate);

parfor i=1:nfreq
    [pc(i,:) phi(i,:)] = sync(pdiff(i,:),i,npoints,wp);
end

% figure(1);
% [~, pc_npoints] = size(pc);
% surf(T(1:pc_npoints), ap.wt.freqs, pc);
% view(0,90);
% shading interp
% set(gca, 'YScale', 'log', 'YMinorTick', 'on', 'TickDir', 'out');
% yvals = get(gca,'YTickLabel');
% set(gca,'YTickLabel',  10.^str2num(yvals));

end

function [pc phi] = sync(pdiff, i, npoints, wp)
    pc = zeros(1,npoints-wp(1));
    phi = zeros(1,npoints-wp(1));
    for j=1:npoints-wp(1)
        m = mean(pdiff(j:(j+(wp(i)-1))));
        pc(j) = abs(m);
        phi(j) = angle(m);
    end
end


