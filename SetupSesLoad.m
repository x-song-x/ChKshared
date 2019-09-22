function SetupSesLoad(MainVarStr, LoadSourceStr)
% This function load recording session related stuff, and return updated
% information both in the LO (LoadOut) and GUI objects in the MainVarStr 
% ('Xin' or 'TP')
%       MainVarStr:     'Xin' or 'TP'
%       LoadSourceStr:  'Sound', 'AddAtts', 'CycleNumTotal', 'TrlOrder'

%   Sound, Additional Attenuations,  and generate according
% Trl play structures

global TP Xin
persistent L

%% L: Load In
str = ['L.Ses = ', MainVarStr, '.D.Ses.Load;'];	eval(str);
str = ['L.Trl = ', MainVarStr, '.D.Trl.Load;'];	eval(str);

%% LoadSource Selection
        SesTrlOrder =       '';
                            LS = 0;
switch LoadSourceStr
    case 'Sound',           LS = 4;
    case 'AddAtts',         LS = 3;
    case 'CycleNumTotal',   LS = 2;
    case 'TrlOrder',        LS = 1;
    otherwise
        errordlg('SetupSesLoad input error');
end
%% Load Sound
if LS>=4
    % Load the Sound File & Update Parameters
	filestr =                   [L.Ses.SoundDir, L.Ses.SoundFile];
    SoundRaw =                  audioread(filestr, 'native');
    if length(SoundRaw) == 1    % Virtual Sounds for Initializing Scan Scheme in FANTASIA
        SoundRaw =              int16(zeros(0,0));
    end
    SoundInfo =                 audioinfo(filestr);   
                if SoundInfo.SampleRate ~= 100000
                    errordlg('Sound sampling rate is not 100kHz');
                    return;
                end
                                        L.Ses.SoundTitle =      SoundInfo.Title;
                                        L.Ses.SoundArtist =     SoundInfo.Artist;
                                        L.Ses.SoundComment =	SoundInfo.Comment;
                                        L.Ses.SoundFigureTitle= [': sound "' L.Ses.SoundFile '" loaded'];
                                        L.Ses.SoundWave =       SoundRaw;         
                                        L.Ses.SoundDurTotal =	length(SoundRaw)/L.Ses.SoundSR; 
    part = {}; i = 1;
    remain =                            L.Ses.SoundComment;
    while ~isempty(remain)
        [part{i}, remain] = strtok(remain, ';');
        [argu, value]=      strtok(part{i}, ':');
        argu =              argu(2:end);
        value =             value(3:end);
        switch argu    
            % Standard cases for all sounds
            case 'TrialNames';          value =                 textscan(value, '%s', 'Delimiter', ' ');
                                        L.Trl.Names =           value{1};
            case 'TrialAttenuations';   value =                 textscan(value, '%f');
                                        L.Trl.Attenuations =    value{1};
            case 'TrialNumberTotal';	L.Trl.SoundNumTotal =	str2double(value);
            case 'TrialDurTotal(sec)';	L.Trl.DurTotal =        str2double(value);
                                        L.Trl.DurCurrent =      NaN;  
            case 'TrialDurPreStim(sec)';L.Trl.DurPreStim =      str2double(value);
            case 'TrialDurStim(sec)';   L.Trl.DurStim =         str2double(value);
            % SPecial cases for Pre-arranged sounds
            case 'SesTrlOrder';         SesTrlOrder =           deblank(value);
                if ~strcmp(SesTrlorder, 'Pre-arranged')
                    errordlg('unrecognizable SesTrlOrder');
                    return
                end
            case 'SesCycleNumTotal';	SesCycleNumTotal =      round(str2double(value)); 
            case 'SesTrlOrderMat';      value =                 textscan(value, '%d');  
                                        SesTrlOrderMat =        value{1};    
                                        SesTrlOrderMat=         reshape(SesTrlOrderMat,...
                                                                    L.Trl.SoundNumTotal,...
                                                                    SesCycleNumTotal)';
            otherwise;                  disp(argu);
        end
        i = i+1;
    end
                                        L.Trl.DurPostStim =     L.Trl.DurTotal - ...
                                                                L.Trl.DurPreStim - ...
                                                                L.Trl.DurStim;
    if isempty(L.Ses.SoundWave)         % Virtual Sounds for Initializing Scan Scheme in FANTASIA
            L.Ses.SoundMat =	L.Ses.SoundWave;
    elseif strcmp(SesTrlOrder, 'Pre-arranged')
                try 
                    L.Ses.SoundMat =    reshape(L.Ses.SoundWave,...
                                            L.Trl.DurTotal* SoundInfo.SampleRate,...
                                            L.Trl.SoundNumTotal,...
                                            SesCycleNumTotal);
                catch
                    errordlg('Pre-arranged session is not at right length');
                    return
                end
        % Turn off necessary GUI options
        set(findobj('tag', 'hSes_CycleNumTotal_Edit'),	'Enable',   'off');
        hSesTrlOrder = findobj('tag', 'hSes_TrlOrder_Rocker');
        hSesTrlOrderButtons = get(hSesTrlOrder,         'Children');
        set(hSesTrlOrderButtons(2),                     'Enable',   'inactive');
        set(hSesTrlOrderButtons(3),                     'Enable',   'inactive');
            % button selection is delayed to LS>1 part
    else
                try 
                    L.Ses.SoundMat =	reshape(L.Ses.SoundWave,...
                                            L.Trl.DurTotal* SoundInfo.SampleRate,...
                                            L.Trl.SoundNumTotal);
                catch
                    errordlg('Pre-arranged session is not at right length');
                    return
                end
        % Turn on necessary GUI options
        set(findobj('tag', 'hSes_CycleNumTotal_Edit'),	'Enable',   'on');
        hSesTrlOrder = findobj('tag', 'hSes_TrlOrder_Rocker');
        hSesTrlOrderButtons = get(hSesTrlOrder,         'Children');
        set(hSesTrlOrderButtons(2),                     'Enable',   'on');
        set(hSesTrlOrderButtons(3),                     'Enable',   'on');
    end        
	if round(   length(SoundRaw)/L.Ses.SoundSR/0.2 ) ~=...
                length(SoundRaw)/L.Ses.SoundSR/0.2
        warndlg('The sound length is NOT in integer multiples of 0.2 second');
	end    
	set(findobj('tag', 'hSes_SoundDurTotal_Edit'),      'String',   sprintf('%5.1f (s)', L.Ses.SoundDurTotal));
	set(findobj('tag', 'hTrl_SoundNumTotal_Edit'),      'String',   num2str(L.Trl.SoundNumTotal));
    set(findobj('tag', 'hTrl_DurTotal_Edit'),           'String',   sprintf('%5.1f (s)', L.Trl.DurTotal));
    set(findobj('tag', 'hTrl_DurCurrent_Edit'),         'String',   sprintf('%5.1f (s)', L.Trl.DurCurrent));   
