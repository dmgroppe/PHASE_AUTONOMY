function [loom_var, nseg] = sync_loom(h1, h2, window, fh)

nseg = fix(length(h1)/window);

val = zeros(1,nseg);

for i=1:nseg
    segstart = (i-1)*window + 1;
    segend = segstart + window -1;
    
    sh1 = h1;
    sh2 = h2;
    
    sh1(segstart:segend) = [];
    sh2(segstart:segend) = [];
    
    val(i) = fh(sh1, sh2);
    
end

loom_var = var(val);


