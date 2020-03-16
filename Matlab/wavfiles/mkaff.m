function M=mkaff(varargin)
% M=mkaff(R,t)
% M=mkaff(R)
% M=mkaff(t)
%
%Makes an affine transformation matrix, either in 2D or 3D.
%For 3D transformations, this has the form
%
% M=[R,t;[0 0 0 1]]
%
%where R is a square matrix and t is a translation vector (column or row)
%
%When multiplied with vectors [x;y;z;1] it gives [x';y';z;1] which accomplishes the
%the corresponding affine transformation
%
% [x';y';z']=R*[x;y;z]+t
%



if nargin==1
  
  switch numel(varargin{1})
    
    case {4,9} %Only rotation provided, 2D or 3D
      
      R=varargin{1};
      nn=size(R,1);
      t=zeros(nn,1);
      
    case {2,3}
      
      t=varargin{1};
      nn=length(t);
      R=eye(nn);
      
  end
else
  
  [R,t]=deal(varargin{1:2});
  nn=size(R,1);
end

t=t(:);

M=eye(nn+1);

M(1:end-1,1:end-1)=R;
M(1:end-1,end)=t(:);
end