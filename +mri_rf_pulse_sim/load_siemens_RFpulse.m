function [pulse, info] = load_siemens_RFpulse(filepath)
% Load Siemens 'external' RF pulses, using "extrf.dat"
%
% SYNTAX
%   [pulse, info] = load_siemens_RFpulse(filepath)
%
% OUTPUT
%   pulse : struct array
%   info  : struct containing the file info
%
% ------------------------------- EXEMPLE ---------------------------------
%
% [pulse, info] = mri_rf_pulse_sim.load_siemens_RFpulse('vendor/siemens/mypulselib.dat')
%
% pulse =
%
%   1×42 struct array with fields:
%
%     name
%     family
%     comment
%     minslice
%     maxslice
%     refgrad
%     powint
%     amplint
%     absint
%     date
%     samples
%     mag
%     pha
%
%
% info =
%
%   struct with fields:
%
%               name: 'mypulselib'
%           dontknow: [0 0 0 0]
%            version: 'V0200'
%               date: 'Fri Dec 06 00:42:42 2024'
%     numer_of_pulse: 42
%             author: 'benoitberanger'
%           checksum: 42424242
%
% pulse(1)
%
% ans =
%
%   struct with fields:
%
%         name: 'SPAMM'
%       family: 'TAGGING'
%      comment: 'binomial [1 1]'
%     minslice: 1
%     maxslice: 500
%      refgrad: 2.00
%       powint: 110.1
%      amplint: 125.531
%       absint: 134.57
%         date: 'Fri Dec 06 00:24:24 2024'
%      samples: 256
%          mag: [256×1 double]
%          pha: [256×1 double]
%
% -------------------------------------------------------------------------

if nargin==0, help(mfilename('fullpath')); return; end


%% Open file

fid = fopen(filepath,'r','ieee-le'); % little endian -> necessary to read the numerical values correctly
assert(fid > 0, 'file cannot be opened : %s', filepath)


%% Fetch file info

info.name           = get_char_in_block(fid, 80);
info.dontknow       = fread(fid,4,'char')';
info.version        = get_char_in_block(fid,  8);
info.date           = get_char_in_block(fid, 28);
info.numer_of_pulse = fread(fid,1,'uint32');
info.author         = get_char_in_block(fid, 64);
info.checksum       = fread(fid,1,'uint32');


%% Fetch pulses

pulse = struct;
for idx = 1 : info.numer_of_pulse

    pulse(idx).name    = get_char_in_block(fid,  32);
    pulse(idx).family  = get_char_in_block(fid,  32);

    pulse(idx).comment = get_comment_block(fid, 512);

    val = fread(fid,6,'float64');
    pulse(idx).minslice = val(1);
    pulse(idx).maxslice = val(2);
    pulse(idx).refgrad  = val(3);
    pulse(idx).powint   = val(4);
    pulse(idx).amplint  = val(5);
    pulse(idx).absint   = val(6);

    pulse(idx).date    = get_char_in_block(fid,  28);
    pulse(idx).samples = fread(fid,1,'uint32');
    datapoints         = fread(fid,pulse(idx).samples*2,'float32');
    pulse(idx).mag     = datapoints(1:2:end); % [0 ; 1]
    pulse(idx).pha     = datapoints(2:2:end); % [-pi/2 ; pi/2]

end

fclose(fid);


end % fcn

%--------------------------------------------------------------------------
function txt = get_char_in_block(fid, size)
block  = char(fread(fid, size, 'char')');
endpos = strfind(block,sprintf('\0'));
txt    = block(1:endpos(1)-1); % stop at first nullchar
end % fcn

%--------------------------------------------------------------------------
function txt = get_comment_block(fid, size)
block  = char(fread(fid, size, 'char')');
endpos = strfind(block,sprintf('\0'));
txt    = block(1:endpos(end)-1); % stop at last nullchar in the block
end % fcn
