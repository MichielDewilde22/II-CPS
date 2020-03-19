function [sig_out] = rdc(sig_in)
%RDC Removes the mean from a signal
%   Only implemented for 1D & 2D signals. The rest will folow :)


if(isvector(sig_in)==1)
    sig_out = sig_in - mean(sig_in);
else

    ndim = length(size(sig_in));
    n_sps = size(sig_in,ndim);
    
    repmatvec = ones(1,ndim);
    repmatvec(ndim) = n_sps;
    sig_out = sig_in - repmat(mean(sig_in,ndim),repmatvec);

%     n_ch = size(sig_in,1);
%     for cnt = 1:n_ch
%         sig_in(cnt,:) = sig_in(cnt,:) - mean(sig_in(cnt,:));
%     end;
%     sig_out = sig_in;    

    
    
end;