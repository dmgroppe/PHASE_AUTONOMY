function [] = ridge_stats(c1, c2, frq, params)

frq_ranges = franges();

[nfrq npoints nspectra] = size(c1);
bl_samples = time_to_samples(params.ana.baseline, params.data.srate);
x = get_x(npoints, params.data.srate);
bwidthsamples = time_to_samples(params.stats.tbin_width, params.data.srate);

%Contains arrays of the freq indicies at which a ridge was detected
ridges = cell(2, nspectra);

for i=1:nspectra
    ridges{1,i} = get_ridges(c1(:,:,i), frq, params);
    ridges{2,i} = get_ridges(c2(:,:,i), frq, params);
end

% Ridge Data - contains only the ridges of data
rd = cell(2,nspectra);
%figure(20);
for i = 1:nspectra
    rd{1,i} = ridge_data(c1(:,:,i), ridges{1,i});
    %surf(x, frq, rd{1,i});
    %view(0,90);
    %shading interp;
    rd{2,i} = ridge_data(c2(:,:,i), ridges{2,i});
    %surf(x, frq, rd{2,i});
    %view(0,90);
    %shading interp;
end

m = cell(2,nspectra);
for i=1:length(frq_ranges)
    lb = frq_ranges(i).lb;
    ub = frq_ranges(i).ub;
    
    fstart = get_index(frq, lb);
    fend = get_index(frq, ub);
    
    
    for j=1:nspectra
        % Only Ridges that are in the range are averaged
        rrindex = find(frq((ridges{1,j}) >= lb & frq(ridges{1,j}) <= ub));
        m{1,j} = average_range(rd{1,j}, ridges{1,j}, rrindex);
        rrindex = find(frq((ridges{2,j}) >= lb & frq(ridges{2,j}) <= ub));
        m{2,j} = average_range(rd{2,j}, ridges{2,j}, rrindex);
    end
    
    for j=1:nspectra
        binned1(:,:,j) = bin_time_series(m{1,j}(:,(bl_samples+1):end), bwidthsamples);
        binned2(:,:,j) = bin_time_series(m{2,j}(:,(bl_samples+1):end), bwidthsamples);
    end
    
    nbins = size(binned1,2);
    b1 = reshape(binned1,nbins,nspectra)';
    b2 = reshape(binned2,nbins,nspectra)';
    
    % Combine the time bins and conditions for permutation ANOVA
    for j=1:nspectra
        index = (j-1)*nbins+1;
        M(index:j*nbins) = b1(j,:);
    end
    for j=(nspectra+1):2*nspectra
        index = (j-1)*nbins+1;
        M(index:j*nbins) = b2(j-nspectra,:);
    end
    
    [test,prob,thresh] = perm_anova(M', nspectra, nbins, 2, 1000, .05);
    result = sprintf('%s (%3.1f-%3.1f): p = %6.2f', frq_ranges(i).Name, frq(fstart), frq(fend), prob);

    dplot = [mean(b1);mean(b2)]';
    errors = [std(b1); std(b2)]'/sqrt(nspectra);
    
    if (~(min(min(dplot) == max(max(dplot)))))
        subplot(length(franges), 1, i);
        barweb(dplot, errors);
        %bar(dplot', 'group');
        title(result);
        xlabel('Time bin');
        ylabel('Norm to BL');    
    end
end

%  Get the ridges from peaks in the spectra ------------------------------
function [ridges] = get_ridges(d, frq, params)

[nfrq npoints nspectra] = size(d);
rt = find_peaks(d, params.ridges.per);

ridges = [];
nridges = 0;
for i=1:nfrq
    % get the indicies that have peaks in this frequency
    ncyclepoints = time_to_samples(1/frq(i)*params.ridges.ncycles*1000, params.data.srate);
    if (ncyclepoints >= npoints)
        ncyclepoints = npoints/2;
    end
    %pind = find(rt(i,:)>0);
    % store the index of the frequency where the ridges was
    if (is_ridges(rt(i,:), ncyclepoints))
        nridges = nridges + 1;
        ridges(nridges) = i;
    end
end

% Find a ridge ------------------------------------------------------------
function [ir] = is_ridges(d, min_points)

for i=1:(length(d)-min_points-1)
    if (sum(d(i:(i+min_points-1))) == min_points)
        ir = 1;
        return;
    end
end
ir = 0;
% Get only data that is a ridge ---------------------------------------
function [rd] = ridge_data(spectrum, ridges)

[nfrq, npoints] = size(spectrum);
rd = zeros(nfrq, npoints);
if (~isempty(ridges))
    for k=1:length(ridges)
        index = ridges(k);
        rd(index,:) = spectrum(index,:);
    end
end

% Average over a frequqnecy range
function [m] = average_range(d, ridges, rrindex)

npoints = length(d);
m = zeros(1, npoints);

if (~isempty(rrindex))
    for k=1:length(rrindex)
        index = ridges(rrindex(k));
        m = m+d(index,:,:);
    end
    m = m/length(rrindex);
end