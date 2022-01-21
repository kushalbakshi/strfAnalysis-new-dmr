%% Set parameters
bat_list = {'Tb111'};
times_location = ['S:\Smotherman_Lab\Auditory cortex\'];
sr = 40000;
channels_available = 16;
save_path = 'S:\Smotherman_Lab\Auditory cortex\STRF Analysis\';
[b, a] = butter(2, 500/(sr/2), 'high');

for bat_num = 1:numel(bat_list)
    bat_dir = dir(strjoin([times_location, bat_list(bat_num),...
        '\Matfile\*_dmr'], ''));
    site_number = length(bat_dir);
    
    for site = 5%1:site_number
        %% Import Data, preprocess, and extract spike times
        load(strjoin([times_location,string(bat_list(:,bat_num)),...
            '\Matfile\',num2str(site),'_dmr\event.mat'], ''));
        marker = importdata(strjoin([times_location,string(bat_list(:,bat_num)),...
            '\Data\',string(bat_list(:,bat_num)),'_',num2str(site),'_marker_tc.mat'],''));
        for channel = 6%1:channels_available
            load(strjoin([times_location,string(bat_list(:,bat_num)),...
            '\Matfile\',num2str(site),'_dmr\Chn',num2str(channel),'.mat'], ''));
            data = data(1, ts(1)*sr:ts(end)*sr);
            data = filtfilt(b, a, data);
            thr = 4 * std(data);
            [pks, locs] = findpeaks(data*-1, 'MinPeakHeight', thr);
            spk = locs/sr;
            spk = spk * 1000;
            spk(diff(spk) < 1) = [];
            spk = spk';
            spiketimes{1}=spk;
            %% Find STRF
            processdata
            STA=DMRcells.STA;
            STA_avg=mean(STA(:));
            STA_stdev=std(STA(:))*3;
            minus_STA_stdev=STA_stdev*-1;
            STA(STA > minus_STA_stdev & STA < STA_stdev) = 0;
            [col,row]=find(STA==max(STA(:)));
            latency=taxis(row);
            peak_freq=faxis(col)/1000;
            
            %% Create STRF Figure
            [fig1, maxFR] = plotMuASTRF(STA, taxis, faxis, X);
%             exportgraphics(fig1, strjoin([save_path,string(bat_list(:,bat_num)),...
%                 '\Site ',num2str(site),' Chn ',num2str(channel),' STRF.jpg'],''),...
%                 'Resolution', 300)
%             save(strjoin([save_path,string(bat_list(:,bat_num)),...
%                 '\Site ',num2str(site),' Chn ',num2str(channel),' STA'],''),...
%                 'STA')
%             save(strjoin([save_path,string(bat_list(:,bat_num)),...
%                 '\Site ',num2str(site),' Chn ',num2str(channel),' faxis'],''),...
%                 'faxis')
%             save(strjoin([save_path,string(bat_list(:,bat_num)),...
%                 '\Site ',num2str(site),' Chn ',num2str(channel),' taxis'],''),...
%                 'taxis')
            %% Generate modulation functions
            [MTF, tempmod, specmod] = STRF2MTF(STA, taxis, X);
            fig2 = plotMTF(MTF, tempmod, specmod);
            sgtitle(['Site ',num2str(site), ' Chn ',num2str(channel),' MUA MTF'], 'Fontweight', 'bold')
%             exportgraphics(fig2,...
%                 strjoin([save_path,string(bat_list(:,bat_num)),...
%                 '\Site ',num2str(site),' Chn ',num2str(channel),' MTF.jpg'],''),...
%                 'Resolution', 300)
%             save(strjoin([save_path,string(bat_list(:,bat_num)),...
%                 '\Site ',num2str(site),' Chn ',num2str(channel),' MTF'],''),...
%                 'MTF')
%             save(strjoin([save_path,string(bat_list(:,bat_num)),...
%                 '\Site ',num2str(site),' Chn ',num2str(channel),' specmod'],''),...
%                 'specmod')
%             save(strjoin([save_path,string(bat_list(:,bat_num)),...
%                 '\Site ',num2str(site),' Chn ',num2str(channel),' tempmod'],''),...
%                 'tempmod')
%             close all
            
        end
            clearvars -except bat_list times_location sr b a...
                channels_available channel save_path...
                ts marker bat_dir site bat_num site_number
    end    
end