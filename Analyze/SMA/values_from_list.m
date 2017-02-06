function vlist = values_from_list(csig, plist)

for i=1:size(plist,2) 
    vlist(i) = csig(plist(1,i), plist(2,i));
end