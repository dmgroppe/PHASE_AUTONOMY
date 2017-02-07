load('/Users/dgroppe/Desktop/Data/NA_d1_sz2.mat');

%% Define freq bands
bands=[0 4; 4 8; 8 13; 13 30; 30 80; 80 150];


%% Preprocess for plotting
[n_tpt, n_chan]=size(matrix_bi);
srate=500;
secs=[0:(n_tpt-1)]/srate;
clinical_onset=1*60+56;
use_chans=12:30; %just RH
n_use_chans=length(use_chans);
dataV=matrix_bi(:,use_chans);
h_offset=3;
for a=1:n_use_chans,
   dataV(:,a)=dataV(:,a)-mean(dataV(:,a))+a*h_offset; 
end

% Plot seizure onset time-voltage
ylim=[5 55];
xlim=[90 180];
figure(1); 
clf;
plot(secs,dataV,'k'); hold on;
plot([1 1]*clinical_onset,ylim);
xlabel('Seconds');
axis([xlim ylim]);
title('NA d1 sz2, voltage domain');


%% Compute Coh Avg Across All Bands
dataV_mnless=dataV;
for a=1:n_use_chans,
   dataV_mnless(:,a)=dataV_mnless(:,a)-mean(dataV_mnless(:,a));
end
params=[];
wind_len=2;
wind_step=1;
K=8;
TW=(K+1)/wind_len;
params.tapers=[TW K];
% params.K=4;
% params.T=2;
params.Fs=srate;
params.fpass=[0 srate*.4];
for c1=1:n_use_chans,
    fprintf('Working on chan #%d\n',c1);
    for c2=c1+1:n_use_chans,
        %[C,phi,S12,S1,S2,f,windCntrs]=coherencysegcDG(dataV_mnless(:,c1),dataV_mnless(:,c2),params.T,params);
        [C,phi,S12,S1,S2,t,f]=cohgramc(dataV_mnless(:,c1),dataV_mnless(:,c2),[wind_len wind_step],params);
        if c1==1 && c2==2,
            %initialize coh time series
            disp('Initializing Cgrand');
           n_coh_pt=length(t); 
           Cgrand=zeros(n_coh_pt,n_use_chans);
        end
        mnC=mean(C,2);
        Cgrand(:,c1)=Cgrand(:,c1)+mnC;
        Cgrand(:,c2)=Cgrand(:,c2)+mnC;
    end
end
Cgrand=2*Cgrand/(n_use_chans^2-n_use_chans);
disp('Done!');

%%
wind_len=2;
wind_step=1;
% params.K=4;
% params.T=2;
K=4;
TW=(K+1)/wind_len;
params=[];
params.tapers=[TW K];
params.Fs=srate;
params.fpass=[0 srate*.4];
[C,phi,S12,S1,S2,t,f]=cohgramc(dataV_mnless(:,1),dataV_mnless(:,2),[wind_len wind_step],params);
disp('Done!');

%% Plot seizure onset PLV
ylim=[min(min(Cgrand)) max(max(Cgrand))];
xlim=[90 180];
figure(2); 
clf;
plot(t,Cgrand); hold on;
plot([1 1]*clinical_onset,ylim,'k--');
xlabel('Seconds');
axis([xlim ylim]);
title('NA d1 sz2, mean coh');