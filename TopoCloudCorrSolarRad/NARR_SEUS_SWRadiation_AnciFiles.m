function NARR_SEUS_SWRadiation_AnciFiles(iyear)
%--------------------------------------------------------------------------
% By Jing Tao, Duke University
% Last updated: 10/10/2013
%--------------------------------------------------------------------------

out_dir='/home/jt85/HMT-SEUS/Mat/SEUS_NARR_1hr1km_UTM_SW_Anci/';
modisAOD_dir='/home/jt85/HMT-SEUS/Mat/SEUS_MODIS_ProFill/Aerosol-MOD08_D3-1000m1day/';
modisAlbedo_dir='/home/jt85/HMT-SEUS/Mat/SEUS_MODIS_ProFill_1hr1km/Albedo/';
home_dir='/home/jt85/HMT-SEUS/Program/';
trans_dir='/home/jt85/HMT-SEUS/Mat/SEUS_SRB_TRA_1hr1km_UTM_UTC_Fill/';

%-----------------------------------------------
% for iyear=2007:2011
for imon=1:12
imonstr=sprintf('%.2d',imon);
starday=1;
for iday=starday:eomday(iyear,imon)
    
    idaystr=sprintf('%.2d',iday);

    %Optional: Obtaining transmittance from MODIS AOD data
    %load([modisAOD_dir,int2str(iyear),'/','Aerosol_',int2str(iyear),doystr,'.mat']);%AOD
    %T=exp(-1*AOD);

for ihour=0:23
    ihrstr=sprintf('%.2d',ihour);
    fstr=[int2str(iyear),imonstr,idaystr,ihrstr];
    oudir=[out_dir,int2str(iyear),'/',fstr,'/'];
    if exist(oudir,'dir')==0;mkdir(oudir);end
    
    %---MODIS Albedo
    load([modisAlbedo_dir,int2str(iyear),'/',fstr,'.mat']);Albedo=data;
    save([oudir,'Albedo.txt'],'Albedo','-ascii', '-double');

    %---sunrise&sunset---
    latlon=load('/home/jt85/IPW/HMT_SEUS/Data/latlon.txt');
    sunrise =NaN(length(latlon),1);
    sunset =NaN(length(latlon),1);
    %---Generated by CalSunriseSunset.sh
    tmp=load([oudir,'sunrisesunset.dat']);%daylength,sunrise,solar_noon,sunset
    sunrise(~isnan(latlon(:,1)))=tmp(:,2);
    sunset(~isnan(latlon(:,1)))=tmp(:,4);
    sunrise = reshape(sunrise,716,610);sunrise=sunrise';
    sunset = reshape(sunset,716,610);sunset=sunset';
    save([oudir,'sunrisesunset.mat'],'sunrise','sunset');
    
    %Interpolated hourly radiation data already corrected for cloudiness
    %Generated by NARR_SEUS_SWRadiation_1hr1km_CloudCorr.m
    ounm='shortwave_Final_from1hrSpatialPdfCorr.mat';%Already corrected for cloudiness
    load([oudir,ounm]);shortwave=NARRcorrSW;
    
    %Generated by SRB_TRA_SEUS_1kmhourly_UTM.m
    load([trans_dir,int2str(iyear),'/',fstr,'.mat']);
    T=transmi;T(isnan(T))=0.0;T(T>1)=1.0;
    Dirct=shortwave.*T;Diff=shortwave.*(1-T);
    save([oudir,'Diff_CloudCorr.txt'],'Diff','-ascii', '-double');
    save([oudir,'Dirct_CloudCorr.txt'],'Dirct','-ascii', '-double');
    
    fnm=[oudir,'Cosillumi.bin'];
    if exist(fnm,'file')>0
    fid=fopen(fnm,'r');
    tmp=fread(fid,inf,'single');
    fclose(fid);
    if size(tmp,1)==0
        data=ones(610,716);
    else
    data=reshape(tmp,716,610)';
    end
    
    fnm=[oudir,'NARR_Terrain_Cosillumi.bin'];
    fid=fopen(fnm,'r');
    tmp=fread(fid,inf,'single');
    fclose(fid);
    if size(tmp,1)==0
        datanarr=ones(610,716);
    else
    datanarr=reshape(tmp,716,610)';
    end
    
    cosillu=data./datanarr;
    else
        cosillu=ones(610,716);
    end
    save([oudir,'Cosillumi_Scaled.txt'],'cosillu','-ascii', '-double');
    
end
end
end

cd(home_dir);

% end
end