end
%% Load AddAtts
if LS>=3
    if strcmp(SesTrlOrder, 'Pre-arranged')
        L.Ses.AddAtts =             L.Ses.AddAtts(1);
        L.Ses.AddAttString =        num2string(L.Ses.AddAtts);
        L.Ses.AddAttNumTotal =      1;    
        L.Trl.NumTotal =            L.Trl.SoundNumTotal*1;     
        L.Ses.CycleDurTotal =       L.Trl.DurTotal * L.Trl.NumTotal;   
    else
        L.Ses.AddAtts =             L.Ses.AddAtts;
        L.Ses.AddAttString =        L.Ses.AddAttString;
        L.Ses.AddAttNumTotal =      length(L.Ses.AddAtts);    
        L.Trl.NumTotal =            L.Trl.SoundNumTotal * L.Ses.AddAttNumTotal;        
        L.Ses.CycleDurTotal =       L.Ses.SoundDurTotal * L.Ses.AddAttNumTotal;  
    end  
        L.Ses.CycleDurCurrent =     NaN;
        L.Trl.NumCurrent =          NaN;            
        L.Trl.AttNumCurrent =       NaN;
        L.Trl.AttDesignCurrent =    NaN;
        L.Trl.AttAddCurrent =       NaN;
        L.Trl.AttCurrent =          NaN;
        L.Ses.TrlIndexSoundNum =    repmat(1:L.Trl.SoundNumTotal, 1, L.Ses.AddAttNumTotal);
    if isnan(L.Trl.SoundNumTotal)
        L.Ses.TrlIndexAddAttNum =	NaN;
    else
        L.Ses.TrlIndexAddAttNum =   repelem(1:L.Ses.AddAttNumTotal, L.Trl.SoundNumTotal);
    end
    set(findobj('tag', 'hSes_AddAtts_Edit'),        'String',   L.Ses.AddAttString);
    set(findobj('tag', 'hSes_AddAttNumTotal_Edit'),	'String',   num2str(L.Ses.AddAttNumTotal));
    set(findobj('tag', 'hSes_CycleDurTotal_Edit'), 	'String',	sprintf('%5.1f (s)', L.Ses.CycleDurTotal));
    set(findobj('tag', 'hSes_CycleDurCurrent_Edit'),'String',   sprintf('%5.1f (s)', L.Ses.CycleDurCurrent));
    set(findobj('tag', 'hTrl_NumTotal_Edit'),       'String',   num2str(L.Trl.NumTotal));
    set(findobj('tag', 'hTrl_NumCurrent_Edit'),     'String',   num2str(L.Trl.NumCurrent));
    set(findobj('tag', 'hTrl_AttDesignCurrent_Edit'),'String',	sprintf('%5.1f (dB)',L.Trl.AttDesignCurrent));
    set(findobj('tag', 'hTrl_AttAddCurrent_Edit'),	'String',	sprintf('%5.1f (dB)',L.Trl.AttAddCurrent));
    set(findobj('tag', 'hTrl_AttCurrent_Edit'),     'String',	sprintf('%5.1f (dB)',L.Trl.AttCurrent));
