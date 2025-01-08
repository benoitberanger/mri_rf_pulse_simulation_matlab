function [pulse, info] = load_siemens_RFpulse(filepath)


if nargin==0, help(mfilename('fullpath')); return; end


%% Open file

fid = fopen(filepath,'r','ieee-le');
assert(fid > 0, 'file cannot be opened : %s', filepath)


%% Fetch file info

info.name           = get_char_in_block(fid, 16*5);
info.dontknow       = fread(fid, 4, 'char')';
info.version        = get_char_in_block(fid, 8);
info.date           = get_char_in_block(fid,28);
info.numer_of_pulse = fread(fid,1,'uint32');
info.author         = get_char_in_block(fid,4*16);
info.checksum       = fread(fid,1,'uint32');


%% Fetch pulses

pulse = struct;
for idx = 1 : info.numer_of_pulse

    pulse(idx).name   = get_char_in_block(fid, 16*2);
    pulse(idx).family = get_char_in_block(fid, 16*2);

    pulse(idx).comment = get_comment_block(fid, 16*32); % bug ?

    val = fread(fid,6,'float64');
    pulse(idx).minslice = val(1);
    pulse(idx).maxslice = val(2);
    pulse(idx).refgrad  = val(3);
    pulse(idx).powint   = val(4);
    pulse(idx).amplint  = val(5);
    pulse(idx).absint   = val(6);

    pulse(idx).date    = get_char_in_block(fid, 28);
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
txt    = block(1:endpos(1)-1);
end % fcn

%--------------------------------------------------------------------------
function txt = get_comment_block(fid, size)
block  = char(fread(fid, size, 'char')');
endpos = strfind(block,sprintf('\0'));
txt    = block(1:endpos(end)-1);
end % fcn
