function [R] = bs_phpinfo_corr(wt1, wt2, adtf_fwd, adtf_bkwrd, A1, A2, ap)

% Computes the significance of the phase-dependant power-information
% correlations using bootstrap techniques and FDR correction

ctype = ap.ppc.ctype;
nbins = ap.ppc.nbins;
npoints = length(wt1);
[~,xbins] = make_phase_bins(ap.ppc.nbins);

% Compute the actual pdpinfo correlations

tic
[R.fwrd_depth, R.bkwrd_depth] = get_corr(wt1,wt2,adtf_fwd, adtf_bkwrd, A1, A2, ctype, xbins, nbins,ap);
ctime = toc;

% Get an estimate of how long it's going to take
mp = (matlabpool('size'));
if ~mp
    mp = 1;
end
    
est_time = ctime*ap.nsurr/60/mp;
display(sprintf('Estimated time to complete stats = %4.2f  minutes.', est_time));

% Compute the surrogates for the the phase-dependant power-information correlation
parfor i=1:ap.nsurr
    sshift = floor(0.5*rand*npoints)+1;
    surr_A1 = [A1(:,sshift:end) A1(:,1:sshift-1)];
    sshift = floor(0.5*rand*npoints)+1;
    surr_A2 = [A2(:,sshift:end) A2(:,1:sshift-1)];
    [surr_fwrd_depth(i,:), surr_bkwrd_depth(i,:)] = get_corr(wt1,wt2,adtf_fwd, adtf_bkwrd, surr_A1, surr_A2,...
        ctype, xbins, nbins, ap);
end

fwrd_count = zeros(1, length(ap.freqs));
bkwrd_count = zeros(1, length(ap.freqs));

% Count
for i=1:ap.nsurr
    fwrd_count = fwrd_count + (surr_fwrd_depth(i,:) > R.fwrd_depth);
    bkwrd_count = bkwrd_count + (surr_bkwrd_depth(i,:) > R.bkwrd_depth);
end

% Compute the probabilities from the counts

R.p_fwrd = (fwrd_count + 1)/(ap.nsurr + 1);
R.p_bkwrd = (bkwrd_count + 1)/(ap.nsurr + 1);

% Compute the phase-dependant power-information correlation

function [fwrd_depth, bkwrd_depth] = get_corr(wt1,wt2,adtf_fwd, adtf_bkwrd, A1, A2, ctype, xbins, nbins, ap)

nfreqs = size(wt1,1);
freqs = ap.freqs;
ftype = ap.pdpi.fit_type;


parfor i=1:nfreqs
    warning off all;
    fwrd = sync_ph_var(wt1(i,:), wt2(i,:), nbins, ctype, [A1(i,:)' adtf_fwd(i,:)']');
    bkwrd = sync_ph_var(wt2(i,:), wt1(i,:), nbins, ctype, [A2(i,:)' adtf_bkwrd(i,:)']');
    
    if strcmpi(ftype,'cos');
        beta = nlinfit(xbins,fwrd.rho,@cos_fit, [0 0.5]);
        fwd_fit = cos_fit(beta, xbins);
        beta = nlinfit(xbins,bkwrd.rho,@cos_fit, [0 0.5]);
        bkwrd_fit = cos_fit(beta, xbins); 
    else
        beta = nlinfit(xbins,fwrd.rho,@ff_bidir, [0.5, 0.5,  fwrd.mean_phase, freqs(i)]);
        fwd_fit = ff_bidir(beta, xbins);
        beta = nlinfit(xbins,bkwrd.rho,@ff_bidir, [0.5, 0.5,  bkwrd.mean_phase, freqs(i)]);
        bkwrd_fit = ff_bidir(beta, xbins); 
    end
    
    % Compute the depth of the fit
    fwrd_depth(i) = max(fwd_fit) - min(fwd_fit);
    bkwrd_depth(i) = max(bkwrd_fit) - min(bkwrd_fit);
end