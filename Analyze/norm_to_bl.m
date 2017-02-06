function [ws] = norm_to_bl(ws, blsamples)

bl = mean(ws(:, 1:blsamples),2);

for i=1:length(ws);
    ws(:,i) = ws(:,i)./bl;
end
    