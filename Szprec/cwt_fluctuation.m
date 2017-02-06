function output=cwt_fluctuation(hx,hy,scale,Sf,wname)
%hx,hy two channel inputs
%scale: scale 
%Sf:sampling frequency
%wname: complex morlet, cmorfb-fc

window=Sf;
cwtcmorx=cwt(hx,scale,wname);
cwtcmory=cwt(hy,scale,wname);
R=cwtcmorx.*conj(cwtcmory)./(abs(cwtcmorx).*abs(cwtcmory));
Ab=unwrap(angle(R));
Ab=Ab';
Ab=padarray(Ab,[window/2 0],'replicate');
output=average(abs(diff(Ab)),window);
end

function x=average(x,win)
c   = cumsum(x)./win;
x   = [c(win); c((win+1):end)-c(1:(end-win))];
end
