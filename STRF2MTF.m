function [MTF tempmod specmod] = calcMTF(STRF,taxis,Xaxis)
% function [MTF tempmod specmod] = calcMTF(STRF,Xaxis,taxis)
% calculate complex valued modulation transfer function given a STRF matrix
% taxis gives the time axis for the STRF in msec
% Xaxis gives the frequency values in octaves
% tempmod is the temporal modulation values in Hz
% specmod is the spectral modulation values in cycles per octave

MTF = fftshift(fft2(STRF));
% find 0 modulation row and col index
spec0ind = ceil((size(MTF,1)+1)/2);
temp0ind = ceil((size(MTF,2)+1)/2);
% only use positive spectral modulation
MTF = MTF(spec0ind:end,:);
% find axis values
Xrange = diff(Xaxis(1:2))*length(Xaxis);
trange = diff(taxis(1:2))*length(taxis);
specmod = (0:size(MTF,1)-1)/Xrange; % cycles per octave
tempmod = (-(temp0ind-1):(temp0ind-1))/(trange/1000); % Hz
