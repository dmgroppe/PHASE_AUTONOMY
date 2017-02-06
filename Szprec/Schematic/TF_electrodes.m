function [implant] = TF_electrodes
% Must mulitply by 1000 to get real x,y coordinates


LHD = [ 1.8688    3.1951
    1.8034    2.9552
    1.7307    2.6935
    1.6581    2.4609];
LOF = [0.9893    3.5367
    0.9530    3.3332
    0.9167    3.0933
    0.8876    2.8752];
LAIH = [3.4897    4.7215
    3.3735    4.5470
    3.2426    4.3508
    3.1263    4.1691];
LLF = [0.8658    1.1889
    0.9167    0.9854
    0.9748    0.7601
    1.0330    0.5493];
LAT = [1.1347    2.1193
    1.3164    2.0175
    1.5272    1.9085
    1.7235    1.8068 ];
LMT = [2.0651    3.1224
    2.0651    2.9189
    2.0651    2.6790
    2.0578    2.4609];
LPIH = [ 2.2177    4.1472
    2.4285    4.1109
    2.6539    4.0673
    2.8719    4.0309];
LPT = [2.6102    1.5596
    2.3995    1.6178
    2.1741    1.6686
    1.9706    1.7268 ];

RHD = [6.0483    3.1442
    6.1137    2.9043
    6.1864    2.6426
    6.2591    2.3882 ];
ROF = [6.9569    3.5512
    6.9787    3.3404
    7.0078    3.1078
    7.0368    2.8898];
RAIH = [ 4.3765    4.7069
    4.5074    4.5470
    4.6673    4.3653
    4.8054    4.1981];
RLF = [ 7.0950    1.1817
    7.0296    0.9781
    6.9569    0.7601
    6.8915    0.5493];
RAT = [6.6371    2.1920
    6.4626    2.0902
    6.2591    1.9594
    6.0774    1.8431 ];
RMT = [ 5.8302    3.0860
    5.8230    2.8825
    5.8230    2.6426
    5.8230    2.4246];
RPIH = [5.7139    4.2854
    5.5104    4.2272
    5.2851    4.1618
    5.0816    4.0964 ];
RPT = [5.2342    1.4942
    5.4377    1.5742
    5.6631    1.6614
    5.8593    1.7268 ];

implant = [LHD;LOF;LAIH;LLF;LAT;LMT;LPIH;LPT;RHD;ROF;RAIH;RLF;RAT;RMT;RPIH;RPT]*1000;