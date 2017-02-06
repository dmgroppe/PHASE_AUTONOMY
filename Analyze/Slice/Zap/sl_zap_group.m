function [R] = sl_zap_group(dap, doplot)

if nargin < 2; doplot = 0; end;

inc_list = zeros(1,numel(dap));

for i=1:numel(dap)
    inc = get_sf_val(dap(i), 'GroupInc');
    if strcmpi(inc, 'yes') || isempty(inc)
        inc_list(i) = 1;
        R(i)= sl_zap(dap(i), doplot);
    end
end

processed = find(inc_list == 1);
if ~isempty(processed)
    R = R(processed);
end

% if doplot
%     zap_plot(R, []);
% end

% sp_freqs_all = [];
% spectra_ind = 0;
% f = min(find(inc_list == 1));
% w = R(f).w;
% zap_peak_edges = R(f).zap_peak_edges;
% Znorm = zeros(1,length(w));
% Z = Znorm;
% 
% zcount = 0;
% spcount = 0;
% for i=1:length(inc_list)
%     if inc_list(i)
%         if ~isempty(R(i).sp_freqs);
%             sp_freqs_all = [sp_freqs_all R(i).sp_freqs];
%             spcount = spcount + 1;
%         else
%             zcount = zcount + 1;
%             Z = Z + R(i).Z;
%             Znorm = Znorm + R(i).Z/max(R(i).Z);
%             spectra_ind = [spectra_ind i];
%         end
%     end
%end



% % See if anything was analyzed if so compute stuff and save the results in
% % S
% 
% if spcount
%     nel = histc(sp_freqs_all, zap_peak_edges);
%     f_centers = mean(reshape(zap_peak_edges,2, numel(zap_peak_edges)/2));
%     p_spike = nel(1:2:length(nel))/spcount;
%     
%     S.spcount = spcount;    
%     S.fcenters = f_centers;
%     S.p_spike = p_spike;
%     S.zap_peak_edges = zap_peak_edges;
%     
% else
%     S.fcenters = [];
%     S.p_spike = [];
%     S.spcount = 0;
%     S.zap_peak_edges = [];
% end
% 
% if zcount
%     Znorm = Znorm/zcount;
%     Z = Z/zcount;
%     
%     S.zcount = zcount;
%     S.Z = Z;
%     S.Znorm = Znorm;
%     S.zcount = zcount;
%     S.w = w;
% 
% else
%     S.Znorm = [];
%     S.Z = [];
%     S.zcount = 0;
%     S.w = [];
% end
% 
% if doplot
%     if spcount
%         clf;
%         subplot(2,1,1);
%         plot(f_centers, p_spike,'.-',  'MarkerSize', 5);
%         axis([0 f_centers(end) 0 1.1]);
%         xlabel('Frequency Hz');
%         ylabel('Spike counts');
%     end
%    
%     if zcount
%         subplot(2,1,2);
%         loglog(w, Znorm);
%         axis([w(1), w(end), ylim]);
%         xlabel('Frequency (Hz)');
%         ylabel('Normalized Z');
%     end    
% end
% 
% 
