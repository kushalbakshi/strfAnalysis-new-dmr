function [fig1, maxRate] = plotMuASTRF(STA, taxis, faxis, X, depth, latency, peak_freq, site, channel)
% Generates a highly annotated STRF figure including depth of recording
% site, latency/integration time of the excitatory component, peak
% frequency of the excitatory component

fig1 = figure('Color', 'w', 'Position', [30 50 1200 800]);
ss = surface(taxis,X,STA);
set(ss,'edgecolor','none');
xlabel('Time (ms)')
ylabel('Frequency (kHz)')
xlim([0 200])
ylim([0 max(X)])
set(gca,'xdir','reverse');
set(gca,'view',[0 90])
colormap jet
lim=caxis;
caxis([-lim(1,2),lim(1,2)])
c_bar=colorbar;
maxRate = lim(1,2);
ylabel(c_bar,'Firing rate')
annotation('textbox',[.6 .9 .1 .1],'string',...
    ['Depth: ',num2str(depth),' µm'],'Edgecolor','none',...
    'FontSize',12)

annotation('textbox',[.6 .87 .1 .1],'string',...
    ['Latency of peak excitation: ',num2str(latency),' ms'],...
    'Edgecolor','none','FontSize',12)

annotation('textbox',[.71 .902 .1 .1],'string',...
    ['Freq at peak excitation: ',num2str(peak_freq),' kHz'],...
    'Edgecolor','none','FontSize',12)

title(['Site ',num2str(site), ' Chn ',num2str(channel),' MUA STRF'], 'FontSize', 14)