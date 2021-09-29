function [sta stavar exclude] = DMRSTA(spiketimes,RD,RP,FsN,Mdb,M,Fs,taxis,X,faxis)
% [sta var exclude] = DMRSTA(spiketimes,RD,RP,FsN,Mdb,M,Fs,taxis,FsSTA,X,faxis)
% calculate spike triggered average and variance from moving ripple stimulus
% spiketimes are in ms
% RD and RP are ripple density and phase sampled at rate FsN
% Mdb is the signal modulation index in db
% original stimulus has M samples at Fs
% taxis gives grid centers of spectral bins relative to spike (in ms)
%    (positive is amount of time prior to spike - assumed to be equally spaced)
% X/faxis gives frequencies in octaves/Hz

sta = zeros(length(faxis),length(taxis));
sta2 = zeros(length(faxis),length(taxis)); % holds sum of squares for variance calc
% ignore spike times where averaging window extends beyond stimulus
dt = diff(taxis(1:2));
exclude = find((spiketimes<(taxis(2)+dt/2)) | (spiketimes>(M*Fs+taxis(1)-dt/2)));
if sum(exclude)>0
    spiketimes(exclude) = [];
    disp(['Excluding ' num2str(length(exclude)) ' spiketimes where averaging window extends beyond stimulus']);
end

% find times of ripple density and phase for interpolation in ms
riptimes = (0:length(RD)-1)*1000/FsN;

% calculate spike triggered average
wb = waitbar(0,'Calculating spike triggered average');
for i=1:length(spiketimes)
    RDint = interp1(riptimes,RD,spiketimes(i)-taxis,'pchip');
    RPint = interp1(riptimes,RP,spiketimes(i)-taxis,'pchip');
    specprof = (Mdb/2)*sin(2*pi*X(:)*RDint+ ones(length(X),1)*RPint);
    sta = sta + specprof;
    sta2 = sta2 + specprof.^2;
    waitbar(i/length(spiketimes),wb);
end
close(wb)
    
stavar = (sta.^2-sta2)/length(spiketimes);
sta = sta/length(spiketimes);

