function [sm] = tsmooth(x, window)

N = length(x);
sm = zeros(1,N);

for i=1:(N-window)
    sm(i) = mean(x(i:i+window));
end
sm((N-window+1):N) = sm(N-window);