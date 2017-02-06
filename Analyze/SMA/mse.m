function [SE] = mse(x,p)

sd = std(x);
Nr = fix((p.r_max-p.r_min)/p.r_step)+1;

SE = zeros(Nr, p.scale_max, p.m_max);

for j=1:p.scale_step:p.scale_max     
    y = CoarseGraining(x,j);
    c = 1;
    for i=1:Nr
        r = p.r_min + (i-1)*p.r_step;
        SE(c,j,:) = SampleEntropy(y,r,sd,j,p);
        c = c+1;
    end   
end

function [y] = CoarseGraining(u, j)
nlin = length(u);

y = zeros(1,nlin);
for i=0:fix(nlin/j)-1
    for k=0:j-1
        y(i+1) = y (i+1) + u(i*j+k+1);
    end
    y(i+1) = y(i+1)/j; 
end

function [se] = SampleEntropy(y,r,sd,j,p)

nlin = length(y);

nlin_j = (nlin/j) - p.m_max; 
r_new = r*sd;              

cont = zeros(1,p.m_max+1);

for i=1:nlin_j
    for l=i+1:nlin_j
        % self-matches are not counted
        k = 0;
        while (k < p.m_max && abs(y(i+k) - y(l+k)) <= r_new)
            k = k+1;
            cont(k) = cont(k) + 1;
            if (k == p.m_max && abs(y(i+p.m_max) - y(l+p.m_max)) <= r_new)
                cont(p.m_max+1) = cont(p.m_max+1) + 1;
            end
        end
    end     
end

for i=1:p.m_max
    if (cont(i+1) == 0 || cont(i) == 0)
        se(i) = -log(1/((nlin_j)*(nlin_j-1)));
    else
        se(i) = -log(cont(i+1)/cont(i));
    end
end


