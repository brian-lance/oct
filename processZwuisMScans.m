function [] = processZwuisMScans(CRAWPATH,CRAWNUMS,STIMPATH,RESULTPATH,SNRTH)

    if ~exist(RESULTPATH, 'dir')
        mkdir(RESULTPATH)
    end
    if ~exist([RESULTPATH,'/MScans'],'dir')
        mkdir([RESULTPATH,'/MScans'])
    end

    lambda0 = 900; indref = 1.34;

    load([STIMPATH,'/StimDef.mat'],'St');

    for CRAWNUM = CRAWNUMS
        if ~exist([RESULTPATH,'/MScans/MScan_',int2str(CRAWNUM),'.mat'],'file')
        fid = fopen([CRAWPATH,'/Default_',int2str(CRAWNUM),'_Mode3D.craw']);
        MScan = fread(fid,'float');
        fclose(fid);
        MScan = MScan(1:2:end) + 1j*MScan(2:2:end);
        MScan = reshape(MScan,[],20275,20); % z dim is different depending on run
        % t dim is always 20275 samples
        % y dim is set to 20 (for now, may need to change later)
        MScan = permute(MScan,[1,3,2]);
        
        avgA = squeeze(mean(abs(MScan).^2,3));
        
        delta_t = angle(MScan)*lambda0/(4*pi*indref);
        
        emptyTriggers = 125; % we send triggers to OCT for bg collection/flyback
        % these samples are not in the craw data, but ARE in the stimulus
        
        NpreFlat = St.NsamPreFlat/5; % the stimulus ramps up 
        Nflat = St.NsamFlat/5; % this is how long the stimulus is flat
        % divide by 5 bc the stimulus is sent at 100kHz, but OCT records at 20kHz
        startInd = 1+NpreFlat-emptyTriggers;
        endInd = startInd + Nflat - 1;
        
        df = 20000/Nflat; % fft frequency spacing
        
        freqInds = St.nFreq + 1; % log is 0-indexed. I'm using matlab lol
        freq = df.*St.nFreq; % stimulus freqs in Hz
        delta_f_full = fft(delta_t(:,:,startInd:endInd),Nflat,3);
        delta_f = delta_f_full(:,:,freqInds) ...
        ./exp(1j*2*pi*reshape(St.StartPhase,1,1,length(freq))); 
        % Frequency response at stim freqs. subtract out start phases
        
        %% Compute noise now bleh
        noises = zeros(size(delta_f));
        for ff = 1:length(freqInds)
            % look at the 20 frequency components surrounding each stim freq
            centerInd = freqInds(ff);
            bin = abs(delta_f_full(:,:,[(centerInd-11):(centerInd-1),...
                                        (centerInd+1):(centerInd+11)]));
            noises(:,:,ff) = mean(bin,3);
        end
        SNRs = abs(delta_f)./noises;
        delta_f_thresh = delta_f; delta_f_thresh(SNRs<SNRTH) = NaN;
    
        save([RESULTPATH,'/MScans/MScan_',int2str(CRAWNUM),'.mat'],"freq","avgA", ...
             "delta_f_thresh","SNRs")
    end
end