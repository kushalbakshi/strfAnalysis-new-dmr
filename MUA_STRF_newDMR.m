%% Set parameters
bat_list = {'Tb104'};
times_location = ['U:\', bat_list, '\'];
sr = 40000;
channels_available = 32;
save_path = 'C:\Users\kbakshi\Documents\Data\STRF Analysis\';
shank_pos = xlsread('Shank Position.xlsx');

for bat_num = 1:numel(bat_list)
    site_number = 10;
    for site = 1:site_number
        %% Import Data, preprocess, and extract spike times
        load(strjoin(['S:\Smotherman_Lab\Auditory cortex\',string(bat_list(:,bat_num)),...
            '\Matfile\',num2str(site),'_dmr\event.mat'], ''));
        marker = importdata(strjoin(['S:\Smotherman_Lab\Auditory cortex\',string(bat_list(:,bat_num)),...
            '\Data\',string(bat_list(:,bat_num)),'_',num2str(site),'_marker_tc.mat'],''));
        for channel = 1:channels_available
            spikes = readmatrix(...
                [times_location,num2str(site),'_dmr_chn',num2str(channel),'_times.txt']);
            spikes = spikes(:,1);
            spikes(spikes < ts(1,1)) = [];
            spikes(spikes > ts(end,1)) = [];
            depth = marker.depth-shank_pos(channel,1);
            %% Find STRF
            spk = spikes * 1000;
            spiketimes{1}=spk;
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
            [fig1, maxFR] = plotMuASTRF(STA, taxis, faxis, X, depth,...
                    latency, peak_freq, site, channel);
            exportgraphics(fig1, strjoin([save_path,string(bat_list(:,bat_num)),...
                '\Site ',num2str(site),' Chn ',num2str(channel),' STRF.jpg'],''),...
                'Resolution', 300)
            save(strjoin([save_path,string(bat_list(:,bat_num)),...
                '\Site ',num2str(site),' Chn ',num2str(channel),' STA'],''),...
                'STA')
            save(strjoin([save_path,string(bat_list(:,bat_num)),...
                '\Site ',num2str(site),' Chn ',num2str(channel),' faxis'],''),...
                'faxis')
            save(strjoin([save_path,string(bat_list(:,bat_num)),...
                '\Site ',num2str(site),' Chn ',num2str(channel),' taxis'],''),...
                'taxis')
            %% Generate modulation functions
            MTF = fftshift(fft2(STA));
            % find 0 modulation row and col index
            spec0ind = ceil((size(MTF,1)+1)/2);
            temp0ind = ceil((size(MTF,2)+1)/2);
            % only use positive spectral modulation
            MTF = MTF(spec0ind:end,:);
            % find axis values
            Xrange = diff(X(1:2))*length(X);
            trange = diff(taxis(1:2))*length(taxis);
            specmod = (0:size(MTF,1)-1)/Xrange; % cycles per octave
            tempmod = (-(temp0ind-1):(temp0ind-1))/(trange/1000); % Hz
            %% Generate modulation rate figures
            figure;
            fig1 = surface(tempmod,specmod,abs(MTF));
            set(fig1, 'FaceColor','interp','EdgeColor','interp');
            xlim([-100 100])
            ylim([0 10])
            ylim([0 5])
            colorbar
            colormap jet
            title(['Site ',num2str(site), ' Chn ',num2str(channel),' MUA MTF'])
            print(strjoin([save_path,string(bat_list(:,bat_num)),...
                '\Site ',num2str(site),' Chn ',num2str(channel),' MTF'],''),...
                '-dtiff')
            save(strjoin([save_path,string(bat_list(:,bat_num)),...
                '\Site ',num2str(site),' Chn ',num2str(channel),' MTF'],''),...
                'MTF')
            save(strjoin([save_path,string(bat_list(:,bat_num)),...
                '\Site ',num2str(site),' Chn ',num2str(channel),' specmod'],''),...
                'specmod')
            save(strjoin([save_path,string(bat_list(:,bat_num)),...
                '\Site ',num2str(site),' Chn ',num2str(channel),' tempmod'],''),...
                'tempmod')
            close all
        end
        clearvars -except bat_list times_location sr cmap...
            channels_available channel STRF_save_path MTF_save_path...
            ts marker shank_pos d site bat_num cutoff
    end
    
end