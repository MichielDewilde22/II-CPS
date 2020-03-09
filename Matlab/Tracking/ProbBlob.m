close all

arrayLoc1=[1 1 1];  end1=[80 80 80];
arrayLoc2=[1 80 1]; end2=[80 1 80];
arrayLoc3=[80 1 1]; end3=[1 80 80];
tic
matCone1=intensityCone3D(arrayLoc1,end1);
matCone2=intensityCone3D(arrayLoc2,end2);
matCone3=intensityCone3D(arrayLoc3,end3);

coneMat=matCone1.*matCone2.*matCone3;

[mxv,index] = max(coneMat,[],[1 2 3],'linear');
[mosqX,mosqY,mosqZ] = ind2sub(size(coneMat),index);

idx = find((0.25>coneMat)&(0<coneMat));
[X,Y,Z] = ind2sub(size(coneMat), idx);
scatter3(X,Y,Z,'B')

idx = find((0.5>coneMat)&(0.25<coneMat));
[X,Y,Z] = ind2sub(size(coneMat), idx);
scatter3(X,Y,Z,'Gr')
idx = find((0.75>coneMat)&(0.5<coneMat));
[X,Y,Z] = ind2sub(size(coneMat), idx);
scatter3(X,Y,Z,'Y')
idx = find(coneMat>0.75);
[X,Y,Z] = ind2sub(size(coneMat), idx);
scatter3(X,Y,Z,'R')

