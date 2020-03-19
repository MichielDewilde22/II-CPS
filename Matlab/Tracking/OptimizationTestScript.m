%RANDOM SHIT WAAR IK AAN DENK OM NI TE VERGETE
%find(A) op 3D matrices geeft lineaire numers bvb 3x3x3 1->27
%dus element 9 is X3 Y3 Z1
%ind2sub ga van lin naar 3coords
%arrayfun gebruike om een functie toe te passen op elke cel van ne matrix
%arrayfun can meerdere matrices gebruike
%dus lin array van 1-...... waardoor elke cel zijn coord krijgt in lin vorm
%in die functie dan ind2sub gebruike om coord te krijge en daarmee rekene
tic;
dims = [500,500,500];
A=1:1:(dims(1)*dims(2)*dims(3));
B=reshape(A,dims);
B=gpuArray(B);
C=arrayfun(@testFun,B);
C=gather(C);
toc;