function [fig2, specmod_max, tempmod_max, specmod_cut, tempmod_cut] =...
    plotSortedMTF(MTF, tempmod, specmod)

fig2 = figure('Color', 'w', 'Position', [30 50 1200 800]);
ax1 = axes('Position', [.15 .1 .75 .65]);
s2 = surface(ax1, tempmod,specmod,abs(MTF));
set(s2, 'FaceColor','interp','EdgeColor','interp');
xlim([-100 100])
xlabel('Temporal Modulation (Hz)')
ylim([0 5])
ylabel('Spectral Modulation (cycles/octave)')
cbar = colorbar;
colormap jet

MTF = abs(MTF);
[~, r_max] = max(MTF(:));
[col, row] = ind2sub([158 401], r_max);
specmod_max = specmod(col);
tempmod_max = tempmod(row);

ax2 = axes('Position', [.05 .1 .07 .65]);
plot(MTF(:,row), specmod)
title(ax2, 'sMTF')
cbar_lim = get(cbar, 'Limits');
cutoff = cbar_lim(2)*0.5;
set(gca, 'xdir', 'reverse', 'xlim', [cutoff cbar_lim(2)],...
    'ylim', [0 5], 'Visible', 'off')
set(findall(gca, 'type', 'text'), 'visible', 'on')

xData = get(get(gca, 'children'), 'XData');
yData = get(get(gca, 'children'), 'Ydata');
specmod_cut = interp1(xData, yData, cutoff);


ax3 = axes('Position', [.15 .78 .65 .07]);
plot(tempmod, MTF(col, :))
title(ax3, 'tMTF')
set(gca, 'xlim', [-100 100], 'ylim', [0 cbar_lim(2)], 'Visible', 'off')
set(findall(gca, 'type', 'text'), 'visible', 'on')

xData = get(get(gca, 'children'), 'XData');
yData = get(get(gca, 'children'), 'Ydata');
[x0, ~] = intersections(xData, yData, xData, repelem(cutoff, length(xData)));
tempmod_cut = max(x0);
% sgtitle(['Site ',num2str(site), ' Chn ',num2str(channel),' Unit ',unit,' MTF'],...
%     'Fontweight', 'bold')