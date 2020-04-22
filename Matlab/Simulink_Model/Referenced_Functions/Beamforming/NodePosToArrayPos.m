function array_pos = NodePosToArrayPos(node_pos_6DOF, array_type)
%NODEPOSTOARRAYPOS Translates single position of node to positions of
%microphones. 
%   This function calculates the microphone positions of a microphone array
%   given the upper right position of the PCB. This is also the 0 position 
%   of the PCB in the eagle but the PCB is mounted upside down.
%   INPUT: 
%    - node_pos_6DOF: 6 element matrix with 6DOF position of the upper
%    right of the PCB. 
%    - array_type: type of microphone array
%   OUTPUT:
%    - array_pos = [NUMBER_OF_MICROPHONES X 3] matrix. The first dimension
%    is the number of microphones. The second dimension is the X,Y,Z
%    position of the microphones in meters. 
tx = node_pos_6DOF(1); % x translation
ty = node_pos_6DOF(2); % y translation
tz = node_pos_6DOF(3); % z translation
rx = node_pos_6DOF(4); % x rotation (roll)
ry = node_pos_6DOF(5); % y rotation (pitch)
rz = node_pos_6DOF(6); % z rotation (yaw)

% determining the array type and setting the right position in matrix X
switch array_type
    case 1
        % Microphone pos [m] taken from eagle .brd file rounded to 10um
        % Mean is subtrackted from positions as to place the vm on 0,0
        m1 = [0; -0.053+0.042898   ; -0.05334+0.027662];  % Upper Middle
        m2 = [0; -0.00193+0.042898 ; -0.04486+0.027662];  % Upper Left
        m3 = [0; -0.00284+0.042898 ; -0.00437+0.027662];  % Lower left
        m4 = [0; -0.1015+0.042898  ; -0.03264+0.027662];  % Right
        m5 = [0; -0.05522+0.042898 ; -0.0031+0.027662];   % Lower middle
        X = [m1 m2 m3 m4 m5];
        
    case 2
        xo = 0; yo = 0;
        %xo = -0.0552292;
        %yo = 0.02119508;
        m1 = [0; 0.08098+xo   ; -0.04648+yo  ];             % 1  o'clock
        m2 = [0; 0.0019351+xo ; -0.0402808+yo];             % 10 o'clock
        m3 = [0; 0.0196481+xo ; -0.0053902+yo];             % 7  o'clock
        m4 = [0; 0.09862+xo   ; -0.01076+yo  ];             % 4  o'clock
        m5 = [0; 0.0749628+xo ; -0.0030644+yo];             % 5  o'clock
        X = [m1 m2 m3 m4 m5];
        
    case 3 % type X (for research purposes)
        m1 = [0;0;0];
        m2 = [0;0;0];
        m3 = [0;0;0];
        m4 = [0;0;0];
        m5 = [0;0;0];
        X = [m1 m2 m3 m4 m5];
        
    case 4 % type X (for research purposes)
        m1 =  [0; 0.075;  0.015];
        m2 =  [0; 0.080;  0.045];
        m3 =  [0; 0.050;  0.030];
        m4 =  [0; 0.050;  0.015];
        m5 =  [0; 0.0375; 0.030];
        m6 =  [0; 0.025;  0.015];
        m7 =  [0; 0.025;  0.030];
        m8 =  [0; 0.050;  0.045];
        m9 =  [0; 0.080;  0.030];
        m10 = [0; 0.025;  0.045];
        X = [m1 m2 m3 m4 m5 m6 m7 m8 m9 m10];
        
    case 5 % Dense Microphone Array
        % Sorry for long line (copied straight out of matlab data ...)
        X = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0; 0,0.00385000000000000,0.00770000000000000,0.0115500000000000,0.0154000000000000,0.0192500000000000,0,0.00385000000000000,0.00770000000000000,0.0115500000000000,0.0154000000000000,0.0192500000000000,0,0.00385000000000000,0.00770000000000000,0.0115500000000000,0.0154000000000000,0.0192500000000000,0,0.00385000000000000,0.00770000000000000,0.0115500000000000,0.0154000000000000,0.0192500000000000,0,0.00385000000000000,0.00770000000000000,0.0115500000000000,0.0154000000000000,0.0192500000000000,-0.00385000000000000,0.0231000000000000;0,0,0,0,0,0,0.00392500000000000,0.00392500000000000,0.00392500000000000,0.00392500000000000,0.00392500000000000,0.00392500000000000,0.00785000000000000,0.00785000000000000,0.00785000000000000,0.00785000000000000,0.00785000000000000,0.00785000000000000,0.0117750000000000,0.0117750000000000,0.0117750000000000,0.0117750000000000,0.0117750000000000,0.0117750000000000,0.0157000000000000,0.0157000000000000,0.0157000000000000,0.0157000000000000,0.0157000000000000,0.0157000000000000,0.00785000000000000,0.00785000000000000];
        
    case 6 % Sparse Array
        % Sorry for long line (copied straight out of matlab data ...)
        X = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;0.0713199000000000,0.0559937000000000,0.0627530000000000,0.0746011000000000,0.0516150000000000,0.0753151000000000,0.0692641000000000,0.0566183000000000,0.0590784000000000,0.0686230000000000,0.0554513000000000,0.0619409000000000,0.0474081000000000,0.0405907000000000,0.0445493000000000,0.0346723000000000,0.0306642000000000,0.0279093000000000,0.0216575000000000,0.0340955000000000,0.0417510000000000,0.0429328000000000,0.0254422000000000,0.0167401000000000,0.0397049000000000,0.0332629000000000,0.0267112000000000,0.0182494000000000,0.0820608000000000,0.0541519000000000,0.0681365000000000,0.0831930000000000;0.0165156000000000,0.0114385000000000,0.0137861000000000,0.0269445000000000,0.0248797000000000,0.0375623000000000,0.0321843000000000,0.0306573000000000,0.0371883000000000,0.0430750000000000,0.0433577000000000,0.0480624000000000,0.0490132000000000,0.0473835000000000,0.0379034000000000,0.0387521000000000,0.0458742000000000,0.0354821000000000,0.0415567000000000,0.0293215000000000,0.0280059000000000,0.0118968000000000,0.0203133000000000,0.0255606000000000,0.0208079000000000,0.0178647000000000,0.0286996000000000,0.0333188000000000,0.0270596000000000,0.0185505000000000,0.0245647000000000,0.0361448000000000];
    
    otherwise
        error('Unknown type')
end

% applying rotation & translation
[R, T] = AxelRotS0(rx, ry, rz);
T = sum([T'; [tx ty tz]], 1);

array_pos = (X'*R + T)';

end

