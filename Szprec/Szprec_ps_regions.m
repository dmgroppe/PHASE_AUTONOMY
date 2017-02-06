function [] = Szprec_ps_regions(varargin)

global SZPREC_CURR_SZ
global SZPREC_CURR_WT
global SZPREC_CURR_T
global SZPREC_CURR_FREQS

if ~exist('SZPREC_CURR_SZ', 'var') || ~exist('SZPREC_CURR_WT', 'var') ||...
    ~exist('SZPREC_CURR_T', 'var')
    return
end

T = SZPREC_CURR_T;
freqs = SZPREC_CURR_FREQS;
sz_name = SZPREC_CURR_SZ;
wt = SZPREC_CURR_WT;
p = abs(wt);

nregions = numel(varargin);
for i=1:nregions
    tind = find(T >= varargin{i}(1) & T <= varargin{i}(2));
    ps(:,i) = squeeze(mean(p(:,tind),2));
end

clf;
plot(repmat(freqs,nregions,1)', ps);

for i=1:nregions
     l{i} = sprintf('%d-%ds', varargin{i}(1), varargin{i}(2));
end
set(gca, 'FontName', 'Times New Roman', 'FontSize', 10);
legend(l);
xlabel('Frequency (Hz)');
ylabel('Power (wavelet)');
set(gcf, 'Name', sz_name);

