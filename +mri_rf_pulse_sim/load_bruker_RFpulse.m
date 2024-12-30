function data = load_bruker_RFpulse(filepath)
% Load Bruker RF pulse, usually a .exc .rfc .inv  file
%
% SYNTAX
%   data = load_bruker_RFpulse(filepath)
%
% NOTES
%   data.RF has 2 columns :
%           first  column is MAG, from 0 to 100 (%)
%           second column is PHA, from 0 to 360 (°)
%

if nargin==0, help(mfilename('fullpath')); return; end
data = struct;


%% Checks

assert(exist(filepath, 'file'), 'no file found : %s', filepath)


%% Load

fid = fopen(filepath, 'rt');
assert(fid > 0, 'file cannot be opened : %s', filepath)
content = fread(fid, '*char')'; % read the whole file as a single char
fclose(fid);


%% Parse

data.TITLE          = fetch_char  (content, '##TITLE'          );
data.JCAMP_DX       = fetch_char  (content, '##JCAMP-DX'       );
data.DATA_TYPE      = fetch_char  (content, '##DATA TYPE'      );
data.ORIGIN         = fetch_char  (content, '##ORIGIN'         );
data.OWNER          = fetch_char  (content, '##OWNER'          );
data.DATE           = fetch_char  (content, '##DATE'           );
data.TIME           = fetch_char  (content, '##TIME'           );
data.MINX           = fetch_double(content, '##MINX'           );
data.MAXX           = fetch_double(content, '##MAXX'           );
data.MINY           = fetch_double(content, '##MINY'           );
data.MAXY           = fetch_double(content, '##MAXY'           );
data.SHAPE_EXMODE   = fetch_char  (content, '##$SHAPE_EXMODE'  );
data.SHAPE_TOTROT   = fetch_double(content, '##$SHAPE_TOTROT'  );
data.SHAPE_BWFAC    = fetch_double(content, '##$SHAPE_BWFAC'   );
data.SHAPE_INTEGFAC = fetch_double(content, '##$SHAPE_INTEGFAC');
data.SHAPE_REPHFAC  = fetch_double(content, '##$SHAPE_REPHFAC' );
data.SHAPE_TYPE     = fetch_char  (content, '##$SHAPE_TYPE'    );
data.SHAPE_MODE     = fetch_double(content, '##$SHAPE_MODE'    );
data.NPOINTS        = fetch_double(content, '##NPOINTS'        );
data.XYPOINTS       = fetch_char  (content, '##XYPOINTS'       );
data.RF             = fetch_points(content, data.NPOINTS       );


end % fcn

%--------------------------------------------------------------------------
function value = fetch_char(content, name)
value = fetch_field(content, name);
value = strtrim(value);
end % fcn

%--------------------------------------------------------------------------
function value = fetch_double(content, name)
value = fetch_field(content, name);
value = str2double(value);
end % fcn

%--------------------------------------------------------------------------
function value = fetch_field(content, name)
value = '';

idx_start = strfind(content, name);
if isempty(idx_start), return, end

idx_end = strfind(content(idx_start:end), newline);
if isempty(idx_end), return, end
idx_end = idx_end(1);

idx_equal = strfind(content(idx_start:idx_start+idx_end), '=');
if isempty(idx_equal), return, end

value = content(idx_start+idx_equal:idx_start+idx_end-2);
end % fcn

%--------------------------------------------------------------------------
function value = fetch_points(content, n_points)
if ~isfinite(n_points)
    value = NaN(0,2);
    return
end
value = zeros(n_points,2);

idx_XYPOINTS_start = strfind(content, '##XYPOINTS');
if ~idx_XYPOINTS_start, return, end
idx_XYPOINTS_end = strfind(content(idx_XYPOINTS_start:end), newline);
if ~idx_XYPOINTS_end, return, end
idx_start = idx_XYPOINTS_start + idx_XYPOINTS_end(1);

idx_END = strfind(content, '##END');
idx_end = idx_END-2;

str = content(idx_start:idx_end);

value = cell2mat(textscan(str,'%f, %f\n'));

end % fcn
