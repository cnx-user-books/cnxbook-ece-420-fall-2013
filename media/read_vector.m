% [c1, c2, c3, c4] = read_vector('filename.out')
%
% Read a saved test vector output (output using File->Data->Store)
% into Matlab vectors. c1-c4 correspond to channels 1 through 4
% of the output signal.  Note that you can save only the first
% few channels by simply leaving out later channels.
% 
% c1=read_vector('filename.out') reads channel 1 into c1.
% [c1, c2]=read_vector('filename.out') reads channel 1 into c1, and
%   channel 2 into c2.

function [c1, c2, c3, c4]=read_vector(file)
fid=fopen(file,'r');
% read header line
x=fscanf(fid,'%x',5);
len=x(5)/4;  % changed to 4 from 2
% read data
vec=fscanf(fid,'%x',[4,len]);  % changed to 2 from 6
% convert from unsigned integer to signed fraction
vec=(vec-((vec>32767)*65536))./32768;
% split into channels
c1=vec(1,:);
c2=vec(2,:);
c3=vec(3,:);
c4=vec(4,:);