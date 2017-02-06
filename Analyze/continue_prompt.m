function [cont] = continue_prompt()

cont = 0;

reply = input('Continue (y)es or n(o) [Y]:','s');
if (isempty(reply))
    reply = 'Y';
end

if (strcmp(upper(reply), 'Y'))
    cont = 1;
    return;
end
