function [] = extractOneBScan(OCTPATH,OCTNUM,RESULTPATH)

imNum = int2str(OCTNUM); % Names are like DEFAULT_XXXX_Mode2D.oct

if ~exist(RESULTPATH, 'dir')
    mkdir(RESULTPATH)
end
if ~exist([RESULTPATH,'/BScans'],'dir')
    mkdir([RESULTPATH,'/BScans'])
end

if ~exist([RESULTPATH,'/BScans/BScan_',imNum,'.mat'],'file')        
    mkdir('temp');
    
    unzip([OCTPATH,'/Default_',imNum,'_Mode2D.oct'],'temp');
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