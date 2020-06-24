Z = peaks;
surf(Z); 
axis tight manual 
set(gca,'nextplot','replacechildren'); 

v = VideoWriter('peaks.avi');
open(v);

for k = 1:20 
   surf(sin(2*pi*k/20)*Z,Z)
   frame = getframe(gcf);
   writeVideo(v,frame);
end

close(v);