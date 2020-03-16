function [R,t]=AxelRotS2(deg,u,x0)
%SYNTAX 2:
%
%       [R,t]=AxelRot(deg,u,x0)
%
% Same as Syntax 1 except that R and t are returned as separate arguments.
M = AxelRotS1(deg,u,x0);
R=M(1:3,1:3);
t=M(1:3,4);
end