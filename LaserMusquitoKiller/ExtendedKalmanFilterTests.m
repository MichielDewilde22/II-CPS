verschil(6000) = 0;
timestep = 0.01;
%X = X + v * sin(thetha) * cos(phi);
%X = X + delta * v * (sin(thetha1) + cos(thetha1)*(thetha-thetha1))*(cos(phi1) - sin(phi1) * (phi - phi1));
%Y = Y + v * sin(thetha) * sin(phi);
%Z = Z + v * cos(thetha);
%v = v;
%thetha = thetha;
%phi = phi;
Zt = [intersections(1,1);intersections(1,2);intersections(1,3);1;1;1];
v = 2;
thetha = 0;
phi = 0;

Xt1t1 = [intersections(1,1);intersections(1,2);intersections(1,3);v;thetha;phi];
Pt1t1 = diag([0.05 0.05 0.05 1 1 1]);
Xinprev = intersections(1,1);
Yinprev = intersections(1,2);
Zinprev = intersections(1,3);

Xinprevprev = intersections(1,1);
Yinprevprev = intersections(1,2);
Zinprevprev = intersections(1,3);
Xinprevprevprev = intersections(1,1);
Yinprevprevprev = intersections(1,2);
Zinprevprevprev = intersections(1,3);


F = [1 0 0 timestep*sin(thetha)*cos(phi) 0 0; 0 1 0 timestep*sin(thetha)*sin(phi) 0 0;
 0 0 1 timestep*cos(thetha) 0 0; 0 0 0 1 0 0; 0 0 0 0 1 0; 0 0 0 0 0 1];
H = [1 0 0 0 0 0; 0 1 0 0 0 0; 0 0 1 0 0 0; 0 0 0 1 0 0; 0 0 0 0 1 0; 0 0 0 0 0 1];

Rk = [0.05 0 0 0 0 0; 0 0.05 0 0 0 0; 0 0 0.05 0 0 0; 0 0 0 3 0.05 0.05; 0 0 0 0.05 0.05 0.05; 0 0 0 0.05 0.05 0.05];

% Rk = [0.005 0.008 0.03 0 0 0; 0 0.005 0 0 0 0; 0.1 0.8 0.05 0 0 0;
%     0 0 0 5 1 1; 0 0 1 0 5 4; 2 1 2 1 2 5];

Q = [0.10 0 0 0 0 0; 0 0.10 0 0 0 0; 0 0 0.10 0 0 0;
    0 0 0 2 0 0; 0 0 0 0 0.5 0; 0 0 0 0 0 0.5];

for i = 1:5998
    v = Xt1t1(4);
    thetha = Xt1t1(5);
    phi = Xt1t1(6);
    Xin = intersections(i+1,1);
    Yin = intersections(i+1,2);
    Zin = intersections(i+1,3);
    v1 = (sqrt((Xin-Xinprevprevprev)^2+(Yin-Yinprevprevprev)^2+(Zin-Zinprevprevprev)^2)/timestep)/3;
    thetha1 = atan2 (sqrt((Xin-Xinprevprevprev)^2+(Yin-Yinprevprevprev)^2),(Zin-Zinprevprevprev));
    phi1 = atan2(Xin-Xinprevprevprev, Yin-Yinprevprevprev);
    F = [1 0 0 timestep*sin(thetha)*cos(phi) 0 0; 0 1 0 timestep*sin(thetha)*sin(phi) 0 0;
    0 0 1 timestep*cos(thetha) 0 0; 0 0 0 1 0 0; 0 0 0 0 1 0; 0 0 0 0 0 1];
    %v1 = sqrt((locations(i+1,1)-locations(i,1))^2+(locations(i+1,2)-locations(i,2))^2+(locations(i+1,3)-locations(i,3))^2)/timestep 
    
Xtt1 = F * Xt1t1;
Ptt1 = F * Pt1t1 * F.' + Q;
Zt = [intersections(i+1,1);intersections(i+1,2);intersections(i+1,3);v1;thetha1;phi1];
Yt = Zt - H * Xtt1;
St = H * Ptt1 * H.' + Rk;
K = (Ptt1 * H.') / St;
Xtt = Xtt1 + K * Yt;
Ptt = (diag([1 1 1 1 1 1]) - K * H) * Ptt1;



Xt1t1 = Xtt;
Pt1t1 = Ptt;
Xinprev = intersections(i+1,1);
Yinprev = intersections(i+1,2);
Zinprev = intersections(i+1,3);
Xinprevprev = Xinprev;
Yinprevprev = Yinprev;
Zinprevprev = Zinprev;
Xinprevprevprev = Xinprevprev;
Yinprevprevprev = Yinprevprev;
Zinprevprevprev = Zinprevprev;

if(Xtt(1) > 5)
    Xtt(1) = 5;
elseif(Xtt(1) < 0)
    Xtt(1) = 0;
end

if(Xtt(2) > 5)
    Xtt(2) = 5;
elseif(Xtt(2) < 0)
    Xtt(2) = 0;
end

if(Xtt(3) > 2.5)
    Xtt(3) = 2.5;
elseif(Xtt(3) < 0)
    Xtt(3) = 0;
end

Fnew = [1 0 0 timestep*sin(thetha)*cos(phi) 0 0; 0 1 0 timestep*sin(thetha)*sin(phi) 0 0;
    0 0 1 timestep*cos(thetha) 0 0; 0 0 0 1 0 0; 0 0 0 0 1 0; 0 0 0 0 0 1];

Xttnew = Fnew * Xtt;

SaveX(i+1) = Xttnew(1);
SaveY(i+1) = Xttnew(2);
SaveZ(i+1) = Xttnew(3);
verschil(i+1) = sqrt((locations(i+1,1) - Xtt(1))^2 + (locations(i+1,2) - Xtt(2))^2 + (locations(i+1,3) - Xtt(3))^2);
verschilpredictions(i+1) = sqrt((locations(i+1,1) - Xttnew(1))^2 + (locations(i+1,2) - Xttnew(2))^2 + (locations(i+1,3) - Xttnew(3))^2);
verschilpredictionsmeasurements(i+1) = sqrt((locations(i+1,1) - intersections(i,1))^2 + (locations(i+1,2) - intersections(i,2))^2 + (locations(i+1,3) - intersections(i,3))^2);
verschilX(i+1) = sqrt((locations(i+1,1) - Xttnew(1))^2);
verschilMeasurementsX(i+1) = sqrt((locations(i+1,1) - intersections(i+1,1))^2);
verschilpredictionsmeasurementsX(i+1) = sqrt((locations(i+1,1) - intersections(i,1))^2);
end
sum(verschil)
sum(verschilpredictions)
sum(error_beams)
sum(verschilpredictionsmeasurements)
sum(verschilX)
sum(verschilMeasurementsX)
sum(verschilpredictionsmeasurementsX)
