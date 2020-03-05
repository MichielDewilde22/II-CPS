close all;
%parameters
matrixSize = [100, 100, 100];
buffer = 1;
maxAngle = deg2rad(15);

origin = [1 1 1];     
endpoint = [46 98 35];

[X,Y,Z] = bresenham_line3d(origin, endpoint);
scatter3(X,Y,Z,'r')
hold on


coneMat = zeros(matrixSize);
for i = 1:length(X)
    coneMat(X(i),Y(i),Z(i)) = 1;
end

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
%                falloffAngle = 1 / (atan(L2distance/projOriginDist));
%                coneMat(xIt,yIt,zIt) = 1 - (falloffAngle/maxAngle);
                if(L2distance<5)
                    coneMat(xIt,yIt,zIt)=1;
                end
            end
        end
    end
end
idx = find(coneMat);
[X,Y,Z] = ind2sub(size(coneMat), idx);
scatter3(X,Y,Z,'B')