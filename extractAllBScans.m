function [] = extractAllBScans(pd,RESULTPATH)

if ~exist(RESULTPATH, 'dir')
    mkdir(RESULTPATH)
end
if ~exist([RESULTPATH,'/BScans'],'dir')
    mkdir([RESULTPATH,'/BScans'])
end

LS = ls(pd);
for ff = 1:size(LS,1)
    fname = LS(ff,:);
    if all(fname(1:7)=='Default')
        spl = strsplit(fname,'_');
        imNum = spl{2}; % Names are like DEFAULT_XXXX_Mode2D.oct
        if ~exist([RESULTPATH,'/BScans/BScan_',imNum,'.mat'],'file')
            if ~exist("temp",'dir')
                mkdir('temp');
            end 

            unzip([pd,'/Default_',imNum,'_Mode2D.oct'],'temp');
            head = xml2struct('temp/Header.xml');
            Nz = str2double(head.Ocity.Image.SizePixel.SizeZ.Text); % number of z pixels
            Ny = str2double(head.Ocity.Image.SizePixel.SizeX.Text); % number of y pixels
            Dz = str2double(head.Ocity.Image.SizeReal.SizeZ.Text); % total depth in mm
            Dy = str2double(head.Ocity.Image.SizeReal.SizeX.Text); % total width in mm
    
            fid = fopen("temp/data/Intensity.data");
            BScan = fread(fid,'float');
            fclose(fid);
            BScan = reshape(BScan,[Nz,Ny]);
            save([RESULTPATH,'/BScans/BScan_',imNum,'.mat'],'BScan','Ny','Nz','Dy','Dz')
            rmdir('temp','s');
        
        end
    end
end

end