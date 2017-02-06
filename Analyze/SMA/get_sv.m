function [sv] = get_sv(sync, uchan, c_pair)

sv = sync(find(uchan==c_pair(2)), find(uchan==c_pair(1)));