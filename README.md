# DER-Planning
The cod called "Master" binds together all the other pieces of the codes in this repository. The aim of the codes is to simulate deteministic (worse case scenario) and stochastic distribution netwrok connection planning.

## Requirements
•	MATLAB 2020a

•	Likely earlier or later version of MATLAB (not tested though)

## Master:
The code that you mostly need to run is Master.m. The code binds together all of the other codes.
##	PowerFlow:
The PowerFlow.m contains a class to perform power flow. The power flow method is backward-forward sweep. Each time a power flow is needed, the Master program makes an object of PowerFlow class.
##	Gen_Data:
The Gen_Data.m contains the artificial generation data of the PV panels.
##	Load_Data:
The Load_Data.m contains the artificial consumption data of the residential customers.
##	Network_Data:
The Network_Data.m contains the topology data and distribution network characteristics. The network topology and its characteristics can be replaced by any radial distribution network.
