clear all;
close all;

bits=1; % PN generator seed

Nt=1024; % Number of total data points 
Np=32; % Number of data points in each block of direct PSD estimate
     % 2Np-1 samples of total-data autocorrelation used in autocorr PSD estimate
     % Np must be element {2, 4, 8, ..., Nt/2}
Nb=round(Nt/Np); % Number of blocks
Na=2*Np-1; % Number of autocorrelation points kept
fftsize=Nt;

% Windows

zeropts=round(Nt-Np);
apsdwin=[zeros(1,zeropts) ones(1,Na) zeros(1,zeropts)];
dpsdwin=hamming(Np)';%rectwin(Np)';
fulldpsdwin=rectwin(round(0.5*Nt))';

% PN sequence generator

bitsarr=cell(1,Np*Nb); % PN generator bits in binary string form
B=16; % Number of bits in shift register
seq=zeros(1,Np*Nb);

% Generate "random" bits and sequence

for q=1:Nt
   nextbit=xor(bitand(bits,2^15),bitand(bits,2^1));
   nextbit=xor(bitand(bits,2^0),nextbit);
   bits=bitxor(bitshift(bits,1,B),nextbit);
   if nextbit==0
      seq(q)=1;
   else
      seq(q)=-1;
   end
   bitsarr{q}=dec2bin(bits,B);
end

disp('Some consecutive values of the shift register:');
disp(sprintf('%s\n',bitsarr{40:50}));

% Calculate psd of total PN sequence

pnpsd=fft(seq,fftsize); pnpsd=pnpsd.*conj(pnpsd);

% Calculate coloring filter and filter PN sequence

b=[32767 0 0 0 13421]/32767;
a=19345/32767;
h=freqz(a,b,fftsize,'whole');
seq=filter(a,b,seq);

% Estimates from Nt/2-point block of data

blk=seq(1:round(0.5*fftsize));

fulldpsd=fft(blk.*fulldpsdwin,fftsize);
fulldpsd=fulldpsd.*conj(fulldpsd);

fullapsd=abs(fft(xcorr(blk,blk,'biased'),fftsize));

% First-block-only estimates

blk=seq((Nt-Np+1):(Nt));

dpsd1=fft(blk.*dpsdwin,fftsize);
dpsd1=dpsd1.*conj(dpsd1);

apsd1=abs(fft(xcorr(blk,blk,'biased'),fftsize));

dpsdsum=zeros(1,fftsize);

% Estimates from total data (all blocks)

for q=1:Nb
   blk=seq([((q-1)*Np+1):q*Np]);
   dpsdsum=dpsdsum+abs(fft(blk.*dpsdwin,fftsize)).^2;
end
dpsd=dpsdsum/Nb;

apsd=abs(fft(xcorr(seq,seq,'biased').*apsdwin,fftsize));

% Plots

str=num2str(round(0.5*fftsize));
subplot(211); plot(fulldpsd*2/fftsize);
title(['Direct PSD, ' str '-point block']);
set(gca,'XLim',[0 Nt]);
subplot(212); plot(fullapsd);
title(['Autocorr PSD, ' str '-point block'])
set(gca,'XLim',[0 Nt]);

figure; str=num2str(Np);
subplot(211); plot(dpsd1/Np);
title(['Direct PSD, first ' str '-point block only']);
set(gca,'XLim',[0 Nt]);
subplot(212); plot(apsd1);
title(['Autocorr PSD, first ' str ...
       '-point block only, all autocorrelation points']);
set(gca,'XLim',[0 Nt]);

figure;
subplot(211); plot(dpsd/Np);
title(['Direct PSD, all ' str '-point blocks']);
set(gca,'XLim',[0 Nt]);
subplot(212); plot(apsd);
title(['Autocorr PSD, ' num2str(Na) ...
       ' autocorrelation points, entire sequence used']);
set(gca,'XLim',[0 Nt]);

figure; str=num2str(fftsize);
subplot(211); plot(pnpsd/fftsize);
title(['Spectrum of ' str '-point PN sequence']);
set(gca,'XLim',[0 Nt]);
subplot(212); plot(abs(h).^2);
title(['Impulse response of coloring filter']);
set(gca,'XLim',[0 Nt]);
