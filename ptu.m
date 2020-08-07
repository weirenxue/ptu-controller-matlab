classdef ptu < handle
    %UNTITLED5 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (GetAccess = public, SetAccess = private)
        PTU
        Status % 'Connection failed' / 'Connection successed'
        Pan_Resolution
        Tilt_Resolution
        Pan_Limit
        Tilt_Limit
    end
    
    methods
        function obj = ptu(RHOST, RPORT)
            %UNTITLED5 Construct an instance of this class
            %   Detailed explanation goes here
            PTU = instrfind('Type', 'tcpip', 'RemoteHost', RHOST, 'RemotePort', RPORT);
            if isempty(PTU)
                obj.PTU = tcpip(RHOST, RPORT);
            else
                fclose(PTU);
                obj.PTU = PTU(1);
            end
            try
                obj.Initialize();
            end
            if strcmp(obj.Status, 'Connection successed')
                obj.PTResolution();
                obj.PTLimit();
            end
        end
        function result = cmd(obj, CMD)
            result = query(obj.PTU, CMD);
        end
        function Initialize(obj)
            % Initialize(PTU)
            % function : clear buffer at first, change mode such as "echo", "feedback".
            try
                fclose(obj.PTU);
                pause(0.1); 
                fopen(obj.PTU); 
                pause(0.2); 
            end
            if strcmp(obj.PTU.Status, 'open')
                obj.Status = 'Connection successed';
                obj.cmd('ED '); % Disable host command echoing, return command result rather than command
                obj.cmd('FT '); % Enable terse ASCII feedback, just return digits
                obj.cmd('LE '); % Enable pan position limits(software)
                pause(0.5); 
                while 1 
                    if obj.PTU.BytesAvailable == 0 % Clear useless package 
                        break;
                    end
                    fgets(obj.PTU);
                end
            else
                obj.Status = ['Connection to the PTU-IP failed : ' obj.PTU.RemoteHost];
                warning(obj.Status);
            end
        end
        function [Pan_Resolution, Tilt_Resolution] = PTResolution(obj)
            % [Pan_Resolution, Tilt_Resolution] = PTResolution(PTU)
            % Get Pan and Tilt Resolution.
            Pan_Resolution = obj.cmd('PR '); %pan resolution in second of arc
            Pan_Resolution = str2num(Pan_Resolution(2:end))/3600; %convert second of arc to degree
            Tilt_Resolution = obj.cmd('TR '); %tilt resolution in second of arc
            Tilt_Resolution = str2num(Tilt_Resolution(2:end))/3600; %convert second of arc to degree
            obj.Pan_Resolution = Pan_Resolution;
            obj.Tilt_Resolution = Tilt_Resolution;
        end
        function [PLimit, TLimit] = PTLimit(obj)
            % [PLimit TLimit]=PTLimit(PUT)
            % function : determine PTU's pan and tilt limits.
            % PLimit(1) and PLimit(2) are minimum and maximum pan position
            % TLimit(1) and TLimit(2) are minimum and maximum tilt position
            Pan_minimum = obj.cmd('PN '); %minimun pan position in position
            Pan_minimum = str2num(Pan_minimum(2:end)) * obj.Pan_Resolution; %minimun pan position in degree
            Pan_maximum = obj.cmd('PX '); %maximum pan position in position
            Pan_maximum = str2num(Pan_maximum(2:end)) * obj.Pan_Resolution; %maximum pan position in degree
            Tilt_minimum = obj.cmd('TN'); %minimum tilt position in position
            Tilt_minimum = str2num(Tilt_minimum(2:end)) * obj.Tilt_Resolution; %minimum tilt position in degree
            Tilt_maximum = obj.cmd('TX'); %maximum tilt position in position
            Tilt_maximum = str2num(Tilt_maximum(2:end)) * obj.Tilt_Resolution; %maximum tilt position in degree
            PLimit = [Pan_minimum Pan_maximum];
            TLimit = [Tilt_minimum Tilt_maximum];
            obj.Pan_Limit = PLimit;
            obj.Tilt_Limit = TLimit;
        end
        function position = deg2pos(obj, Direction, deg)
            % position = deg2pos(PTU, Direction, deg)
            % function : convert degree to position that is PTU's unit. 
            % PTU : PTU object
            % Direction : P/p for pan, T/t for tilt
            % deg : desire degree
            if Direction == 'P' || Direction == 'p'
                position = round(deg/obj.Pan_Resolution);
            elseif Direction == 'T' || Direction == 't'
                position = round(deg/obj.Tilt_Resolution);
            else 
                error('Select direction P/p/T/t');
                return
            end
        end
        function Status = gotoPT(obj, P_degree,T_degree)
            % PTU_goto(PTU, P_degree,T_degree)
            % make PTU to (P_degree,T_degree)
            Status = 'Out of range';
            if (P_degree - obj.Pan_Limit(1))*(P_degree - obj.Pan_Limit(2)) < 0 ...
                && (T_degree - obj.Tilt_Limit(1))*(T_degree - obj.Tilt_Limit(2)) < 0
                Status = 'Destination is OK';
                P_pos = obj.deg2pos('P', P_degree);
                T_pos = obj.deg2pos('T', T_degree);
                PPpos = ['PP' num2str(P_pos)];
                TPpos = ['TP' num2str(T_pos)];
                obj.cmd(PPpos);
                obj.cmd(TPpos);
            end
        end
        function [Pos, Speed] = getPS(obj)
            % [Pos, Speed] = getPS(PTU)
            % Get current position and speed in both axis.
            % Pos = [PP TP], Speed = [PS TS]
            Pos_Speed = obj.cmd('B '); %查現在的位置與速度
            Pos_Speed = str2num(Pos_Speed(2:end)); %字串轉成數字
            Pos = [Pos_Speed(1) * obj.Pan_Resolution Pos_Speed(2) * obj.Tilt_Resolution]; %角秒轉度數
            Speed = [Pos_Speed(3) * obj.Pan_Resolution Pos_Speed(4) * obj.Tilt_Resolution]; %角秒轉度數
        end
        function SetUserLimit(obj, Pan_minimum, Pan_maximum, Tilt_minimum, Tilt_maximum)
            % SetUserLimit(PTU, Pan_minimum, Pan_maximum, Tilt_minimum, Tilt_maximum)
            % Enable user limit, and set user limits.
            if Pan_minimum < 0 && Pan_maximum > 0 && Tilt_minimum < 0 && Tilt_maximum > 0
                obj.cmd('LU');
                Pan_minimum = floor(obj.deg2pos('P', Pan_minimum));
                Pan_maximum = ceil(obj.deg2pos('P', Pan_maximum));
                Tilt_minimum = floor(obj.deg2pos('T', Tilt_minimum));
                Tilt_maximum = ceil(obj.deg2pos('T', Tilt_maximum));

                PNU = ['PNU' num2str(Pan_minimum)];
                PXU = ['PXU' num2str(Pan_maximum)];
                TNU = ['TNU' num2str(Tilt_minimum)];
                TXU = ['TXU' num2str(Tilt_maximum)];

                obj.cmd(PNU);
                obj.cmd(PXU);
                obj.cmd(TNU);
                obj.cmd(TXU);
                
                obj.PTLimit;
            end
        end
        function delete(obj)
            fclose(obj.PTU);
            delete(obj.PTU);
            delete(obj);
        end
    end
end

