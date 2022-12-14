% Network Information from a real distribution system
% it only consists one bus from MV side and the rest is LV

%Bus Type Vm Va BasekV Vmin Vmax
Bus=[
    1  3  1  0  20  0.95  1.05   
    2  1  1  0  0.4  0.95  1.05
    3  1  1  0  0.4  0.95  1.05
    4  1  1  0  0.4  0.95  1.05
    5  1  1  0  0.4  0.95  1.05
    6  1  1  0  0.4  0.95  1.05
    7  1  1  0  0.4  0.95  1.05
    8  1  1  0  0.4  0.95  1.05
    9  1  1  0  0.4  0.95  1.05
    10  1  1  0  0.4  0.95  1.05
    11 1  1  0  0.4  0.95  1.05
    12 1  1  0  0.4  0.95  1.05
    ];
%Branch F_Bus T_Bus R(p.u.) X(p.u.) Y(p.u.) G(p.u.) I_Rated
Branch=[
    1	2	0.072	0.134	0	0.00256	1.73913
   	2	3	0.056	0.008	0	0	1.12
   	3	4	0.084	0.007	0	0	0.72
  	4	5	0.054	0.006	0	0	1
   	5	6	0.064	0.005	0	0	0.72
   	3	7	0.249	0.038	0	0	1.12
   	7	8	0.143	0.002	0	0	0.624
   	2	9	0.016	0.002	0	0	1.12
   	9	10	0.074	0.011	0	0	1.12
   	10	11	0.077	0.006	0	0	0.72
   	9	12	0.001	0.000	0	0	0.8
];
S_Base = 50 ; % In kW
V_Base = 400; % In volt
% Network topology: Load/Gen  Bus
Topology = {Load_1  8
            Load_2  6
            Load_3  11
            Load_4 12
            Load_5 11
            PV1 6
            PV2 8
                };


