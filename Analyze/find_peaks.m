function [rt] = find_peaks(d, per, min_peak)

if (nargin) < 2; per = 3; end;
if (nargin < 3); min_peak = 1; end;

[r,c] = size(d);

rt = zeros(r,c);
p = zeros(r,c);
for i=1:c
    p(:,:) = 0;
    p = findpeaks(d(:,i),min_peak);
    rt(:,i) = p;
end

%[rt] = remnoise(rt);
[rt] = ExcludePeaks(d, rt, per);


function [p] = findpeaks(d,mp)

np = size(d,1);
count = 0;
p = zeros(1,np);
i=2;
while(i<= (np-1))
    if ((d(i) > d(i-1) ) && (d(i) > d(i+1)))
        count = count + 1;
        p(i) = 1;
        i = i + mp;
    else
        i = i+1;
    end
end

function [cont] = remnoise(m)

[r,c] = size(m);
cont = ones(r,c);

for i=2:(r-1)
    for j=2:(c-1)
        count = 0;
        if (m(i,j) == 1)
            for k=i-1:i+1
                for l=j-1:(j+1);
                    if (m(k,l) == 1)
                        count = count +1;
                    end
                end
            end          
            if (count < 3)
                cont(i,j) = 0;
            end
        end
    end
end

function [excluded] = ExcludePeaks(sp, peaks, per)

spmax = max(max(sp));
[r,c] = size(peaks);
excluded = peaks;

for i=1:r
    for j=1:c
        if (sp(i,j) < per*spmax/100.0)
            excluded(i,j) = 0;
        end
    end
end