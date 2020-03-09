% send_socket = udp('127.0.0.1', 6969);
% fopen(send_socket);
% a = 69.6969;
% b = 6666.66;
% send_string = a + "," + b;
% fwrite(send_socket, send_string);
% fclose(send_socket);

hds = HDS('192.168.69.10',6969);
for i=1:10
   hds.send_angles(45.0-i, 35.0+i); 
end
hds.close();
