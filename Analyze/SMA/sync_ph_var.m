function [R] = sync_ph_var(h1, h2, nbins, ctype, ys)

% Phase-dependant correlations to an arbitrary variable if passed to ys, or
% to power.  If only one ys is passed the mean amplitude of that variable
% as function of phase is placed within rho.

if nargin < 5
    a1 = abs(h1);
    a2 = abs(h1);
else
    
    % if only one time series is passed for the correlation just correlate
    % to that variable
    if size(ys,1) == 1
        a1 = ys;
        a2 = [];
        ny = 1;
    else
        ny = 2;
        a1 = ys(1,:);
        a2 = ys(2,:);
    end
end

if nargin < 4; ctype = 'spearman'; end;

dphi = phase_diff(angle(h1) - angle(h2));

R.mean_phase = angle(sum(exp(1i*dphi)));
dphi = dphi-R.mean_phase;
dphi = phase_diff(dphi);

%bins = -pi:2*pi/nbins:pi;
bins = make_phase_bins(nbins);

for i=1:nbins+1
     indicies{i}= find(dphi> bins(1,i) & dphi < bins(2,i));
     R.counts(i) = numel(indicies{i});
end

R.rho = zeros(1,length(nbins+1));
R.meana1 = R.rho;
R.meana2 = R.rho;
R.p = R.rho;

for i=1:nbins+1
    if ~isempty(indicies{i})
        if ny == 2
    
            p1 = a1(indicies{i});
            p2 = a2(indicies{i});

            R.meana1(i) = mean(p1);
            R.meana2(i) = mean(p2);

            % compute the correlation
            switch ctype
                case 'spearman'
                    [R.rho(i), R.p(i)] = corr(p1',p2','type','Spearman');
                case 'pearson'
                    [R.rho(i), R.p(i)] = corr(p1',p2','type','Pearson' );
                otherwise
                    [R.rho(i), R.p(i)] = corr(p1',p2','type','Spearman');
            end
        else
            % Here only one variable was passed for so just average its value
            % over the phase indicies
            
            R.rho(i) = mean(a1(indicies{i}));
            R.mean1(i) = R.rho(i);
            R.p(i) = 0.5;
        end 
    else
        R.meana1(i) = 0;
        R.meana2(i) = 0;
        R.rho(i) = 0;
        R.p(i) = 1;
    end
end