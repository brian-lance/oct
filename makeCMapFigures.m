function makeCMapFigures(RESULTPATH)

FIGPATH = [RESULTPATH,'/Figs'];

if ~exist(FIGPATH, 'dir')
    mkdir(FIGPATH)
end
if ~exist([FIGPATH,'/CMaps'], 'dir')
    mkdir([FIGPATH,'/CMaps'])
end

%% MAKE COLORWHEEL
huemap = 10*log10(1 + hsv(64)/1.5);
[X,Y] = meshgrid(-64:.1:64,-64:.1:64);
phase = angle(X+ 1j*Y)/2/pi; mag = abs(X+1j*Y);
indphase = round(64*(phase+0.5));
circle = ind2rgb(indphase,huemap).*mag/max(max(mag));
circle = circle.*(mag<64);
%%

LS = ls([RESULTPATH,'/MScans']);
for filenum = 1:size(LS,1)
    fname = LS(filenum,:);
    if all(fname(1:5)=='MScan')
        load([RESULTPATH,'/MScans/',fname],'freq','delta_f_thresh')
        spl = strsplit(fname,'_');
        scanNum = spl{2}; % Names are like MScan_XXXX.m
        figfilename = [FIGPATH,'/CMaps/CMap_',scanNum(1:4)];
        F = figure('units','normalized','outerposition',[0 0 1 1]);
        subplot(4,4,16);
        image(circle);
        xticks([])
        yticks([])
        for f_ind = 1:length(freq)
            subplot(4,4,f_ind)
            cplx_map = squeeze(delta_f_thresh(:,:,f_ind));
            phase_map = 0.5 + angle(cplx_map)/2/pi;
            ind_hue = round(64*phase_map);
            maxval = max(max(abs(cplx_map)));
            colored_map = ind2rgb(ind_hue,huemap).*abs(cplx_map)./maxval;
            imagesc(colored_map);
            title([num2str(freq(f_ind)),' Hz, Max: ',num2str(maxval,3), ' nm' ])
            xticks([])
            yticks([])
        end
        saveas(F,[figfilename,'.fig'],'fig');
        saveas(F,[figfilename,'.png'],'png');
        close(F);
    end
end

end