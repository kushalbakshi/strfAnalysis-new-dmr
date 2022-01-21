%% Set parameters
strf_info = readtable('U:\STRF Analysis\STRFs for SfN.xlsx', 'sheet', 'Spike Sorting');
spike_path = ['C:\Users\kbakshi\Documents\Data\Sorted Waveforms\'];
save_path = ['C:\Users\kbakshi\Documents\Data\STRF Analysis\Sorted\'];
depth_pos = xlsread('S:\Smotherman_Lab\Auditory cortex\NN 4x4 probe depth.xlsx');
RC_pos = xlsread('S:\Smotherman_Lab\Auditory cortex\NN 4x4 probes RC.xlsx');

for n = 1:height(strf_info)
    sorted_files = dir(strjoin([spike_path, strf_info.Animal(n), '\*.txt'], ''));
    
    for file = 11%1:length(sorted_files)
        sorted_data = readmatrix([sorted_files(file).folder, '\',...
            sorted_files(file).name]);
        
        
        if isempty(str2num(sorted_files(file).name(2))) == 0
            load(['C:\Users\kbakshi\Documents\Data\',sorted_files(file).folder(50:end),...
                '\Matfile\',sorted_files(file).name(1:2),'_dmr\event.mat'])
            
            marker = load(['C:\Users\kbakshi\Documents\Data\',sorted_files(file).folder(50:end),...
                '\Data\',sorted_files(file).folder(50:end),'_',...
                sorted_files(file).name(1:2),'_marker_tc.mat']);
            site = sorted_files(file).name(1:2);
        else
            load(['C:\Users\kbakshi\Documents\Data\',sorted_files(file).folder(50:end),...
                '\Matfile\',sorted_files(file).name(1),'_dmr\event.mat'])
            
            marker = load(['C:\Users\kbakshi\Documents\Data\',sorted_files(file).folder(50:end),...
                '\Data\',sorted_files(file).folder(50:end),'_',...
                sorted_files(file).name(1),'_marker_tc.mat']);
            site = sorted_files(file).name(1);
        end
        
        if isempty(str2num(sorted_files(file).name(end-5))) == 0
            channel = sorted_files(file).name(end-5:end-4);
        else
            channel = sorted_files(file).name(end-4);
        end
        depth = marker.depth - depth_pos(str2num(channel),1);
        RC = marker.rostro_caudal - RC_pos(str2num(channel),1);
        
        sorted_data(sorted_data(:,2)<ts(1,1), :) = [];
        sorted_data(sorted_data(:,2)>ts(end,1)+1, :) = [];
        units = unique(sorted_data(:,1));
        
        for unique_value = 1:numel(units)-1
            pos = find(sorted_data(:,1) == unique_value);
            spk = sorted_data(pos, 2) * 1000;
            spiketimes{1} = spk;
            processdata
            STA=DMRcells.STA;
            STA_avg=mean(STA(:));
            STA_stdev=std(STA(:))*3;
            minus_STA_stdev=STA_stdev*-1;
            STA(STA > minus_STA_stdev & STA < STA_stdev) = 0;
            [col,row]=find(STA==max(STA(:)));
            latency=taxis(row);
            peak_freq=faxis(col)/1000;
            [col,row]=find(STA==min(STA(:)));
            min_peak_freq = faxis(col)/1000;
            min_latency = taxis(row);
            [e_spectralBW, e_temporalBW, i_spectralBW, i_temporalBW] = findSTRFbw(STA, taxis, faxis);
            
            %% Create STRF Figure
            [fig1, maxFR] = plotSortedSTRF(STA, taxis, faxis, depth,...
                latency, peak_freq, site, channel, unique_value,...
                sorted_data, pos);
            
            exportgraphics(fig1, [save_path,sorted_files(file).folder(50:end),...
                '\Site ',num2str(site),' Chn ',num2str(channel),...
                ' Unit ', num2str(unique_value), ' STRF.jpg'],...
                'Resolution', 300)
            save([save_path,sorted_files(file).folder(50:end),...
                '\Site ',num2str(site),' Chn ',num2str(channel),...
                ' Unit ', num2str(unique_value),' STA'],...
                'STA')
            save([save_path,sorted_files(file).folder(50:end),...
                '\Site ',num2str(site),' Chn ',num2str(channel),...
                ' Unit ', num2str(unique_value),' faxis'],...
                'faxis')
            save([save_path,sorted_files(file).folder(50:end),...
                '\Site ',num2str(site),' Chn ',num2str(channel),...
                ' Unit ', num2str(unique_value),' taxis'],...
                'taxis')
            
            %% Generate modulation functions
            [MTF, tempmod, specmod] = STRF2MTF(STA, taxis, X);
            [fig2, specmod_max, tempmod_max, specmod_cut, tempmod_cut] =...
                plotSortedMTF(MTF, tempmod, specmod);
            sgtitle(['Site ',num2str(site), ' Chn ',num2str(channel),' Unit ',...
                num2str(unique_value),' MTF'], 'Fontweight', 'bold')
            
            exportgraphics(fig2,...
                [save_path,sorted_files(file).folder(50:end),...
                '\Site ',num2str(site),' Chn ',num2str(channel),...
                ' Unit ', num2str(unique_value),' MTF.jpg'],...
                'Resolution', 300)
            save([save_path,sorted_files(file).folder(50:end),...
                '\Site ',num2str(site),' Chn ',num2str(channel),...
                ' Unit ', num2str(unique_value),' MTF'],...
                'MTF')
            save([save_path,sorted_files(file).folder(50:end),...
                '\Site ',num2str(site),' Chn ',num2str(channel),...
                ' Unit ', num2str(unique_value),' specmod'],...
                'specmod')
            save([save_path,sorted_files(file).folder(50:end),...
                '\Site ',num2str(site),' Chn ',num2str(channel),...
                ' Unit ', num2str(unique_value),' tempmod'],...
                'tempmod')
            close all
        end
    end
end
