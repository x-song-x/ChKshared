function msg = SetupPointGreyCams
global Xin

%% Search All PointGrey Cameras
try 
    info = imaqhwinfo('pointgrey');
    % All PointGrey cameras' name would be listed
catch
    errordlg('PointGrey cameras cannot be located')
end

%% Locate Each Camera, Reset if necessary
pass =      0;
resettime = 0;
while pass == 0
    pass = 1;
    imaqreset;      % reset cameras
    resettime = resettime + 1;
    disp('reseting cameras');
    for i = 1:length(info.DeviceInfo)
        info.hVid = videoinput('pointgrey', i, info.DeviceInfo(i).DefaultFormat);
        info.hSrc = getselectedsource(info.hVid);
        for j = 1:length(Xin.D.Sys.PointGreyCam) 
            if strcmp(  Xin.D.Sys.PointGreyCam(j).DeviceName,	info.DeviceInfo(i).DeviceName) && ...
               strcmp(  Xin.D.Sys.PointGreyCam(j).SerialNumber,	info.hSrc.SerialNumber)
                Xin.D.Sys.PointGreyCam(j).Located = i;    
                info.pSrc = propinfo(info.hSrc); 
                info.CurShutterLimit = info.pSrc.Shutter.ConstraintValue(2) - Xin.D.Sys.PointGreyCam(j).ShutterResv; 
                if abs(info.CurShutterLimit/Xin.D.Sys.PointGreyCam(j).ShutterTarget -1) >0.01
                    pass = pass*0;
                end
            end     
        end
        delete(info.hVid);
    end
    if resettime > 10
        disp('cannot get the shutter right')
        pass = 1;
    end
end

%% Shared settings
        
