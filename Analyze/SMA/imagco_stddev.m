function stddev = imagco_stddev(C)

N = length(C);
C = abs(C);
stddev = sqrt(((1-C.^2).*(atanh(C).^2))./(N*(N-1)*C.^2));
%stddev = sqrt(((1-C.^2).*(atanh(C).^2))./(N*C.^2));


% stddev = zeros(N,N);
% 
% for i=1:N
%     for j=i+1:N
%         imagco = abs(C(j,i));
%         sd = sqrt((1-((abs(imagco))^2))/(N*(N-1))* ((atanh(abs(imagco)))^2/(abs(imagco)^2)));
%         stddev(j,i) = sd;
%     end
% end