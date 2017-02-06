function [ imCo,pValue,sig] = imagCoh( x )

if ~exist('x','var'), x= []; end

[chanNum,Len]=size(x);

% now we will go through every single combo of inputs computing the rel
% phase and then mean phase coherence

for i=1:chanNum
  
    for j=1:i
      imCo(i,j)=0;
      pValue(i,j)=0;
    end
    for j=i+1:chanNum
      % have to repeat for every window

      % phase i - phase j =>pzhdif
      hi(1:Len)=hilbert(x(i,:));
      hj(1:Len)=hilbert(x(j,:));
      phzDf=unwrap(angle(hi))-unwrap(angle(hj));
      phzDf=mod(phzDf,2*pi);
      A1(1:Len)=abs(hi(1:Len));
      A2(1:Len)=abs(hj(1:Len));
      topPart(1:Len)=A1.*A2;
      topPart(1:Len)=topPart.*(sin(phzDf(1:Len)));
      topPart_avg=mean(topPart(1:Len));
      
      A1s(1:Len)=A1.*A1;
      A2s(1:Len)=A2.*A2;
      botPart=sqrt(mean(A1s(:))*mean(A2s(:)));
      imCo(i,j)=topPart_avg/botPart;            
      C=abs(imCo(i,j));
      
      imCoStdDev=sqrt((1-((abs(C))^2))/(chanNum*(chanNum-1))* ((atanh(abs(C)))^2/ (abs(C)^2)));
      %pValue(i,j)= chi2pdf( abs(imCo(i,j))/imCoStdDev,1);
      pValue(i,j)= 1.0-normcdf( abs(imCo(i,j)),0,imCoStdDev);
    end
end
% perform fdr    
alfa=0.1;
%linearize the pvals
ctr=0;
pvLin=zeros(1,chanNum);
for i=1:chanNum
   for j=i+1:chanNum
     ctr=ctr+1;
     pvLin(ctr)=pValue(i,j);
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
       if(pValue(i,j)<maxPi)
           sig(i,j)=1;
       else
           sig(i,j)=0;
           imCo(i,j)=0;
       end
   end
end   

