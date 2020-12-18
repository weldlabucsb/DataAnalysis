function [root_dir,camname,pixelsize,mag,photonspercount,h,lambda,c,Ephoton,gamma,Isat,res_crosssec,crosssec,kB,mSr,save_qual,ODsave_qual] = paramsfnc(CameraName)

%ADMIN STUFF
root_dir='../../';%As of now the image folder is two from the doit.m command

%CAMERA CONSTANTS%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    lowerCamName = lower(CameraName);
    switch lowerCamName
        case {'ogblackfly','nonsense'}
            %BLACKFLY CAMERA%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            camname='OGBLACKFLY';
            pixelsize=3.75E-6;%size of pixels in meters
            mag=150/35;
            photonspercount=1;
        case {'odtblackfly','odt','odtbfly'}
            %BLACKFLY CAMERA%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            camname='ODTBLACKFLY';
            pixelsize=3.75E-6;%size of pixels in meters
            mag=500/300;
            photonspercount=1;
        case {'xodtblackfly','xodt','xodtbfly'}
            %BLACKFLY2 CAMERA%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            camname='XODTBLACKFLY';
            pixelsize=6E-6;%size of pixels in meters
            mag=2;
            photonspercount=1;
        case {'latticeblackfly','lattice','latticebfly'}  
            % BLACKFLY CAMERA%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            camname='LAT1BLACKFLY';
            pixelsize=3.75E-6;%size of pixels in meters
            mag=2;
            photonspercount=1;
        case {'andor','vertical','verticalimaging'}
            % % % ANDOR CAMERA%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            camname='ANDOR';
            pixelsize=16E-6;%size of pixels in meters
            mag=8;%0.75;%8
            photonspercount=1;
        case {'demag','tighttrap','tighttrapimaging2018_08_20'}
            %BLACKFLY2 CAMERA%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            camname='TightTrapImaging2018_08_20';
            pixelsize=6E-6;%size of pixels in meters
            mag=35/150;  %maybe???
            photonspercount=1;
        case {'faillattice'}  
            % BLACKFLY CAMERA%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            camname='LAT1BLACKFLY';
            pixelsize=6E-6;%size of pixels in meters
            mag=8/3;
            photonspercount=1;

    end
    %Fundamental and AMO Constants%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    h=6.626E-34;%planck's constant
    lambda=461E-9;%wavelength of light in m
    c=3E8;%speed of light
    Ephoton=h*c/lambda;%energy of 461 photon
    gamma=2*pi*30.5E6;%line width in hertz*rad
    Isat=405.4; % saturation intensity in watts per meter squared
    res_crosssec=gamma*Ephoton/2/Isat;%resonant cross section in m^2
    crosssec=res_crosssec/3; %cross section; to account for polarization, field, etc. in m^2
    kB=1.38E-23;
    mSr=84*1.67E-27;
    save_qual='-r100';
    ODsave_qual='-r50';

end