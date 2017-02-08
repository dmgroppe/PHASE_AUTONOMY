%Szprec_run(list)

%%
global DATA_DIR;
DATA_DIR='/Users/dgroppe/ONGOING/TWH_DATA';

%DG added
global ONSET_DIR;
ONSET_DIR='/Users/dgroppe/Desktop/Dropbox/TWH_INFO/ONSET_TIMES_CLINICAL/';

list={'NA'};

%%
Szprec_process(list); % Computes phase fluctuations at 6 frequency bands for all channels and makes some figures


%%
Szprec_rankts_process(list);


%%
chan=1;
figure(10); clf;
subplot(131);
hist(f(:,chan),100);
ylabel('Bin Counts');
xlabel('Raw max F');

subplot(132);
hist(log(f(:,chan)),100);
xlabel('log(max F)');

subplot(133);
hist(lf(:,chan),100);
xlabel('asin_trans(max F)');