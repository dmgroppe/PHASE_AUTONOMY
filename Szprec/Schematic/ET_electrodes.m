function [implant] = ET_electrodes
% Must mulitply by 1000 to get real x,y coordinates

LHD = [ 2.2435    3.7260
    2.2171    3.9631
    2.1908    4.2464
    2.1644    4.5033];
LAT = [ 1.3081    2.7708
    1.5386    2.6457
    1.7758    2.5271
    1.9932    2.4217];
LMT = [ 2.4806    3.7392
    2.4872    3.9763
    2.4872    4.2464
    2.4938    4.4901];
LPT =[3.5017    1.9079
    3.2645    1.9935
    3.0010    2.0791
    2.7837    2.1582
    2.5597    2.2306
    2.3489    2.3097];
RHD = [ 7.6386    3.7128
    7.6781    3.9763
    7.7242    4.2398
    7.7571    4.4769 ];
RAT = [8.4620    2.8367
    8.2446    2.7247
    8.0009    2.6127
    7.7769    2.5007];
RMT = [  7.4146    3.7589
    7.4146    3.9961
    7.4278    4.2727
    7.4409    4.5165 ];
RPT = [6.7493    2.1318
    6.9864    2.2043
    7.2367    2.2899
    7.4607    2.3756];

implant = [LHD;LAT;LMT;LPT;RHD;RAT;RMT;RPT]*1000;

















