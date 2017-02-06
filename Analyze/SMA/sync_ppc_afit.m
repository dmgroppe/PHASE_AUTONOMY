function [Rbd, Rud, R, xfit] = sync_ppc_afit(tf1, tf2, ap)

n_timeseries = size(tf1,1);
nbins = ap.ppc.nbins;
ctype = ap.ppc.ctype;
[~,x] = make_phase_bins(ap.ppc.nbins);

parfor i=1:n_timeseries
    [~, ~, rho(i,:), ~, ~, mean_phase(i)] = sync_ppc(tf1(i,:), tf2(i,:), nbins, ctype);
end

freqs = ap.freqs;
xfit = -pi:ap.ppc.xfit_inc:pi;

for i=1:n_timeseries
    [Rbd(i).beta,Rbd(i).resid,Rbd(i).J,Rbd(i).COVB,Rbd(i).mse] = nlinfit(x,rho(i,:),@ff_bidir, [0.5, 0.5, mean_phase(i), freqs(i)]);
    [Rud(i).beta,Rud(i).resid,Rud(i).J,Rud(i).COVB,Rud(i).mse] = nlinfit(x,rho(i,:),@pdpc, 0.5);
    
    Rbd(i).fit = ff_bidir(Rbd(i).beta, xfit);
    Rud(i).fit = pdpc(Rud(i).beta, xfit);  
end

R.rho = rho;
R.mean_phase = mean_phase;
