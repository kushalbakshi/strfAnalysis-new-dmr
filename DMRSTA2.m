function [stRD stFM exclude] = DMRSTA2(spiketimes,RD,RP,FsN,Mdb,M,Fs,taxis,X,faxis)
% [stRD stFM exclude] = DMRST2(spiketimes,RD,RP,FsN,Mdb,M,Fs,taxis,FsSTA,X,faxis)
% calculate spike triggered distribution of RD and FM from moving ripple stimulus
% spiketimes are in ms
% RD and RP are ripple density and phase sampled at rate FsN
% Mdb is the signal modulation index in db
% original stimulus has M samples at Fs
% taxis gives grid centers of spectral bins relative to spike (in ms)
%    (positive is amount of time prior to spike - assumed to be equally spaced)
% X/faxis gives frequencies in octaves/Hz

FMdt = 1; % change in time to find derivative of RP in msec
% ignore spike times where averaging window extends beyond stimulus
dt = diff(taxis(1:2));
exclude = find((spiketimes<(taxis(2)+dt/2)) | (spiketimes>(M*Fs+taxis(1)-dt/2)));
if sum(exclude)>0
    spiketimes(exclude) = [];
    disp(['Excluding ' num2str(length(exclude)) ' spiketimes where averaging window extends beyond stimulus']);
end
stRD = zeros(length(spiketimes),length(taxis));
stFM = zeros(length(spiketimes),length(taxis)); % holds sum of squares for variance calc

% find times of ripple density and phase for interpolation in ms
riptimes = (0:length(RD)-1)*1000/FsN;

% calculate spike triggered average
wb = waitbar(0,'Calculating spike triggered average of RD and FM');
for i=1:length(spiketimes)
    stRD(i,:) = interp1(riptimes,RD,spiketimes(i)-taxis,'pchip');
    RPint1 = interp1(riptimes,RP,spiketimes(i)-taxis+FMdt,'pchip');
    RPint2 = interp1(riptimes,RP,spiketimes(i)-taxis-FMdt,'pchip');
    stFM(i,:) = (RPint1-RPint2)/(2*FMdt);
    waitbar(i/length(spiketimes),wb);
end
close(wb)


