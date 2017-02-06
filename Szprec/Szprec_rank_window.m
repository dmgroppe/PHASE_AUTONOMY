function rw = Szprec_rank_window(f, rankmin, rank_mint, p)

rw = zeros(1, length(f));
for i=1:length(f)-rank_mint
    n = sum(f(i:(i+rank_mint-1)) > rankmin);
    if n >= rank_mint*p
        rw(i:(i+rank_mint-1)) = 1;
    end
end

