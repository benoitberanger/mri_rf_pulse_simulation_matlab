function pulse2RFfile(pulse, fname)
% Dumps the pulse waveforms (B1 & GZ) into a .RF file
%
% SYNTAX
%   pulse2RFfile(pulse, fname)
%

mag = pulse.magnitude;
mag = mag / max(mag) * 1023;

pha = rad2deg(pulse.phase);

grad = pulse.GZ;
grad = grad / max(grad);

content_numeric = [pha(:) mag(:) grad(:)];

save(fname,'content_numeric','-ascii', '-double', '-tabs' )

end % fcn
