%%Define computer-specific variables
ipA = '192.168.1.1';   portA = 9090;   % Modify these values to be those of your first computer.
ipB = '192.168.1.2';  portB = 6969;  % Modify these values to be those of your second computer.
%%Create UDP Object
udpA = udp(ipB,portB,'LocalPort',portA);
%%Connect to UDP Object
fopen(udpA)

data = 7.001

fwrite(udpA, data, 'float32');
% fprintf(udpA,'8')
% fprintf(udpA,'9')

fclose(udpA)
delete(udpA)
clear ipA portA ipB portB udpA