end
%% Load CycleNumTotal
if LS>=2
    if strcmp(SesTrlOrder, 'Pre-arranged')
        L.Ses.CycNumTotal = SesCycleNumTotal;
    else
        L.Ses.CycNumTotal = L.Ses.CycNumTotal;
    end
    L.Ses.CycleNumCurrent =	NaN; 
    L.Ses.DurTotal =        L.Ses.CycleDurTotal * L.Ses.CycleNumTotal;        
    L.Ses.DurCurrent =      NaN;  
    set(findobj('tag', 'hSes_CycleNumTotal_Edit'),	'String',   num2str(L.Ses.CycleNumTotal));
    set(findobj('tag', 'hSes_CycleNumCurrent_Edit'),'String',   num2str(L.Ses.CycleNumCurrent));
    set(findobj('tag', 'hSes_DurTotal_Edit'),       'String',   sprintf('%5.1f (s)', L.Ses.DurTotal));
    set(findobj('tag', 'hSes_DurCurrent_Edit'),     'String',   sprintf('%5.1f (s)', L.Ses.DurCurrent)); 
end
%% Load TrlOrder
if LS>=1
    if strcmp(SesTrlOrder,	'Pre-arranged')
        L.Ses.TrlOrder =	'Pre-arranged';
                        L.Ses.TrlOrderMat =	SesTrlOrderMat;
        % This would be bypassed in a second call to set the GUI only
    end
    switch L.Ses.TrlOrder
        case 'Sequential'
            try
                        L.Ses.TrlOrderMat =	repmat(1:L.Trl.NumTotal, L.Ses.CycleNumTotal, 1);
            catch
                        L.Ses.TrlOrderMat =	NaN;
            end
        case 'Randomized'
            try
                L.Ses.TrlOrderMat =     [];
                if ~isinf(L.Ses.CycleNumTotal)
                    for i = 1:L.Ses.CycleNumTotal
                        L.Ses.TrlOrderMat = [L.Ses.TrlOrderMat; randperm(L.Trl.NumTotal)];
                    end    
                else
                        L.Ses.TrlOrderMat = NaN;
                end
            catch
                        L.Ses.TrlOrderMat =	NaN;
            end     
        case 'Pre-arranged'
                        L.Ses.TrlOrderMat =	L.Ses.TrlOrderMat;
        otherwise
            errordlg('wrong trial order option');
    end
        L.Ses.TrlOrderVec =         reshape(L.Ses.TrlOrderMat',1,[]); % AddAtt Order
    try
        L.Ses.TrlOrderSoundVec =	L.Ses.TrlIndexSoundNum(L.Ses.TrlOrderVec);
    catch
        L.Ses.TrlOrderSoundVec =    NaN;
    end        
    L.Trl.StimNumCurrent =      NaN;
    L.Trl.StimNumNext =         NaN;
    L.Trl.SoundNumCurrent =    	NaN;
    L.Trl.SoundNameCurrent =    '';
    set(findobj('tag', 'hTrl_StimNumCurrent_Edit'),     'String',	num2str(L.Trl.StimNumCurrent));
    set(findobj('tag', 'hTrl_StimNumNext_Edit'),        'String',	num2str(L.Trl.StimNumNext));
    set(findobj('tag', 'hTrl_SoundNumCurrent_Edit'),	'String',   num2str(L.Trl.SoundNumCurrent));
    set(findobj('tag', 'hTrl_SoundNameCurrent_Edit'),   'String',	num2str(L.Trl.SoundNameCurrent));    
end
%% L: Load Out
str = [MainVarStr, '.D.Ses.Load = L.Ses;'];	eval(str);
str = [MainVarStr, '.D.Trl.Load = L.Trl;']; eval(str);
%% XINTRINSIC or FANTASIA Specific Updates, after write back Load
switch MainVarStr
    case 'Xin'
        % PointGrey Camera related
        Xin.D.Ses.UpdateNumTotal =      Xin.D.Ses.Load.DurTotal * Xin.D.Sys.NIDAQ.Task_AI_Xin.time.updateRate;
        Xin.D.Ses.UpdateNumCurrent =    NaN;      
        Xin.D.Ses.UpdateNumCurrentAI =  NaN;    
        Xin.D.Ses.FrameTotal =      Xin.D.Ses.Load.DurTotal * Xin.D.Sys.PointGreyCam(2).FrameRate; 
        Xin.D.Ses.FrameRequested =	NaN;    
        Xin.D.Ses.FrameAcquired =   NaN;    
        Xin.D.Ses.FrameAvailable =  NaN;   
        set(Xin.UI.H.hSes_FrameTotal_Edit,      'String', 	num2str(Xin.D.Ses.FrameTotal));
        set(Xin.UI.H.hSes_FrameAcquired_Edit,   'String',   num2str(Xin.D.Ses.FrameAcquired) );
        set(Xin.UI.H.hSes_FrameAvailable_Edit,  'String',   num2str(Xin.D.Ses.FrameAvailable) ); 
    case 'TP'
        
    otherwise
end
