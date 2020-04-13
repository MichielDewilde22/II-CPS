function M=AxelRotS1(deg,u,x0)
%SYNTAX 1:
%
%    M=AxelRot(deg,u,x0)
%
%
%in:
%
%  u, x0: 3D vectors specifying the line in parametric form x(t)=x0+t*u
%         Default for x0 is [0,0,0] corresponding to pure rotation (no shift).
%         If x0=[] is passed as input, this is also equivalent to passing
%         x0=[0,0,0].
%
%  deg: The counter-clockwise rotation about the line in degrees.
%       Counter-clockwise is defined using the right hand rule in reference
%       to the direction of u.
%
%
%out:
%
% M: A 4x4 affine transformation matrix representing
%    the roto-translation. Namely, M will have the form
%
%                 M=[R,t;0 0 0 1]
%
%    where R is a 3x3 rotation and t is a 3x1 translation vector.
x0=x0(:); u=u(:)/norm(u);

AxisShift=x0-(x0.'*u).*u;

Mshift=mkaff(eye(3),-AxisShift);

Mroto=mkaff(R3d(deg,u));

M=inv(Mshift)*Mroto*Mshift;
end