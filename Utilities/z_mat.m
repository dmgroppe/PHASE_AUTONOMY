function [z] = z_mat(x,dim)

if min(size(x) == 2)
    if dim ==2
        z = (x-repmat(mean(x,2),1,length(x)))./repmat(squeeze(std(x,2)),1,length(x));
    else
        z = (x-repmat(mean(x,1),length(x), 1))./repmat(squeeze(std(x,1)),length(x),1);
    end
else
    z = (x-mean(x))/std(x);
end
