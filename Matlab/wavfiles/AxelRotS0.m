function [R, T] = AxelRotS0(Xr, Yr, Zr)
  Xr = -Xr;
  Yr = -Yr;
  Zr = -Zr;

  [Rx, Tx] = AxelRotS2(Xr,[1,0,0],[0,0,0]);
  [Ry, Ty] = AxelRotS2(Yr,[0,1,0],[0,0,0]);
  [Rz, Tz] = AxelRotS2(Zr,[0,0,1],[0,0,0]);
  R = Rx*Ry*Rz;
  T = Tx+Ty+Tz;
end

