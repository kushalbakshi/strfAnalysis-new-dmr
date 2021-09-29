function [DMRcell] =  processDMRcell(spiketimes,RD,RP,FsN,Mdb,M,Fs,taxis,X,faxis,stderrSTA,sigcut)
% DMRcell =  processDMRcell(spiketimes,RD,RP,taxis,FsN,X,faxis,stderrSTA,sigcut)
% calculate STA, pre-spike ripple distribution and ISIs 
% for a single cell
% 
[STA STAvar exclude] = DMRSTA(spiketimes,RD,RP,FsN,Mdb,M,Fs,taxis,X,faxis);
tmpspiketimes = spiketimes;
tmpspiketimes(exclude) = [];
ISIs = sort(diff(tmpspiketimes));
rate = length(tmpspiketimes)/(M/Fs);
DMRcell.STA = STA;
DMRcell.exclude = exclude;
DMRcell.excludednum = length(exclude);
tmpspiketimes = spiketimes;
tmpspiketimes(exclude) = [];
DMRcell.ISIs = sort(diff(tmpspiketimes));
DMRcell.spikenum = length(tmpspiketimes);
DMRcell.rate = length(tmpspiketimes)/(M/Fs);
% find significant part of STA
tmpSTA = STA;
stderr = stderrSTA/sqrt(DMRcell.spikenum);
nonsiginds = abs(tmpSTA)<sigcut*stderr;
DMRcell.sigpix = sum(sum(~nonsiginds));
if DMRcell.sigpix>0
    sigSTA = tmpSTA(~nonsiginds);
    DMRcell.sigavg = mean(abs(sigSTA(:)))/stderrSTA;
else
    DMRcell.sigavg = 0;
end

% calc spike triggered RD and FM
[RDdisttmp FMdisttmp] = DMRSTA2(spiketimes,RD,RP,FsN,Mdb,M,Fs,taxis,X,faxis);
DMRcell.RDdist = RDdisttmp;
DMRcell.FMdist = FMdisttmp;

