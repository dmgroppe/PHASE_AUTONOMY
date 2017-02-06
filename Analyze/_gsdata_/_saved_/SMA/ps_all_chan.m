function [prob_summary, analyzed_list, avgps, w, auc_p] = ps_all_chan(EEG, chtoexcl, alpha, ptname, dosave)

if nargin < 5; dosave = 0; end;
if nargin < 4; ptname = 'vant'; end;

[A] = analysis_lists(ptname);
condlist = {'quiet', 'rest_eo'};
window = EEG.srate*2;

nchan = size(EEG.data,1);

chcount = 0;
for i=1:nchan
    if (isempty(find(i == chtoexcl, 1)))
        fprintf('\n Working on channel %d', i);
        chcount = chcount + 1;
        chlist = [i, i];
        [avgps(:,:,chcount),w, allps, ~, sig] = ps_compare(EEG, condlist, chlist, window, ptname, alpha, 0);
        prob_summary(:,chcount) = fix(get_sig_in_range(A, w, sig)*w(2));
        [auc_p(i,:)] = get_sig_auc(A, w, allps);
        analyzed_list(chcount) = i;
    end
end

if dosave
    path = [get_export_path_SMA() upper(ptname) 'PS' condlist{1} condlist{2} '.mat'];
    save(path, 'avgps', 'prob_summary', 'analyzed_list', 'w', 'auc_p(i)');
end

function [pcount] = get_sig_in_range(A, w, sig)

nfreq = size(A.flist,2);

for i=1:nfreq
    sindex = get_f_index(A.flist(1,i), w);
    eindex = get_f_index(A.flist(2,i), w);
    %pcount(i) = sum(sig(sindex:eindex));
    pcount(i) = get_max_cont(sig(sindex:eindex));
end

% Computes significance between two sets of PS using the area under the
% curce caluclated by simpsons rule
function [p] = get_sig_auc(A, w, pss)

nfreq = size(A.flist,2);
nspectra = size(pss{1},1);

for i=1:nfreq
    sindex = get_f_index(A.flist(1,i), w);
    eindex = get_f_index(A.flist(2,i), w);
    
    for j=1:nspectra
        auc1(j) = auc_simpsons(pss{1}(j,sindex:eindex),0, w(2)-w(1));
        auc2(j) = auc_simpsons(pss{2}(j,sindex:eindex),0, w(2)-w(1));
        
    end
    
    p(i) = ranksum(auc1,auc2);
end

function [oldmaxl]  = get_max_cont(sig)

if (sum(sig) == length(sig) || sum(sig) == 0)
    oldmaxl = sum(sig);
    return;
end

maxl = 0;
oldmaxl = 0;
for i=1:length(sig)
    if abs(sig(i))
        if maxl == 0;
            direc = sign(sig(i));
        end
        
        if direc == sig(i)
            maxl = maxl + 1;
        else
            maxl = 0;
        end
    else
        if maxl > oldmaxl
            oldmaxl = maxl;
        end
        maxl = 0;
    end
end

if maxl
    oldmaxl = sign(direc)*maxl;
end