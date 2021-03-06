% Received translation from Qualisys is the xyx position of the upper right of the pcb.
% This is also the 0 position of the pcb in eagle but
% The pcb is mounted upside down. 
% For a default rotation of [0, 0, 0], all microphones lie in the YZ plane
function X = nodeToX(node, relative)
  tx   = node(1);
  ty   = node(2);
  tz   = node(3);
  rx   = node(4);
  ry   = node(5);
  rz   = node(6);
  type = node(7);
  
  if exist('relative', 'var')
    tx = 0;
    ty = 0;
    tz = 0;
    rx = 0;
    ry = 0;
    rz = 0;
  end
  
  % Microphone postitions [m] taken from eagle .brd file rounded to 10um
  % Mean is subtrackted from positions as to place the vm on 0,0
  if (type == 1) % Type M
    m1 = [0; -0.053+0.042898   ; -0.05334+0.027662];         % Upper Middle
    m2 = [0; -0.00193+0.042898 ; -0.04486+0.027662];         % Upper Left
    m3 = [0; -0.00284+0.042898 ; -0.00437+0.027662];         % Lower left
    m4 = [0; -0.1015+0.042898  ; -0.03264+0.027662];         % Right
    m5 = [0; -0.05522+0.042898 ; -0.0031+0.027662];          % Lower middle
    X = [m1 m2 m3 m4 m5];
  elseif (type == 2)
    xo = 0; yo = 0;
    %xo = -0.0552292;
    %yo = 0.02119508;
    m1 = [0; 0.08098+xo   ; -0.04648+yo  ];                 % 1  o'clock
    m2 = [0; 0.0019351+xo ; -0.0402808+yo];                 % 10 o'clock
    m3 = [0; 0.0196481+xo ; -0.0053902+yo];                 % 7  o'clock
    m4 = [0; 0.09862+xo   ; -0.01076+yo  ];                 % 4  o'clock
    m5 = [0; 0.0749628+xo ; -0.0030644+yo];                 % 5  o'clock
    X = [m1 m2 m3 m4 m5];
  elseif (type == 3)  % type X (for research purposes)
    m1 = [0;0;0];
    m2 = [0;0;0];
    m3 = [0;0;0];
    m4 = [0;0;0];
    m5 = [0;0;0];
    X = [m1 m2 m3 m4 m5];
  elseif (type == 4)  % type X (for research purposes)
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
    
  elseif (type == 5) %Dense Array
      mic_pos_final_pos = load('mic_pos_sonar_stm32_dense.mat');
      X = [zeros(1,32); cell2mat(struct2cell(mic_pos_final_pos))'];
  
  elseif (type == 6) %Sparse Array
      mic_pos_final_pos = load('mic_pos_sonar_stm32.mat');
      X = [zeros(1,32); cell2mat(struct2cell(mic_pos_final_pos))'];      
  else 
    error('Unknown type')
  end
  
  [R, T] = AxelRotS0(rx, ry, rz);
  T = sum([T'; [tx ty tz]], 1);
  X = (X'*R + T)';
end
