function s = evars2array(fname,N)
%EVARS2ARRAY reads a text file generated by exporting an array using the
%eVars plugin in Eclipse.
%   S = EVARS2ARRAY(FNAME,N) assumes the text file FNAME contains an array
%   of length N that was formatted and saved by the eVars Eclipse plugin.
%   It returns the array in an Nx1 vector, S.
% 
% David Jun
% ECE 420 - University of Illinois
% 02/12/2013 v1.1

% open file for reading
h = fopen(fname,'r');

% first line is variable name
fgetl(h);

n=0;
s=zeros(N,1);
while(n < N)
    % compute number of digits for current index
    k = max(0,floor(log10(n)))+1;
    % get line
    line = fgetl(h);
    if(line ~= -1)
        line = strtrim(line);
    else
        % we've somehow hit EOF. maybe N was not correct
        display(sprintf('Only %d of %d elements were read',n,N));
        break;
    end
    % handle eVars-specific formatting
    idx = strfind(line,sprintf('[%d]',n));
    while(isempty(idx))
        line = strtrim(fgetl(h));
        idx = strfind(line,sprintf('[%d]',n));
    end
    % increment index
    n = n+1;
    % convert string to number
    s(n) = str2double(strtrim(line(idx+k+2:end)));
end
fclose(h);
s = s(1:n);

