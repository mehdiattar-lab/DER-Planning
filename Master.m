% Master program
clear;
clc;

Load_Data;
Gen_Data;
Network_Data;

Sub_Voltage=1; % p.u.
Percision=0.001;
Init_Voltage=1; % p.u. voltage is used to calculate load currents

PlanningType=questdlg('Choose the type of planning studies:','Type','Deterministic',...
    'Stochastic','Deterministic');
Horizon = str2double(inputdlg({'Planning horizon (max 8760 hours)'},'Input',[1 50])); 

Num_of_Buses = length(Bus); % Since there is one slack bus, the actual numbers are -1
Loads_Generations = zeros(Num_of_Buses,1);

% Making graph
Graph_Resistance=graph(Branch(:,1),Branch(:,2),Branch(:,3));
Graph_Reactance=graph(Branch(:,1),Branch(:,2),Branch(:,4));
Distance_Resistance=distances(Graph_Resistance);
Distance_Reactance=distances(Graph_Reactance);

[Bus_Numbers,~] = size(Bus);
Nodal_voltage = zeros (Bus_Numbers,Horizon);
[Branch_Numbers,~] = size(Branch);
Branch_Current = zeros (Branch_Numbers,Horizon);

switch PlanningType
    case 'Deterministic'
        for i=1:1:Horizon
            NumberofHourSimulated=i
            if i==3635
                i=i
            end
            for bus=1:1:Num_of_Buses
                is_bus=cellfun(@(x)isequal(x,bus),Topology);
                [row,col] = find(is_bus);
                if ~isempty(row)
                    Num_Elements=numel(row);
                    for j=1:1:Num_Elements
                        Loads_Generations(bus,1) = Topology{row(j,1),1}(i,1)+Loads_Generations(bus,1);
                    end
                end
            end
            Loads_Generations = Loads_Generations./S_Base;
            Object = PowerFlow(Num_of_Buses,Branch,Loads_Generations,Sub_Voltage,Init_Voltage,Percision,Graph_Resistance,Graph_Reactance,Distance_Resistance,Distance_Reactance);
            Output = Object.Backward_Forward;
            Nodal_voltage(:,i) = Object.V_New;
            Branch_Current(:,i) = Object.Branch_Current;
            Loads_Generations = zeros(Num_of_Buses,1);
        end
        
    case 'Stochastic'
        Num_Samples = str2double(inputdlg({'Number of samples in MonteCarlo simulations'},'Input',[1 50]));
        empty_individual.Voltage = [];
        empty_individual.Current = [];
        pop = repmat(empty_individual,Num_Samples,1);   % We run 100 power flows per each hour of the timeseries
        BigPop = repmat(pop,8760,1);
        
        Mean_Load_1 = (sum(Load_1))/8760;
        STD_Load_1 = std(Load_1);
        
        Mean_Load_2 = (sum(Load_2))/8760;
        STD_Load_2 = std(Load_2);
        
        Mean_Load_3 = (sum(Load_3))/8760;
        STD_Load_3 = std(Load_3);
        
        Mean_Load_4=(sum(Load_4))/8760;
        STD_Load_4 = std(Load_4);
        
        Mean_EV=(sum(EV))/8760;
        STD_EV = std(EV);
        
        Mean_PV1=(sum(PV1))/8760;
        STD_PV1 = std(PV1);
        
        Mean_PV2=(sum(PV2))/8760;
        STD_PV2 = std(PV2);
        
        for i=1:1:Horizon
            NumberofHourSimulated=i
            for k=1:Num_Samples
                if k==1
                    for bus=1:1:Num_of_Buses
                        is_bus=cellfun(@(x)isequal(x,bus),Topology);
                        [row,col] = find(is_bus);
                        if ~isempty(row)
                            Num_Elements=numel(row);
                            for j=1:1:Num_Elements
                                Loads_Generations(bus,1) = Topology{row(j,1),1}(i,1)+Loads_Generations(bus,1);
                            end
                        end
                    end
                  
                else
                    %%%%% Creating random variables for each Load/Generation
                    Load_1_rnd=normrnd(Mean_Load_1,STD_Load_1);
                    Load_2_rnd=normrnd(Mean_Load_2,STD_Load_2);
                    Load_3_rnd=normrnd(Mean_Load_3,STD_Load_3);
                    Load_4_rnd=normrnd(Mean_Load_4,STD_Load_4);
                    EV_rnd=normrnd(Mean_EV,STD_EV);
                    PV1_rnd=normrnd(Mean_PV1,STD_PV1);
                    PV2_rnd=normrnd(Mean_PV2,STD_PV2);
                    Topology_rnd = {Load_1_rnd  8
                                    Load_2_rnd  6
                                    Load_3_rnd  11
                                    Load_4_rnd 12
                                    EV_rnd 11
                                    PV1_rnd 6
                                    PV2_rnd 8
                                        };
                    for bus=1:1:Num_of_Buses
                        is_bus=cellfun(@(x)isequal(x,bus),Topology_rnd);
                        [row,col] = find(is_bus);
                        if ~isempty(row)
                            Num_Elements=numel(row);
                            for j=1:1:Num_Elements
                                Loads_Generations(bus,1) = Topology_rnd{row(j,1),1}+Loads_Generations(bus,1);
                            end
                        end
                    end
                end
                Loads_Generations = Loads_Generations./S_Base;
                Object = PowerFlow(Num_of_Buses,Branch,Loads_Generations,Sub_Voltage,Init_Voltage,Percision,Graph_Resistance,Graph_Reactance,Distance_Resistance,Distance_Reactance);
                Output = Object.Backward_Forward;
                BigPop(((i-1)*Num_Samples)+k).Voltage = Object.V_New;
                BigPop(((i-1)*Num_Samples)+k).Current = Object.Branch_Current;
                Loads_Generations = zeros(Num_of_Buses,1);
            end
        end
end

switch PlanningType
    case 'Deterministic'
     fplot(@(x) 1.05,'r')
     hold on
     fplot(@(x) 0.95,'r')
     hold on
     for i=1:Horizon
         i=i
         plot(i,Nodal_voltage(8,i),'.')
         hold on
     end
     case 'Stochastic'
     fplot(@(x) 1.05,'r')
     hold on
     fplot(@(x) 0.95,'r')
     hold on
     for i=1:Horizon
        i=i
        for j=1:Num_Samples
            plot(i,BigPop(((i-1)*Num_Samples)+j).Voltage(5,1),'.')
            hold on
        end
     end
end
