function [coneMat] = intensityCone3D(ori,endp)
%parameters
matrixSize = [100, 100, 100];
buffer = 1;
maxAngle = deg2rad(5); %half of the total angle of the cone

origin = ori;
endpoint = endp;

[X,Y,Z] = bresenham_line3d(origin, endpoint);
coneMat = zeros(matrixSize);

for i = 1:length(X)
    coneMat(X(i),Y(i),Z(i)) = 1;
end

for xIt = 1: length(coneMat(:,1,1))
    for yIt = 1: length(coneMat(1,:,1))
        for zIt = 1: length(coneMat(1,1,:))
            currentCell = [xIt,yIt,zIt];
            
            %distance point point = sqrt((x2-x1)^2 + (y2-y1)^2 + (z2-z1)^2)
            originDist = sqrt(sum((origin-currentCell).^2));
            lineLength = sqrt(sum((origin-endpoint).^2));
            L2distance = point_to_line(currentCell, origin,endpoint);
            %See pythogorian: can only be used if sqrt(originDist^2-L2distance^2) <
            %length of line
            projOriginDist = sqrt(originDist^2-L2distance^2);
            if  projOriginDist < (lineLength + buffer)
                %Will be looked at later for performance, maybe calculate
                %tangent of angle in advance and use "case system"
                falloffAngle = (atan(L2distance/projOriginDist));
                if(1 - (falloffAngle/maxAngle)<0)
                    coneMat(xIt,yIt,zIt)=0;
                else
                    coneMat(xIt,yIt,zIt) = 1 - (falloffAngle/maxAngle);
                end
                
%                if(L2distance>projOriginDist/4)
%                    coneMat(xIt,yIt,zIt)=0;
%                else
%                    coneMat(xIt,yIt,zIt)=1;
%                end
            end
        end
    end
end

end