%% Setting Up Cameras
for i = 1:length(Xin.D.Sys.PointGreyCam)  
    
    ic = 1;
    Xin.D.Sys.PointGreyCam(i).TriggerMode(ic).Name =              'SoftwareGrab';
    Xin.D.Sys.PointGreyCam(i).TriggerMode(ic).TriggerType =       'immediate';
    Xin.D.Sys.PointGreyCam(i).TriggerMode(ic).TriggerCondition =  'none';
    Xin.D.Sys.PointGreyCam(i).TriggerMode(ic).TriggerSource =     'none';    
    ic = 2;
    Xin.D.Sys.PointGreyCam(i).TriggerMode(ic).Name =              'SoftwareRec';
    Xin.D.Sys.PointGreyCam(i).TriggerMode(ic).TriggerType =       'immediate';
    Xin.D.Sys.PointGreyCam(i).TriggerMode(ic).TriggerCondition =  'none';
    Xin.D.Sys.PointGreyCam(i).TriggerMode(ic).TriggerSource =     'none';
    ic = 3;
    Xin.D.Sys.PointGreyCam(i).TriggerMode(ic).Name =              'HardwareRec';
    Xin.D.Sys.PointGreyCam(i).TriggerMode(ic).TriggerType =       'hardware';
    Xin.D.Sys.PointGreyCam(i).TriggerMode(ic).TriggerCondition =  'risingEdge';
    Xin.D.Sys.PointGreyCam(i).TriggerMode(ic).TriggerSource =     Xin.D.Sys.PointGreyCam(i).TriggerSource;
    
    ic = 1;
    Xin.D.Sys.PointGreyCam(i).TriggerName =      Xin.D.Sys.PointGreyCam(i).TriggerMode(ic).Name;  
    Xin.D.Sys.PointGreyCam(i).TriggerType =      Xin.D.Sys.PointGreyCam(i).TriggerMode(ic).TriggerType;         
    Xin.D.Sys.PointGreyCam(i).TriggerCondition = Xin.D.Sys.PointGreyCam(i).TriggerMode(ic).TriggerCondition; 
    Xin.D.Sys.PointGreyCam(i).TriggerSource =    Xin.D.Sys.PointGreyCam(i).TriggerMode(ic).TriggerSource;  
    
    if Xin.D.Sys.PointGreyCam(i).Located
        Xin.HW.PointGrey.Cam(i).hVid = videoinput('pointgrey',...
                                        Xin.D.Sys.PointGreyCam(i).Located,...
                                        Xin.D.Sys.PointGreyCam(i).Format);
        set(Xin.HW.PointGrey.Cam(i).hVid,...
            'UserData',                                 ['PGC(', num2str(i), ').hVid']);  
        Xin.HW.PointGrey.Cam(i).hSrc = getselectedsource( Xin.HW.PointGrey.Cam(i).hVid);
             
        %% Getting Parameters from Cameras        
        pVid = propinfo(Xin.HW.PointGrey.Cam(i).hVid);
        pSrc = propinfo(Xin.HW.PointGrey.Cam(i).hSrc); 

        %% General Fixed Settings for all Cameras in XINTRINSIC & FANTASIA
        Xin.HW.PointGrey.Cam(i).hVid.LoggingMode =      'memory';   % do not use VideoWriter, since initial binning is necessary
        Xin.HW.PointGrey.Cam(i).hVid.FramesPerTrigger =	1;          % one frame/trigger
        Xin.HW.PointGrey.Cam(i).hSrc.Brightness =       pSrc.Brightness.ConstraintValue(1);  
                                                                  % the lowest possible brightness
        Xin.HW.PointGrey.Cam(i).hSrc.FrameRateMode =    'Manual';   % customized lock
        if isfield(pSrc, 'Gamma')
            Xin.HW.PointGrey.Cam(i).hSrc.Gamma =        1;          % 1 = linear
            Xin.HW.PointGrey.Cam(i).hSrc.GammaMode =	'Off';      % customized lock
        end
        if isfield(pVid, 'Sharpness')
            Xin.HW.PointGrey.Cam(i).hSrc.Sharpness =	1024;       % 1024 = do nothing
            Xin.HW.PointGrey.Cam(i).hSrc.SharpnessMode ='Off';      % customized lock 
        end
        Xin.HW.PointGrey.Cam(i).hSrc.Strobe1 =          'Off';      % disable
        Xin.HW.PointGrey.Cam(i).hSrc.Strobe2 =          'Off';      % disable
        Xin.HW.PointGrey.Cam(i).hSrc.Strobe3 =          'Off';      % disable
        Xin.HW.PointGrey.Cam(i).hSrc.TriggerDelay =     0;          % immediately
        Xin.HW.PointGrey.Cam(i).hSrc.TriggerParameter =	1;          % ? DCAM property
        Xin.HW.PointGrey.Cam(i).hSrc.TriggerDelayMode = 'Off';      % no delay
        Xin.HW.PointGrey.Cam(i).hSrc.ExposureMode = 	'Off';       
        Xin.HW.PointGrey.Cam(i).hSrc.ShutterMode =      'Manual';  
        Xin.HW.PointGrey.Cam(i).hSrc.GainMode =         'Manual';         

        %% Variable Settings for Individual Cameras
            Xin.HW.PointGrey.Cam(i).hSrc.FrameRate =	Xin.D.Sys.PointGreyCam(i).FrameRate;
        pause(1.0);
        pSrc = propinfo(Xin.HW.PointGrey.Cam(i).hSrc); 
        Xin.D.Sys.PointGreyCam(i).Shutter =             pSrc.Shutter.ConstraintValue(2) - ...
                                                        Xin.D.Sys.PointGreyCam(i).ShutterResv;                                                    
        Xin.D.Sys.PointGreyCam(i).ShutterRange =        [pSrc.Shutter.ConstraintValue(1) Xin.D.Sys.PointGreyCam(i).Shutter];
            Xin.HW.PointGrey.Cam(i).hSrc.Shutter =      Xin.D.Sys.PointGreyCam(i).Shutter;        
        
        Xin.D.Sys.PointGreyCam(i).GainRange =        	pSrc.Gain.ConstraintValue;  
        switch Xin.D.Sys.PointGreyCam(i).GainPolar
            case 'Min' 
                Xin.D.Sys.PointGreyCam(i).Gain =        Xin.D.Sys.PointGreyCam(i).GainRange(1); 
            case 'Max' 
                Xin.D.Sys.PointGreyCam(i).Gain =        Xin.D.Sys.PointGreyCam(i).GainRange(2);
            otherwise
                errordlg(['PointGrey Camera #', num2str(i), ': unidentifiable "GainPolar"']);
                Xin.D.Sys.PointGreyCam(i).Gain =        Xin.D.Sys.PointGreyCam(i).GainRange(1); 
        end 
            Xin.HW.PointGrey.Cam(i).hSrc.Gain =         Xin.D.Sys.PointGreyCam(i).Gain;
        
        Xin.D.Sys.PointGreyCam(i).DispGainBit =         0;
        Xin.D.Sys.PointGreyCam(i).DispGainNum =         2^Xin.D.Sys.PointGreyCam(i).DispGainBit;
        
        % % For Color Cameras
        % Xin.HW.PointGrey.Cam(i).hSrc.WhiteBalanceRB =   Xin.D.Sys.PointGreyCam(i).WhiteBalanceRB; 
        % Xin.HW.PointGrey.Cam(i).hSrc.WhiteBalanceRBMode = ...
        %                                                 Xin.D.Sys.PointGreyCam(i).WhiteBalanceRBMode;

        %% Setting up Resolution Related Parameters      
        Xin.D.Sys.PointGreyCam(i).RawVideoResolution =	pVid.VideoResolution.DefaultValue;
        Xin.D.Sys.PointGreyCam(i).RawWidth =            Xin.D.Sys.PointGreyCam(i).RawVideoResolution(1); 
        Xin.D.Sys.PointGreyCam(i).RawHeight =           Xin.D.Sys.PointGreyCam(i).RawVideoResolution(2);
        Xin.D.Sys.PointGreyCam(i).ZoomWidth =           Xin.D.Sys.PointGreyCam(i).RawWidth/...
                                                            Xin.D.Sys.PointGreyCam(i).PreviewZoom;
        Xin.D.Sys.PointGreyCam(i).ZoomHeight =          Xin.D.Sys.PointGreyCam(i).RawHeight/...
                                                            Xin.D.Sys.PointGreyCam(i).PreviewZoom;
        %% Display rotaion reltaed parameters
        switch Xin.D.Sys.PointGreyCam(i).PreviewRot
            case 0;     Xin.D.Sys.PointGreyCam(i).DispWidth =	Xin.D.Sys.PointGreyCam(i).ZoomWidth;
                        Xin.D.Sys.PointGreyCam(i).DispHeight =	Xin.D.Sys.PointGreyCam(i).ZoomHeight;
            case 90;	Xin.D.Sys.PointGreyCam(i).DispWidth =	Xin.D.Sys.PointGreyCam(i).ZoomHeight;
                        Xin.D.Sys.PointGreyCam(i).DispHeight =	Xin.D.Sys.PointGreyCam(i).ZoomWidth;
            case 180;	Xin.D.Sys.PointGreyCam(i).DispWidth =	Xin.D.Sys.PointGreyCam(i).ZoomWidth;
                        Xin.D.Sys.PointGreyCam(i).DispHeight =	Xin.D.Sys.PointGreyCam(i).ZoomHeight;
            case 270;	Xin.D.Sys.PointGreyCam(i).DispWidth =	Xin.D.Sys.PointGreyCam(i).ZoomHeight;
                        Xin.D.Sys.PointGreyCam(i).DispHeight =	Xin.D.Sys.PointGreyCam(i).ZoomWidth;
            otherwise;  errordlg('Disp Rotation Angle Not Support');
        end
        
        %% Camera preview inputs       
        Xin.D.Sys.PointGreyCam(i).PreviewClipROI =      0;   
        Xin.D.Sys.PointGreyCam(i).PreviewRef =          0;         
            % Xin.D.Sys.PointGreyCam(i).ROIPosition     
        Xin.D.Sys.PointGreyCam(i).PreviewImageIn = ...
                                                        uint8(256*rand(...
                                                        Xin.D.Sys.PointGreyCam(i).RawHeight,...
                                                        Xin.D.Sys.PointGreyCam(i).RawWidth, 1));   
        Xin.D.Sys.PointGreyCam(i).PreviewStrFR =        [num2str(Xin.D.Sys.PointGreyCam(i).FrameRate) '.00 FPS'];
        Xin.D.Sys.PointGreyCam(i).PreviewStrTS =        '00:00:00.0';
        Xin.D.Sys.PointGreyCam(i).DispPeriod =          0.1;
        Xin.D.Sys.PointGreyCam(i).DispTimer =           second(now); 
       
        %% process display image: .Zoom, Gain, Rotate, ROI        
        % ZOOM in
        Xin.D.Sys.PointGreyCam(i).DispImgB1 =           uint16( Xin.D.Sys.PointGreyCam(i).PreviewImageIn); 
        if Xin.D.Sys.PointGreyCam(i).PreviewZoom == 1
            Xin.D.Sys.PointGreyCam(i).DispImgB2 =       [];
            Xin.D.Sys.PointGreyCam(i).DispImgB3 =       [];
            Xin.D.Sys.PointGreyCam(i).DispImgB4 =       [];
            Xin.D.Sys.PointGreyCam(i).DispImgBO =       Xin.D.Sys.PointGreyCam(i).DispImgB1;
        else 	
            Xin.D.Sys.PointGreyCam(i).DispImgB2 =       reshape(Xin.D.Sys.PointGreyCam(i).DispImgB1,...
                                                            Xin.D.Sys.PointGreyCam(i).PreviewZoom,...
                                                            Xin.D.Sys.PointGreyCam(i).ZoomHeight,...
                                                            Xin.D.Sys.PointGreyCam(i).PreviewZoom,...
                                                            Xin.D.Sys.PointGreyCam(i).ZoomWidth); 
            Xin.D.Sys.PointGreyCam(i).DispImgB3 =       sum(Xin.D.Sys.PointGreyCam(i).DispImgB2, 1, 'native');  
            Xin.D.Sys.PointGreyCam(i).DispImgB4 =       sum(Xin.D.Sys.PointGreyCam(i).DispImgB3, 3, 'native');
            Xin.D.Sys.PointGreyCam(i).DispImgBO =       squeeze(Xin.D.Sys.PointGreyCam(i).DispImgB4);
        end
        % GAIN & NORMALIZATION
            Xin.D.Sys.PointGreyCam(i).DispImgGO =       uint8(...
                                                            Xin.D.Sys.PointGreyCam(i).DispImgBO/...
                                                            Xin.D.Sys.PointGreyCam(i).PreviewZoom^2*...
                                                            Xin.D.Sys.PointGreyCam(i).DispGainNum);        
        % ROTATE
        try
            Xin.D.Sys.PointGreyCam(i).DispImgRO =       rot90(Xin.D.Sys.PointGreyCam(i).DispImgGO, ...
                                                            (360-Xin.D.Sys.PointGreyCam(i).PreviewRot)/90);
        catch
            Xin.D.Sys.PointGreyCam(i).DispImgRO =       Xin.D.Sys.PointGreyCam(i).DispImgGO;
            disp('Preview Rotation Angle Not Support');
        end        
        % ROI 
        if  Xin.D.Sys.PointGreyCam(i).PreviewClipROI
            Xin.D.Sys.PointGreyCam(i).DispImgOO =       Xin.D.Sys.PointGreyCam(i).DispImgRO.*...
                                                        Xin.D.Sys.PointGreyCam(i).ROIi;
        else
            Xin.D.Sys.PointGreyCam(i).DispImgOO =       Xin.D.Sys.PointGreyCam(i).DispImgRO;
        end       
        Xin.D.Sys.PointGreyCam(i).DispImg =             Xin.D.Sys.PointGreyCam(i).DispImgOO;
        Xin.D.Sys.PointGreyCam(i).DispImg3 =            reshape(...
                                                            repmat(Xin.D.Sys.PointGreyCam(i).DispImg, 1, 3),...
                                                            size(Xin.D.Sys.PointGreyCam(i).DispImg,1),...
                                                            size(Xin.D.Sys.PointGreyCam(i).DispImg,2),...
                                                            3);

        % HISTOGRAM
        if Xin.D.Sys.PointGreyCam(i).UpdatePreviewHistogram
            Xin.D.Sys.PointGreyCam(i).DispHistMax =     max(Xin.D.Sys.PointGreyCam(i).DispImg, [], 2);
            Xin.D.Sys.PointGreyCam(i).DispHistMean =	uint8(mean(Xin.D.Sys.PointGreyCam(i).DispImg,2)); 
            Xin.D.Sys.PointGreyCam(i).DispHistMin =     min(Xin.D.Sys.PointGreyCam(i).DispImg, [], 2);
        end

    else
        errordlg(['PointGrey cameras #', num2str(i),' "', Xin.D.Sys.PointGreyCam(i).Comments, '" cannot be located']);        
    end
end

%% LOG MSG
msg = [datestr(now, 'yy/mm/dd HH:MM:SS.FFF') '\tSetupPointGreyCamera\tSetup PointGrey Cameras\r\n'];  
updateMsg(Xin.D.Exp.hLog, msg);