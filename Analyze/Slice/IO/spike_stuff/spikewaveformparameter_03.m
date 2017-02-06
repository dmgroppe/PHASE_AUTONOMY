function [W, X, par] = spikewaveformparameter_03(cfg,waves)

% --- aligns and upscales waveforms
% --- extract parameters of waveform
% --- waves is a n*m (nWaveforms *waveformsamples) matrix
%waves = res(c).wav

if ~isfield(cfg, 'troughalign'),    cfg.troughalign = 1;    end
if ~isfield(cfg, 'peakalign'),      cfg.peakalign = 0;      end
if ~isfield(cfg, 'interpn'),        cfg.interpn = 0;        end
if ~isfield(cfg, 'dowfparam'),      cfg.dowfparam = 1;      end
if ~isfield(cfg, 'normalize'),      cfg.normalize = 1;      end
if ~isfield(cfg, 'fsample'),        cfg.fsample = 40000;      end


[nw nsmpl] = size(waves);
W = waves;
X = 0:nsmpl-1;


if cfg.troughalign %| cfg.peakalign
    % --- make new xscale (as short as possible)

    if cfg.troughalign
        [a,b]=min(waves');
    elseif cfg.peakalign
        [a,b]=max(waves');
    end

    lenL = -max(b)*2; lenR =nsmpl+max(b);
    X = [lenL:lenR];
    c = find(X==0);

    % --- shift waves trough to zero
    W= zeros(nw,length(X))+NaN;
    for k=1:nw
        [a,ind]=min(waves(k,:));
        W(k,c-ind:c+nsmpl-ind-1) = waves(k,:);
    end
end

% --- get x axis right before upscaling and parameter extraction
X = X .* 1/(cfg.fsample*0.001);

% --- upscale by linear interpolation
if cfg.interpn>0
    xn = linspace(X(1), X(end), length(X)*cfg.interpn);
    Wn= zeros(nw,length(xn));
    warning off
    for k=1:nw
        Wn(k,:) = interp1(X,W(k,:),xn);
    end,
    warning on
    W = Wn;
    X = xn;
end



% --- normalize amplitude ratio
if cfg.normalize,
    for j=1:size(W,1)
        W(j,:)= [W(j,:)./ diff(minmax(W(j,:)))*2.0];
        W(j,:) = W(j,:) + diff([min(W(j,:)) -1]);
    end
end


zeroInd = nearest(X,0);

% --- extract waveform parameter
if cfg.dowfparam

    [nw nsmpl] = size(W);

    par = zeros(nw,4)+NaN;
    % --- ar will contain:
    % ---  spike duration
    % ---  half amplitude duration
    % ---  peakTroughAmp

    for j=1:nw

        par(j,1:9) = NaN;
        cW = W(j,:);

        if ~any(~isnan(cW)), continue, end

        % ... find turning points: max and min after threshold crossing
        td = diff(cW);
        td = td(1:(end-1))<0 & td(2:end)>0;
        td = [0 td 0];
        tr = cW < nanmean(cW);
        idown = find(td & tr);
        % --- if more change points: select one after the initial 5 samples
        if length(idown) > 1,
            %tmp=find(idown>5);
            %idown = idown(idown>5);
            %[a,b]=min(cW(idown)); %select the global minimum
            %idown = idown(ceil(length(b)*0.5)); %idown = idown(b); 
            idown = idown(nearest(idown,zeroInd));
        end

        td = diff(cW);
        td = td(1:(end-1))>0 & td(2:end)<0;
        td = [0 td 0];
        tr = cW>nanmean(cW);
        iup = find(td & tr);
        iup  = iup(iup>idown);
        % --- if more change points: select the one after idown
        if length(iup)>1,
            [a,b]=max(cW(iup));
            iup = iup(ceil(length(b)*0.5)); %iup = iup(b); 
        end

if isempty(iup) | isempty(idown), continue, end,        
        
        % maximum rate of fall/maximum rate of rise
        % differentiate first:
                
        wdiff = diff(cW,1); %last ind is original ind-1
        %find the global minimum before the action potential through
        maxrise = min(wdiff(1:idown));
        %find the global maximum after the action potential through
        %maxfall = max(wdiff(idown+1:end));
        maxfall = max(wdiff(idown+1:iup));
        
        risefallratio = maxfall/maxrise;
        
        %[maxriseinds] = findlocalminima(wdiff); %maximum rise ind and val
        %maxriseinds = maxfallinds(maxriseinds<idown);
        %[maxrise] = min(wdiff(maxriseinds));  
        %[maxfallinds] = findlocalmaxima(wdiff); %maximum rise ind and val
        %maxfallinds = maxfallinds(maxfallinds<idown);
        %[maxfall] = min(wdiff(maxfallinds));
                
        % --- assign: duration peak-to-trough
        %par(j,1) = abs(diff([idown iup]));
%if isempty(iup) |isempty(idown)
%        keyboard
%end
par(j,1) = abs(diff([X(idown) X(iup)]));
        
        % --- assign: ratio of hyperpolarisation (baseline-down) to depolarisation amplitude (whole amplitude) 
        hypind = min([iup idown]);
        tmp = find(~isnan(cW));
        par(j,2) = (abs(diff([cW(tmp(1)) cW(hypind)])) ./ abs(diff([cW(idown) cW(iup)])));
        
        % --- assign: half-amplitude of hyperolristion to half ampkitude
        % --- back on depolarisation flank
        hypind = min([iup idown]);
        tmp = find(~isnan(cW));
        halfampval = diff([cW(tmp(1)) cW(hypind)])*0.5;
        %firstind = nearest([cW(tmp(1):hypind)], diff([cW(tmp(1)) cW(hypind)])*0.5);
        firstind = nearest([cW(1:hypind)], halfampval);
        secondind = hypind+nearest([cW(hypind:end)], halfampval);
        par(j,3) = abs(diff([X(firstind) X(secondind)]));

        % --- assign: duration from half amplitude hyperpolarisation to peak depolarisation
        hypind = min([iup idown]);
        tmp = find(~isnan(cW));
        halfampind = nearest([cW(tmp(1):hypind)], diff([cW(tmp(1)) cW(hypind)])*0.5);
        depind = max([iup idown]);
        %par(j,2) = abs(diff([halfampind depind]));
        par(j,4) = abs(diff([X(halfampind) X(depind)]));
        
        par(j,5) = risefallratio;
        par(j,6) = maxfall;
        par(j,7) = maxrise;
        %find the global maximum after the action potential through

        
        % --- assign: abs baseline to hyperpolarisation (baseline-down)  
        A = max(cW(1:idown));
        par(j,8) = abs(diff([A,cW(idown)]));
            
        % --- assign: abs baseline to depolarisation (baseline-up)  
        A = max(cW(1:idown));
        par(j,9) = abs(diff([A,cW(iup)]));

        
        
        % --- assign: ratio of baseline to trough VS baseline to peak
        % absPeakTrough = abs(diff([cW(iup) cW(idown)]));
        % tmp = find(~isnan(cW));
        % if ~isempty(tmp)
        %    absBaseTrough = abs(diff([cW(tmp(1)) cW(idown)]));
        %    par(j,3) = abs(diff([cW(iup) cW(idown)]));
        % else
        %    par(j,3) = NaN;
        % end
    end

end




% if isempty(find(dat ~= 0)), return, end
%
% % cfg = [];
% % cfg.method = 'duration'
% % dat = data.waves{1}'
% % --- peak to trough amplitude
% peakTroughAmp = abs(diff([dat(iup) dat(idown)]));
% %peakTroughAmp% (end+1)  = abs(diff([dat(iup) dat(idown)]));
%
% % --- duration from half amplitude hyperpolarisation to peak depolarisation
% hyperpolind = min([iup idown]);
% depolind = max([iup idown]);
% endind = 5;
% startInd = (nearest(dat(endind:hyperpolind), abs(diff([dat(hyperpolind) mean(dat(1:endind))])) * 0.5));
% duration = abs(diff([startInd depolind]));
% %(end+1
% % --- half amplitude
% durationhalfAmp = [];
%
%
% % return
% %
% % % --- est is via OCnrado and mikhem
% %
% % x1 = linspace(0,800,32);
% %
% %
% %
% %
% % dat_s.Waveparameter.HalfAmp_Duration = [];
% % dat_s.Waveparameter.SpikeDuration = [];
% % dat_s.Waveparameter.HalfAmp2PeakDur = [];
% % dat_s.Waveparameter.RepHalfAmp2PeakDur = [];
% %
% %
% %
% % % changed to discard already negative ones (setting them to NaN)
% %
% %
% % %load all_V4_attIn_wf.mat
% % dat_s.wfnrm = cell(1,length(dat_s.wf));
% dat_s.intwfnrm = cell(1,length(dat_s.wf));
% dat_s.alignwf = cell(1,length(dat_s.wf));
% x1 = linspace(0,800,32);
% x2 = linspace(0,800,160);
% dat_s.Waveparameter.HalfAmp_Duration = [];
% dat_s.Waveparameter.SpikeDuration = [];
% dat_s.Waveparameter.HalfAmp2PeakDur = [];
% dat_s.Waveparameter.RepHalfAmp2PeakDur = [];
%
%
% for k = 1:length(dat_s.wf);
%
%     if isempty(dat_s.wf{k})
%         dat_s.Waveparameter.HalfAmp_Duration(k) = NaN;
%         dat_s.Waveparameter.SpikeDuration(k) = NaN;
%         dat_s.Waveparameter.HalfAmp2PeakDur(k) = NaN;
%         dat_s.Waveparameter.RepHalfAmp2PeakDur(k) = NaN;
%         continue
%     end
%
%     dat_s.wfnrm{k} = repmat(NaN,32,1);
%     absdif = abs(max(dat_s.wf{k})) + abs(min(dat_s.wf{k}));
%     dat_s.wfnrm{k}(1:length(dat_s.wf{k})) = dat_s.wf{k} ./absdif ;
%
%
%     %Interpolate from 32 samples to 160 samples (that is
%     %from 25 usec/sample to 5 usec/sample
%     dat_s.intwfnrm{k} = interp1(x1,dat_s.wfnrm{k},x2);
%
%     % ------- Get the Spike-Duration (Mike: This is in essence your code)
%     [Maximum max_index] = max(dat_s.intwfnrm{k});
%     [Minimum min_index] = min(dat_s.intwfnrm{k});
%     SpikeDuration = diff([min_index max_index]);% Substract the min_index from the max_index and get the Spikeduration in Samples.
%
%     SpkDurusec = SpikeDuration * 5; %to get in usec according to our new samplingrate
% % --- tw added
%     if SpkDurusec>0
%     dat_s.Waveparameter.SpikeDuration(k) = SpkDurusec;
% else
%     dat_s.Waveparameter.SpikeDuration(k) = NaN;
% end
%     % ---------- Get the Half Amplitude Duration
%     start_index = nearest(x2,100); % Index in which spike starts
%
%     % Defining the HalfValue
%     if dat_s.intwfnrm{k}(start_index) < 0
%         AproxHalfValue = abs(Minimum) - dat_s.intwfnrm{k}(start_index);
%     else
%         AproxHalfValue = abs(Minimum) + dat_s.intwfnrm{k}(start_index);
%     end
%
%     AproxHalfValue = - AproxHalfValue/2;
%
%     %Then split the data
%     Fst_p = dat_s.intwfnrm{k}(start_index:min_index);
%     Snd_p = dat_s.intwfnrm{k}(min_index+1:end);
%
%
%     %Get indexes
%     FstHalfIndex = nearest(Fst_p,AproxHalfValue);
%     SndHalfIndex = nearest(Snd_p,AproxHalfValue);
%
%     %Get the duration
%     dat_s.Waveparameter.HalfAmp_Duration(k) = x2(min_index+SndHalfIndex) - x2(start_index+FstHalfIndex);
%
%     % ---------------- Get the 1st Half Amplitude to Peak Duration
%     %just one line of code!!!!
%     %dat_s.Waveparameter.HalfAmp2PeakDur(k) = x2(max_index) - x2(start_index+FstHalfIndex);
%     HalfAmp2Peak = diff([(start_index+FstHalfIndex) max_index]);
%     dat_s.Waveparameter.HalfAmp2PeakDur(k) = HalfAmp2Peak*5;
%
%     %Get 2nd Half Amplitude (repolarization) to Peak
%     %fist, get the value when repolarization start (crossing zero)
%    [Maximum2 max_index2]=max(Snd_p);
%    max_index2=min_index+max_index2;
%    %new split
%    Trd_p = dat_s.intwfnrm{k}(min_index+1:max_index2);
%
%    SndHalfAmplVal = Maximum2/2;
%    if SndHalfAmplVal<0 %discard aberrant waveforms
%        dat_s.Waveparameter.HalfAmp_Duration(k) = NaN;
%        dat_s.Waveparameter.SpikeDuration(k) = NaN;
%        dat_s.Waveparameter.HalfAmp2PeakDur(k) = NaN;
%        dat_s.Waveparameter.RepHalfAmp2PeakDur(k) = NaN;
%        continue
%    end
%
%    SndHalfAmpl_index = nearest(Trd_p, SndHalfAmplVal);
%    SndHalfAmpl_index = min_index + SndHalfAmpl_index;
%    dat_s.Waveparameter.RepHalfAmp2PeakDur(k) = x2(max_index2) - x2(SndHalfAmpl_index);
%    if dat_s.Waveparameter.RepHalfAmp2PeakDur(k)<0
%        error('negative value!!!')
%    end
%
% %alignment to the trough
% dat_s.alignwf{k} = repmat(NaN,300,1);
% dat_s.alignwf{k}(100-(min_index-1):100+(160-min_index))=dat_s.intwfnrm{k};
% x3=linspace(-100,200,300);
% end
%
%
%
% if 0
% %plotting
% %close all
% figure
% subplot 221
% hold on
% for k = 1:length(dat_s.wf);
%
%     if isempty(dat_s.intwfnrm{k}), continue, end
%     plot(x2,dat_s.intwfnrm{k})
%     xlabel('Time (\musec)')
%     title('Butterfly plot')
%
% end
%
% subplot 223
% hold on
% for k = 1:length(dat_s.wf);
%
%     if isempty(dat_s.alignwf{k}), continue, end
%     plot(x3,dat_s.alignwf{k})
%     xlabel('Time (\musec)')
%     title('Spikes Align to the through')
%
% end
%
%
% hold off
%
% subplot 222
% plot(dat_s.Waveparameter.SpikeDuration,dat_s.Waveparameter.RepHalfAmp2PeakDur,'or')
% xlabel('SpikeDur (\musec)')
% ylabel('2nd Half Amplitude to Peak Duration (\musec)')
%
% subplot 224
% plot(dat_s.Waveparameter.SpikeDuration,dat_s.Waveparameter.HalfAmp_Duration,'or')
% xlabel('SpikeDur (\musec)')
% ylabel('Half Amplitude Duration (\musec)')
%
%
% end

function [y] = findlocalmaxima_local(x)
y = find(diff(sign(diff([-inf x -inf])))<0);

function y = findlocalminima_local(x)
y = find(diff(sign(diff([inf x inf])))>0);



