# DER-Planning

# Master:
The code that you mostly need to run is Master.m. The code binds together all of the other codes.
#	PowerFlow:
The PowerFlow.m contains a class to perform power flow. The power flow method is backward-forward sweep. Each time a power flow is needed, the Master program makes an object of PowerFlow class.
#	Gen_Data:
The Gen_Data.m contains the generation data of the PV panels.
#	Load_Data:
The Load_Data.m contains the consumption data of the residential customers.
#	Network_Data:
The Network_Data.m contains the topology data and distribution network characteristics.
