close all;
%parameters
matrixSize = [100, 100, 100];
buffer = 1;
maxAngle = deg2rad(15);

origin = [12 37 6];     
endpoint = [46 3 35];

[X,Y,Z] = bresenham_line3d(origin, endpoint);	


coneMat = zeros(matrixSize);
for i = 1:length(X)
    coneMat(X(i),Y(i),Z(i)) = 1;
end

% plot3(X,Y,Z,'*');
% xlim([0 matrixSize])
% ylim([0 matrixSize])
% zlim([0 matrixSize])

for xIt = 1: length(coneMat(:,1,1))
    for yIt = 1: length(coneMat(1,:,1))
        for zIt = 1: length(coneMat(1,1,:))
            currentCell = [xIt,yIt,zIt];
            
            %distance point point = (x2-x1)^2 + (y2-y1)^2 + (z2-z1)^2
            originDist = sum((origin-currentCell).^2);
            lineLength = sum((origin-endpoint).^2);
            L2distance = point_to_line(currentCell, origin,endpoint);
            %See pythogorian: can only be used if sqrt(originDist^2-L2distance^2) <
            %length of line
            projOriginDist = sqrt(originDist^2-L2distance^2);
            if  projOriginDist < (lineLength + buffer)
               falloffAngle = 1 / (atan(L2distance/projOriginDist));
               coneMat(xIt,yIt,zIt) = 1 - (falloffAngle/maxAngle);
            end
        end
    end
end