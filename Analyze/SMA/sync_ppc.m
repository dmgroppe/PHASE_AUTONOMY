function [meana1, meana2, rho, p, bins, mean_phase] = sync_ppc(h1, h2, nbins, only_goodphase, ctype)

if nargin < 5; ctype = 'spearman'; end;
if nargin < 4; only_goodphase = false; end;

a1 = abs(h1);
a2 = abs(h2);

dphi = phase_diff(angle(h1) - angle(h2));

mean_phase = angle(sum(exp(1i*dphi)));
dphi = dphi-mean_phase;
dphi = phase_diff(dphi);

%bins = -pi:2*pi/nbins:pi;
bins = make_phase_bins(nbins);

rho = zeros(1,nbins+1);
meana1 = rho;
meana2 = rho;
p = rho;

if ~only_goodphase
    % Do all the phase bins
    
    for i=1:nbins+1
         indicies{i}= find(dphi> bins(1,i) & dphi < bins(2,i));
    end
    
    for i=1:nbins+1
        % Average amplitude in each phase bin for each oscillation
        if ~isempty(indicies{i})
            [rho(i),p(i), meana1(i), meana2(i)] = get_pdpc(a1,a2, indicies{i}, ctype);
        end
    end
else
    % Just compute the PDPC for the good phase.  Speeds thigs up alot
    % The good phase is the central bin.  nbins had better be an even
    % number!!
    
    ind = nbins/2+1;
    indicies= find(dphi> bins(1,ind) & dphi < bins(2,ind));
    if ~isempty(indicies)
        [rho(ind),p(ind), meana1(ind), meana2(ind)] = get_pdpc(a1,a2, indicies, ctype);
    end  
end

function [rho,p, meana1, meana2] = get_pdpc(a1,a2, indicies, ctype)
p1 = a1(indicies);
p2 = a2(indicies);

meana1 = mean(p1);
meana2 = mean(p2);

% compute the correlation
switch ctype
    case 'spearman'
        [rho, p] = corr(p1',p2','type','Spearman');
    case 'pearson'
        [rho, p] = corr(p1',p2','type','Pearson' );
    otherwise
        [rho, p] = corr(p1',p2','type','Spearman');
end

