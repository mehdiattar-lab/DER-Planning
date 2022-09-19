% Copyright 2022 Tampere University, Tampere, Finland
% This software was developed as a part of the course distributed energy resources in electricity networks
% This source code is licensed under the MIT license.
% Author: Mehdi Attar <Mehdi.attar@tuni.fi>


% Master program
clear;
clc;

Load_Data;
Gen_Data;
Network_Data;

Sub_Voltage=0.99; % p.u.
Percision=0.003;
Init_Voltage=1; % p.u. voltage is used to calculate load currents

PlanningType=questdlg('Choose the type of planning studies:','Type','Deterministic',...
    'Stochastic','Deterministic');
Horizon = str2double(inputdlg({'From (hour): Min=1','To (hour): Max=8760'},'Simulation duration 0<from<to<=8760',[1 70])); 
Duration = Horizon(2,1)-Horizon(1,1);

Num_of_Buses = length(Bus); % Since there is one slack bus, the actual numbers are -1
Loads_Generations = zeros(Num_of_Buses,1);

% Making graph
Graph_Resistance=graph(Branch(:,1),Branch(:,2),Branch(:,3));
Graph_Reactance=graph(Branch(:,1),Branch(:,2),Branch(:,4));
Distance_Resistance=distances(Graph_Resistance);
Distance_Reactance=distances(Graph_Reactance);

[Bus_Numbers,~] = size(Bus);
Nodal_Voltage = zeros (Bus_Numbers,Duration);
[Branch_Numbers,~] = size(Branch);
Branch_Current = zeros (Branch_Numbers,Duration);

switch PlanningType
    case 'Deterministic'
        Z_Score(1,1) = -str2double(inputdlg({'Z_score generation~=0'},'Z-score of normal distribution for generation',[1 70]));
        Z_Score(2,1) = str2double(inputdlg({'Z_score demand~=0'},'Z-score of normal distribution for demand',[1 70]));
        for i=Horizon(1,1):1:Horizon(2,1)
            NumberofHoursSimulated=i
            for bus=1:1:Num_of_Buses
                is_bus=cellfun(@(x)isequal(x,bus),Topology);
                [row,col] = find(is_bus);
                if ~isempty(row)
                    Num_Elements=numel(row);
                    for j=1:1:Num_Elements
                        if row(j,1)<6  % for loads
                            Loads_Generations(bus,1) = Topology{row(j,1),1}(i,1)+Z_Score(2,1)*Topology{row(j,1),1}(i,2)+Loads_Generations(bus,1); % x=mean+Z_score*STD
                        else % for generations
                            Loads_Generations(bus,1) = Topology{row(j,1),1}(i,1)+Z_Score(1,1)*Topology{row(j,1),1}(i,2)+Loads_Generations(bus,1); % x=mean+Z_score*STD
                        end
                    end
                end
            end
            Loads_Generations = Loads_Generations./S_Base;
            Object = PowerFlow(Num_of_Buses,Branch,Loads_Generations,Sub_Voltage,Init_Voltage,Percision,Graph_Resistance,Graph_Reactance,Distance_Resistance,Distance_Reactance);
            Output = Object.Backward_Forward;
            Nodal_Voltage(:,i+1-Horizon(1,1)) = Object.V_New;
            Branch_Current(:,i+1-Horizon(1,1)) = Object.Branch_Current;
            Loads_Generations = zeros(Num_of_Buses,1);
        end
        
    case 'Stochastic'
        Num_Samples = str2double(inputdlg({'Number of samples in MonteCarlo simulations'},'Input',[1 50]));
        empty_individual.Voltage = [];
        empty_individual.Current = [];
        pop = repmat(empty_individual,Num_Samples,1);
        Results = repmat(pop,Duration,1);
        
        Counter=0;
        for i=Horizon(1,1):1:Horizon(2,1)
            NumberofHoursSimulated=i
            Counter=Counter+1;
            for k=1:Num_Samples 
                %%%%% Creating random variables for each Load/Generation
                Load_1_rnd = abs(normrnd(Load_1(i,1),Load_1(i,2)));
                Load_2_rnd = abs(normrnd(Load_2(i,1),Load_2(i,2)));
                Load_3_rnd = abs(normrnd(Load_3(i,1),Load_3(i,2)));
                Load_4_rnd = abs(normrnd(Load_4(i,1),Load_4(i,2)));
                Load_5_rnd = abs(normrnd(Load_5(i,1),Load_5(i,2)));
                PV1_rnd = normrnd(PV1(i,1),PV1(i,2));
                PV2_rnd = normrnd(PV2(i,1),PV2(i,2));
                Topology_rnd = {Load_1_rnd  8
                                Load_2_rnd  6
                                Load_3_rnd  11
                                Load_4_rnd 12
                                Load_5_rnd 11
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
          
                Loads_Generations = Loads_Generations./S_Base;
                Object = PowerFlow(Num_of_Buses,Branch,Loads_Generations,Sub_Voltage,Init_Voltage,Percision,Graph_Resistance,Graph_Reactance,Distance_Resistance,Distance_Reactance);
                Output = Object.Backward_Forward;
                Results(((Counter-1)*Num_Samples)+k).Voltage = Object.V_New;
                Results(((Counter-1)*Num_Samples)+k).Current = Object.Branch_Current;
                Loads_Generations = zeros(Num_of_Buses,1);
            end
        end
end




%%%%%%%%%%%%%%%%%% Ploting

% switch PlanningType
%     case 'Deterministic'
%      fplot(@(x) 1.05,'r')
%      hold on
%      fplot(@(x) 0.95,'r')
%      hold on
%      Over_Voltage_Counter=0;
%      x=zeros(1,Duration+1);
%      x(1,:)=(1:Duration+1);
%      y=Nodal_Voltage(8,:);
%      plot(x,y,'.')
%      title('Voltage (p.u.)- deterministic')
%     
%     case 'Stochastic'
%      Over_Voltage_Counter=0;
%      x=zeros(1,Duration+1);
%      x(1,:)=(1:Duration+1);
%      x=repmat(x,[1,Num_Samples]);
%      x=sort(x);
%      Voltage=zeros(1,(Duration+1)*Num_Samples);
%      counter=0;
%      counter1=0;
%      Num_violation_stochastic = 0;
%      for i=Horizon(1,1):1:Horizon(2,1)
%          counter1=counter1+1;
%          Violation="False";
%         for j=1:Num_Samples
%             counter=counter+1;
%             Voltage(1,counter)=Results(((counter1-1)*Num_Samples)+j).Voltage(8,1);
%             if  find(Results(((counter1-1)*Num_Samples)+j).Voltage>1.05)
%                 Violation="True";
%             end
%         end
%         if strcmp(Violation,"True")
%             Num_violation_stochastic=Num_violation_stochastic+1;
%         end
%      end
%      
%      fplot(@(x) 1.05,'r')
%      hold on
%      fplot(@(x) 0.95,'r')
%      hold on
%      plot(x,Voltage,'.')
%      title('Voltage (p.u.)- Stochastic')
%      Num_violation_stochastic=Num_violation_stochastic
%      
% end
