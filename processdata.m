% process spike times
% calculate and store ISI distribution and STA 
% start with cell array of spiketime lists

filename = 'processeddata.mat';

sigcut = 4; % number of standard errs for significance
% preliminaries
load('dmr-5000flo-80000fhi-4SM-40TM-40db-200000khz-48DF-15min_param');

% initialize structure for each cell
DMRcell.ISIs = [];
DMRcell.spikenum = 0;
DMRcell.rate = 0;
DMRcell.STA = zeros(length(taxis),length(faxis));
% DMRcell.STAvar = zeros(length(taxis),length(faxis));
DMRcell.exclude = [];
DMRcell.excludednum = 0;
DMRcell.sigpix = 0; % number of significant pixels
DMRcell.sigavg = 0; % average abs(STA) for significant pixels
DMRcell.RDdist = [];
DMRcell.FMdist = [];
 
% initialize structure array
DMRcells(length(spiketimes)) = DMRcell;

% save parameters
FsN = Fsn; % RD and RP are specified at this sample rate
Mdb = App; % amplitude range for spectrogram
stderrSTA = Mdb/sqrt(8); % standard dev of sinusoid with (half) amplitude Mdb/2
Mbin = 100; % number of samples for each spectral bin in STA
% Mchunk = 32000;
mnRD = mean(RD);
stdRD = std(RD);
mnFM = mean(FM);
stdFM = std(FM);
trange = [0 200]; % take STA for trange msec relative to spike
taxis = trange(1):1000*Mbin/Fs:trange(2); 
save(filename,'spiketimes','RD','RP','mnRD','stdRD','mnFM','stdFM',...
    'FsN','Mdb','M','Fs','taxis','X','faxis','Mbin','stderrSTA','sigcut');

% for i=1:length(spiketimes)
for i=1:1
    tmpDMRcell = processDMRcell(spiketimes{i},RD,RP,FsN,Mdb,M,Fs,taxis,X,faxis,stderrSTA,sigcut);
    DMRcells(i) = tmpDMRcell;
    save(filename,'DMRcells','-append');
end
