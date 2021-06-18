classdef PositionGenerator < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private)
        % node position [x y z]
        pos
    end
    
    methods
        function obj = PositionGenerator(x0,y0,z0)
            %UNTITLED Construct an instance of this class
            %   Detailed explanation goes here
            obj.pos = [x0, y0, z0];
        end
        
        function nextPos(obj,x,y,z)
            obj.pos = [obj.pos; x,y,z];
        end
        
        function moveTo(obj,end_pos,dt)
            t_size = size(obj.pos,1);
            inc_pos = (end_pos - obj.pos(t_size,:))/dt;
            for t = t_size : t_size+dt-1
                obj.pos = [obj.pos; obj.pos(t,:) + inc_pos];
            end
        end
        
        function move(obj,dir,dt,speed)
            % dir: direction axis
            % dt: number of time steps
            % speed: position increment multiplier
            switch dir
                case 'north'
                    inc_pos = [0 +1 0];
                case 'south'
                    inc_pos = [0 -1 0];
                case 'east'
                    inc_pos = [+1 0 0];
                case 'west'
                    inc_pos = [-1 0 0];
                case 'up'
                    inc_pos = [0 0 +1];
                case 'down'
                    inc_pos = [0 0 -1];
                otherwise
                    inc_pos = [0 0 0];
            end
            t_size = size(obj.pos,1);
            for t = t_size : t_size+dt-1
                obj.pos = [obj.pos; obj.pos(t,:) + speed.*inc_pos];
            end
        end
        
        function zigzag(obj)
            obj.move('north',30,1);
            obj.move('east',7,1);
            obj.move('south',2,1);
            obj.move('stop',5,1);
            obj.move('north',2,1);
            obj.move('east',7,1);
            obj.move('south',2,1);
            obj.move('stop',5,1);
            obj.move('north',2,1);
            obj.move('east',3,1);
        end
       
        function savefile(obj,nodeId)
            filename = num2str(nodeId,'NodePosition%d.dat');
            writematrix(obj.pos, filename, 'Delimiter','comma');
        end
    end
end

