function [] = page_hinkley_test()

sm = 25; % smoothing
%v = 0.05;
nsurr = 100;
alpha = 0.1;

x = rand(1,1000)*10;
%x = rand(1,1000);
v = var(x)/10;  % Can set this anything really just playing, this seems okay


% Create a step(s) in 'activity'
x(500:550) = smooth(x(500:550) + 2);
x(200:250) = x(200:250)*1.4;

[hp, A, U, p] = change_detect(x, v, sm, nsurr);

ind = find(p < alpha);
if ~isempty(ind)
    display('Locations of changes');
    hp(ind,:)
end

