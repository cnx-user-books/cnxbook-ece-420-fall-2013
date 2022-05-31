% sweep(start_freq,end_freq,amp,length)
%
% Generates a length-element vector consisting of a frequency sweep from
% the digital frequency start_freq to the digital frequency end_freq (both
% frequencies should be between 0 and pi). The frequency sweep has amplitude
% amp (i.e., values between -amp and amp).

function vec=sweep(start_freq,end_freq,amp,length)
phase = 0;
freq = start_freq;
freq_incr = (end_freq-start_freq)/length;
vec=zeros(1,length);
for i=1:length
  vec(1,i)=sin(phase)*amp;
  phase=phase+freq;
  freq = freq+freq_incr;
end
