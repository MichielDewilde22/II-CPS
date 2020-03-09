classdef HDS
    %HDS A class for sending data to the human detection system (HDS). 
    
    properties (SetAccess = private)
        IP % IP address of the HDS
        port % Port for sending data
        HDS_socket % socket for HDS communication
        % Possibly some values for transforming the angles
    end
    
    methods
        function obj = HDS(send_IP, send_port)
            %HDS Constructor which opens the UDP socket.
            obj.IP = send_IP; 
            obj.port = send_port;
            obj.HDS_socket = udp(obj.IP, obj.port);
            fopen(obj.HDS_socket);
        end
        
        function close(obj)
            %CLOSE is a method for closing the UDP socket, the socket
            % should alwarys be closed after usage to avoid errors.
            fclose(obj.HDS_socket);
        end
        
        function send_angles(obj, horizontal_angle, azimuth_angle)
            %SEND_ANGLES is a method for sending the horizontal and azimuth
            %angle to the HDS. Later on we could possibly include some 
            %angle transformation code (radians => degrees, ...). The HDS
            %system should receive the angles in the following format:
            % - angles in degrees
            % - first angle is the horizontal angle
            % - second angle is the azimuth angle
            % - they are send in a string, seperated by a ",".
            send_string = horizontal_angle + "," + azimuth_angle;
            fwrite(obj.HDS_socket, send_string);
        end
    end
end

