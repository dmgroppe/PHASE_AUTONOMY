function [sig imCo] = b_fdr(pValue)

chanNum = length(pValue);

alfa=0.05;
%linearize the pvals
ctr=0;
pvLin=zeros(1,chanNum);
for i=1:chanNum
  for j=i+1:chanNum
    ctr=ctr+1;
    pvLin(ctr)=pValue(j,i);
  end
end
sortedpvLin=sort(pvLin,'ascend');
% find the lowest P-vals
cnFac=1;
maxPi=0;
for i=1:ctr
  if(sortedpvLin(i)>alfa*i/ctr*cnFac)
      break;
  end
  maxPi=sortedpvLin(i);
end

% now that we know the highest accepted,set the significance
for i=1:chanNum
  for j=i+1:chanNum
      if(pValue(j,i)<maxPi)
          sig(j,i)=1;
      else
          sig(j,i)=0;
          imCo(j,i)=0;
      end
  end
end

