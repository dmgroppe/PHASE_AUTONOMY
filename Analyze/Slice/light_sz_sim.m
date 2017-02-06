function [circ_v, circ_m] = light_sz_sim(nsz, sz_isi, sz_var, light_isi, next_sz, is_corr)

if nargin < 6; is_corr = 0; end;


lp = ones(1,nsz)*light_isi;
lp_times = cumsum(lp);

if is_corr
    sz_times = lp_times + abs(rand(1,nsz)*sz_var);
else
    sz = rand(1,nsz)*sz_var + sz_isi;
    sz_times = cumsum(sz);
end

t = [];
for i=1:nsz
    ind = find(sz_times > lp_times(i));
    if ~isempty(ind) && numel(ind) >= next_sz
        %count = count + 1;
        %t(count) = sz_times(ind(next_sz))-lp_times(i);
        t = [t sz_times(ind(1:next_sz))-lp_times(i)];
    end
end

theta  = t/light_isi*2*pi;
%circ_plot(theta,'hist',[],20,true,true,'linewidth',2,'color','r');
circ_m = circ_mean(theta);
circ_v = circ_var(theta);
%ttext = sprintf('Circ mean = %6.2f, Circ var = %6.2f', circ_m, circ_v);
%title(ttext);



