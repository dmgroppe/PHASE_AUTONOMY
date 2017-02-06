function [] = sync_nmpl(EEG, ch, cond, ap)

[tstart tend] = get_trange(cond, ap.length, ap.ptname);
subr = get_subregion(EEG, tstart, tend);
subr = subr(ch,:);

x = subr(1:10000);

rg = (-500:500)';
sigmas = exp(log(2):.3:log(20000));
gabors = exp(-.5*(rg.^2)*sigmas.^(-2)).*cos(rg*sigmas.^(-1)*2*pi*2);

[ws,r] = temporalMP(x,gabors,false,10000);

t = 1:10000;

subplot(2,1,1);
plot(t,x, t, r);

subplot(2,1,2);
imagesc(conv2(ws,exp(-rg.^2/2/20^2),'same')');
%view(0,90);
shading interp;





% d1 = window_FIR(ap.nmpl.lowf(1), ap.nmpl.lowf(2), EEG.srate);
% d2 = window_FIR(ap.nmpl.highf(1), ap.nmpl.highf(2), EEG.srate);
% 
% 
% filt1 = filtfilt(d1.Numerator,1, subr);
% 
% if ap.surr
%     filt2 = filtfilt(d2.Numerator,1, rand_rotate(subr));
% else
%     filt2 = filtfilt(d2.Numerator,1, subr);
% end
% 
% a1 = unwrap(angle(hilbert(filt1)))/(2*pi);
% a2 =  unwrap(angle(hilbert(filt2)))/(2*pi);
% 
% 
% for n=1:length(ap.nmpl.n)
%     parfor m = 1:length(ap.nmpl.m)
%         pl(m,n) = pcoh((ap.nmpl.n(n)*a1 - ap.nmpl.m(m)*a2));
%     end
% end
% 
% surf(ap.nmpl.n, ap.nmpl.m, pl);
% shading flat;
% view(0,90);
% 
% function [R]= pcoh(dphi)
% 
% npoints = length(dphi);
% 
% ssum = sum(sin(dphi));
% csum = sum(cos(dphi));
% R = sqrt((ssum/npoints)^2 + (csum/npoints)^2);


