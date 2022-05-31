% save_test_vector(file, left, right, up down)
% 
% Save a test vector include file based on the left-input and
% right-input vectors given. If 'right','up','down' is omitted, the same
% input is sent to both the left and right channels.

function save_test_vector(file, left, varargin)
if nargin == 2
    right = left;
    up = left;
    down = left;
else
    if nargin ==3 
        right=varargin{1};
        up = left;
        down = right;
    else
        if nargin ==4
            right = varargin{1};
            up = varargin{2};
            down = left;
        else
            if narargin == 5
                right = varargin{1};
                up = varargin{2};
                down = varargin{3};
            end
        end
    end
end

if length(left) ~= length(right) 
  disp('Left and right vector length mismatch')
else
  fid = fopen(file, 'wt');
  fprintf(fid,'     .global _tv_inbuf\n');
  fprintf(fid,'     .global _tv_outbuf\n');
  fprintf(fid,'     .global _tv_count_addr\n');
  fprintf(fid,'_tv_count .set %i\n',length(left));
  x = zeros(length(left)*4,1);      % changed to 4 
  x(1:4:4*length(left)) = left;
  x(2:4:4*length(left)) = right;
  x(3:4:4*length(left)) = up;
  x(4:4:4*length(left)) = down;
  fprintf(fid,' .sect ".etext"\n');
  fprintf(fid,'_tv_outbuf\n');
  fprintf(fid,' .space 16*%i\n',4*length(left));
  fprintf(fid,'_tv_inbuf\n');
  x = round(x*32768);
  x = x - (x > 32767);
  fprintf(fid,' .word %i\n',x);
  fprintf(fid,' .sect ".data"\n');
  fprintf(fid,'_tv_count_addr .word %i\n',length(left));
  fclose(fid);
end
