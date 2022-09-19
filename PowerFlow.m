% Backward_Forward power flow
% This software was developed as a part of the course distributed energy resources in electricity networks
% This source code is licensed under the MIT license.
% Author: Mehdi Attar <Mehdi.attar@tuni.fi>

classdef PowerFlow < handle
    properties
        Num_of_Buses
        Load_Gen
        Sub_Voltage
        Init_Voltage
        Percision
        Graph_Resistance
        Graph_Reactance
        Distance_Resistance
        Distance_Reactance
        
        V_Old
        V_New
        V_Reference
        Delta_V
        Voltage_Drop
        Nodal_Current
        Branch_Current
        Branch
        Branch_num
    end
    methods
        % Constructor
        function obj=PowerFlow(Num_of_Buses,Branch,Load_Gen,Sub_Voltage,Init_Voltage,Percision,Graph_Resistance,Graph_Reactance,Distance_Resistance,Distance_Reactance)
           obj.Num_of_Buses = Num_of_Buses;
           obj.Load_Gen = Load_Gen;
           obj.Sub_Voltage = Sub_Voltage;
           obj.Init_Voltage = Init_Voltage;
           obj.Percision = Percision;
           obj.Graph_Resistance = Graph_Resistance;
           obj.Graph_Reactance = Graph_Reactance;
           obj.Distance_Resistance = Distance_Resistance;
           obj.Distance_Reactance = Distance_Reactance;
           obj.Branch = Branch;
           [obj.Branch_num,~] = size(Branch);
        end
        
        function OutPut=Backward_Forward(obj)
            obj.V_Old = obj.Init_Voltage*ones(obj.Num_of_Buses,1);
            obj.V_Old(1,1) = obj.Sub_Voltage; 
            obj.V_New = zeros(obj.Num_of_Buses,1);
            obj.Delta_V = obj.V_Old - obj.V_New;
            obj.Nodal_Current = zeros(obj.Num_of_Buses,1);
            obj.Branch_Current = zeros(obj.Num_of_Buses-1,1);
            
            obj.V_Reference = obj.Init_Voltage*ones(obj.Num_of_Buses,1);
            obj.V_Reference(1,1) = obj.Sub_Voltage; 
            
            
            % Backward sweep
            while max(obj.Delta_V) > obj.Percision
                obj.V_New = zeros(obj.Num_of_Buses,1);
                
                obj.Nodal_Current = zeros(obj.Num_of_Buses,1);
                obj.Branch_Current = zeros(obj.Num_of_Buses-1,1);
                % nodal currents. assumption: constant power load
                obj.Nodal_Current = obj.Load_Gen./(sqrt(3)*obj.V_Old);
                
                % branch currents
                for i=1:1:length(obj.Nodal_Current)
                   if obj.Nodal_Current(i,1)~=0
                      Common_Buses = shortestpath(obj.Graph_Resistance,i,1);
                      for j=1:1:length(obj.Branch_Current)
                          First_Column = find(obj.Branch(j,1)==Common_Buses);
                          Second_Column = find(obj.Branch(j,2)==Common_Buses);
                          if ~isempty(First_Column) && ~isempty(Second_Column)
                             obj.Branch_Current(j,1) = obj.Nodal_Current(i,1) + obj.Branch_Current(j,1) ;
                          end
                      end
                   end
                end
                
                % Voltage drop
                obj.Voltage_Drop = obj.Branch_Current.*(abs(complex(obj.Branch(:,3),obj.Branch(:,4))));
                
                First_Matrix = obj.Branch(:,[1,2]);
                % Forward sweep
                obj.V_New(1,1) = obj.Sub_Voltage;
                Zero_Existance=find(obj.V_New(:,:)==0);
                
                while ~isempty(Zero_Existance)
                    for i=2:obj.Num_of_Buses
                        Neiboring_Buses=neighbors(obj.Graph_Resistance,i);
                        for k=1:length(Neiboring_Buses)
                            if obj.V_New(Neiboring_Buses(k,1),1)>0
                                [a b] = find(First_Matrix == i);
                                [c d] = find(First_Matrix == Neiboring_Buses(k,1));
                                row=intersect(a,c);
                                obj.V_New(i,1)=obj.V_New(Neiboring_Buses(k,1),1)-obj.Voltage_Drop(row,1);
                            end
                        end
                    end
                Zero_Existance = find(obj.V_New(:,:)==0);
                end
                % finding inaccuracy
                obj.Delta_V = abs(obj.V_New-obj.V_Old);
                obj.V_Old = obj.V_New;
                OutPut=obj.V_New;
            end
        end
    end
end

