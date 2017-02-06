function [test] = pallindrome(word)

if nargin < 1 
    display('Nothing entered');
    return;
end

test = strcmp(fliplr(word), word);

