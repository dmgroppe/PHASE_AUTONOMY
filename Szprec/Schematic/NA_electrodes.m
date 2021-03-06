function [implant] = NA_electrodes
% Must mulitply by 1000 to get real x,y coordinates

LHD = [ 2.2457    3.7202
    2.2129    3.9701
    2.1931    4.2265
    2.1734    4.4961];
LAT = [ 1.3582    2.7998
    1.5357    2.6749
    1.7329    2.5368
    1.8973    2.4185];
LMT = [  2.4890    3.7400
    2.4890    3.9701
    2.4890    4.2396
    2.4956    4.4961];
LPT =[2.2260    2.2410
    2.4627    2.1686
    2.7059    2.0634
    2.9361    1.9714];
RHD = [  7.6172    3.6677
    7.6632    3.9175
    7.7026    4.1870
    7.7355    4.4369];
RAT = [8.3930    2.7932
    8.2023    2.7012
    7.9919    2.6091
    7.7881    2.5237];
RMT = [  7.4002    3.7137
    7.4002    3.9438
    7.4068    4.2133
    7.4199    4.4698];
RSPT = [ 6.5981    1.7216
    6.7625    1.8202
    6.9400    1.9385
    7.1241    2.0306
    7.3147    2.1621
    7.5054    2.2738];
RIPT = [6.2694    2.2344
    6.4535    2.2936
    6.6573    2.3462
    6.8545    2.3988
    7.0846    2.4711
    7.2884    2.5368];

implant = [LHD;LAT;LMT;LPT;RHD;RAT;RMT;RSPT;RIPT]*1000;

















