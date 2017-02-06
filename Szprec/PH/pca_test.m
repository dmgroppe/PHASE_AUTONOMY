function [] = pca_test()

for i=1:5
    x(:,i) = randperm(25) + 5;
    x(11:15,i) = 1:5;
end

[COEFF,SCORE,latent,tsquare] = princomp(x');

imagesc(COEFF);
