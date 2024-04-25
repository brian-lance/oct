function makeBScanFigures(RESULTPATH)

FIGPATH = [RESULTPATH,'/Figs'];

if ~exist(FIGPATH, 'dir')
    mkdir(FIGPATH)
end
if ~exist([FIGPATH,'/BScans'], 'dir')
    mkdir([FIGPATH,'/BScans'])
end

%%

LS = ls([RESULTPATH,'/BScans']);
for filenum = 1:size(LS,1)
    fname = LS(filenum,:);
    if all(fname(1:5)=='BScan')
        load([RESULTPATH,'/BScans/',fname],'Ny','Nz','Dz','Dy','BScan')
        spl = strsplit(fname,'_');
        scanNum = spl{2}; % Names are like BScan_XXXX.m
        figfilename = [FIGPATH,'/BScans/BScan_',scanNum(1:4)];
        F = figure;
        z = linspace(0,Dz,Nz); y = linspace(0,Dy,Ny);
        imagesc(y,z,BScan); colormap gray;
        pbaspect([Dy,Dz,1])
        saveas(F,[figfilename,'.fig'],'fig');
        saveas(F,[figfilename,'.png'],'png');
        close(F);
    end
end

end