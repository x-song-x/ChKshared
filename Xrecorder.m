function varargout = Xrecorder(varargin)

%% For Standarized SubFunction Callback Control
if nargin==0                % INITIATION
    InitializeTASKS
elseif ischar(varargin{1})  % INVOKE NAMED SUBFUNCTION OR CALLBACK
    try
        if (nargout)                        
            [varargout{1:nargout}] = feval(varargin{:});
                            % FEVAL switchyard, w/ output
        else
            feval(varargin{:}); 
                            % FEVAL switchyard, w/o output  
        end
    catch MException
        rethrow(MException);
    end
end

function InitializeTASKS
clear all
global rec

%% Parameter Setup
rec.FileNameHead =          'rec';
rec.FileDir =               'C:\EXPERIMENTS\Ambience\';
rec.RecTime =               1;

rec.MicSys =                '4189+2250';
rec.MicSysNum =             3;
rec.MicSys_Name =           '4189+2250';
rec.MicSys_MIC_Name =       '4189';
rec.MicSys_MIC_mVperPa =	51.3;	 % mV/Pa
rec.MicSys_Amp_Name =       '2250+ZC0032';
rec.MicSys_Amp_GaindB =     60;
rec.MicSys_Amp_GainNum =    1000;
rec.MicSys_Amp_DR =         5;

    rec.MicSys_AmpRon.Gain40 = 		4200/40;
    rec.MicSys_AmpRon.Gain30 = 		1320/40;
    rec.MicSys_AmpRon.Gain20 = 		410/40;
    rec.MicSys_AmpRon.Gain10 = 		130/40;
    rec.MicSys_AmpRon.CufFreq =     36e3;

    rec.MicSysOptions(1).Name =  		'4191+AM1800';
    rec.MicSysOptions(1).MIC_Name =     '4191';
    rec.MicSysOptions(1).MIC_mVperPa = 	13.2;
    rec.MicSysOptions(1).Amp_Name =  	'AM1800';
    rec.MicSysOptions(1).Amp_GaindB =   80;
    rec.MicSysOptions(1).Amp_MaxDR =    10;

    rec.MicSysOptions(2).Name =  		'4191+Ron''s';
    rec.MicSysOptions(2).MIC_Name =     '4191';
    rec.MicSysOptions(2).MIC_mVperPa = 	13.2;
    rec.MicSysOptions(2).Amp_Name =  	'Ron''s';
    rec.MicSysOptions(2).Amp_GaindB =  	40;
    rec.MicSysOptions(2).Amp_MaxDR =       10;

    rec.MicSysOptions(3).Name =  		'4189+2250';
    rec.MicSysOptions(3).MIC_Name =     '4189';
    rec.MicSysOptions(3).MIC_mVperPa = 	51.3;
    rec.MicSysOptions(3).Amp_Name =  	'2250+ZC0032';
    rec.MicSysOptions(3).Amp_GaindB =  	60;
    rec.MicSysOptions(3).Amp_MaxDR =    5;

rec.NIDAQ_Card =            'NI PCIe-6323'; % 'NI USB-6251'
rec.NIDAQ_OptionNum =       1;
rec.NIDAQ_SR =              100e3;
rec.NIDAQ_UR =              10;

rec.NIDAQ_Options(1).Dev.devName =      'Dev3';
rec.NIDAQ_Options(1).CO.chanIDs = 		0;
rec.NIDAQ_Options(1).AI.chanIDs =		2;
% rec.NIDAQ_Options(1).AI.chanIDs =		16;

rec.NIDAQ_Options(2).Dev.devName =      'Dev4';
rec.NIDAQ_Options(2).CO.chanIDs = 		0;
rec.NIDAQ_Options(2).AI.chanIDs =		0;

%% GUI Setup

S.Color.BG =        [   0       0       0];
S.Color.HL =        [   0       0       0];
S.Color.FG =        [   0.6     0.6     0.6];    
S.Color.TextBG =    [   0.25    0.25    0.25];
S.Color.SelectB =  	[   0       0       0.35];
S.Color.SelectT =  	[   0       0       0.35];

rec.UI.C = S.Color;

% Screen Size
S.MonitorPositions = get(0,'MonitorPositions');

% Global Spacer Scale
S.SP = 10;          % Panelette Side Spacer
S.S = 2;            % Small Spacer 

% Panelette Scale
S.PaneletteWidth = 100;         S.PaneletteHeight = 150;    
S.PaneletteTitle = 18;
S.PaneletteRowNum = 1;  S.PaneletteColumnNum = 8;

% Control Panel Scale 
S.PanelCtrlWidth =  S.PaneletteColumnNum *(S.PaneletteWidth+S.S) + 2*(2*S.S);
S.PanelCtrlHeight = S.PaneletteRowNum *(S.PaneletteHeight+S.S) + S.PaneletteTitle;

% Figure Scale
S.FigWidth = S.PanelCtrlWidth + 2*S.SP;
S.FigHeight = S.PanelCtrlHeight + 2*S.SP;
S.FigCurrentW = S.MonitorPositions(1,3)/2 - S.FigWidth/2;
S.FigCurrentH = S.MonitorPositions(1,4)/2 - S.FigHeight/2;
rec.UI.S = S;

% create GUI Figure
rec.UI.H0.hFigGUI = figure(...
    'Name',         'Xrecorder',...
    'NumberTitle',  'off',...
    'Resize',       'off',...
	'color',        S.Color.BG,...
    'position',     [   S.FigCurrentW ,  S.FigCurrentH,...
                        S.FigWidth,     S.FigHeight],...
    'menubar',      'none',...
	'doublebuffer', 'off');

% create the Control Panel
S.PanelCurrentW = S.SP;
S.PanelCurrentH = S.SP;
rec.UI.H0.hPanelCtrl = uipanel(...
  	'parent',           rec.UI.H0.hFigGUI,...
    'BackgroundColor',  S.Color.BG,...
    'Highlightcolor',   S.Color.HL,...
    'ForegroundColor',  S.Color.FG,...
   	'units',            'pixels',...
  	'Title',            'CONTROL PANEL',...
    'Position',         [   S.PanelCurrentW     S.PanelCurrentH ...
                            S.PanelCtrlWidth    S.PanelCtrlHeight]);

% create rows of Empty Panelettes                      
for i = 1:S.PaneletteRowNum
    for j = 1:S.PaneletteColumnNum
        rec.UI.H0.Panelette{i,j}.hPanelette = uipanel(...
        'parent',           rec.UI.H0.hPanelCtrl,...
        'BackgroundColor',  S.Color.BG,...
        'Highlightcolor',   S.Color.HL,...
        'ForegroundColor',  S.Color.FG,...
        'units',            'pixels',...
        'Title',            ' ',...
        'Position',         [2*S.S+(S.S+S.PaneletteWidth)*(j-1),...
                            2*S.S+(S.S+S.PaneletteHeight)*(i-1),...
                            S.PaneletteWidth, S.PaneletteHeight]);
                            % edge is 2*S.S
    end
end

% create Panelettes
S.PnltCurrent.row = 1;      S.PnltCurrent.column =    1;
    WP.name =   'Timer / File Name';
        WP.handleseed =     'rec.UI.H0.Panelette';
        WP.type =	'Edit';
        WP.row =        S.PnltCurrent.row;
        WP.column =     S.PnltCurrent.column;
            S.PnltCurrent.column = S.PnltCurrent.column + 1; 
        WP.text = { 'Recording Time (in Seconds)',...
                    'Waveform File Surname'};
        WP.tip = WP.text; 
        WP.inputValue = {   0,...
                            rec.FileNameHead};
        WP.inputFormat = {'%5.1f','%s'};
        WP.inputEnable = {'on','on'};
        Panelette(S, WP, 'rec');    
        rec.UI.H.hRecTime_Edit =        rec.UI.H0.Panelette{WP.row,WP.column}.hEdit{1};
        rec.UI.H.hFileNameHead_Edit =   rec.UI.H0.Panelette{WP.row,WP.column}.hEdit{2};
        set(rec.UI.H.hRecTime_Edit,         'tag',  'hRecTime_Edit');
        set(rec.UI.H.hFileNameHead_Edit,	'tag',  'hFileNameHead_Edit');
        clear WP;
    
    WP.name =	'Microphone';    
        WP.handleseed =     'rec.UI.H0.Panelette';
        WP.type = 	'RockerSwitch';
        WP.row =        S.PnltCurrent.row;
        WP.column =     S.PnltCurrent.column;
            S.PnltCurrent.column = S.PnltCurrent.column + 1; 
        WP.text = { 'B&K 4191-B-001 / B&K 2250+4189'};
        WP.tip = {  '4191''s sensitivity is 13.2mV/Pascal, \n4189''s final sensitivity is 51.3mV/Pascal'};  
        WP.inputOptions =   {'4191+AM1800','4191+Ron''s','4189+2250'};
        WP.inputDefault =   3;
        Panelette(S, WP, 'rec');  
        rec.UI.H.hMicSys_Rocker =       rec.UI.H0.Panelette{WP.row,WP.column}.hRocker{1};
        set(rec.UI.H.hMicSys_Rocker,        'tag',  'hMicSys_Rocker');
        clear WP; 
    
    WP.name =	'Amplification';
        WP.handleseed =     'rec.UI.H0.Panelette';
        WP.type =	'ToggleSwitch';   
        WP.row =        S.PnltCurrent.row;
        WP.column =     S.PnltCurrent.column;
            S.PnltCurrent.column = S.PnltCurrent.column + 1; 
        WP.text = { 'Amplifier','in dB'};
        WP.tip = {  'Amplifier''s Amplification, in dB',...
                	'Amplifier''s Amplification, in dB'};
        WP.inputOptions = {'80 dB','60 dB','50 dB';'40 dB','30 dB','20 dB'};
        WP.inputDefault = [3, 0];
        Panelette(S, WP, 'rec'); 
        rec.UI.H.hAmp_Toggle1 = rec.UI.H0.Panelette{WP.row,WP.column}.hToggle{1};
        rec.UI.H.hAmp_Toggle2 = rec.UI.H0.Panelette{WP.row,WP.column}.hToggle{2};
        set(rec.UI.H.hAmp_Toggle1,          'tag',  'hAmp_Toggle1');
        set(rec.UI.H.hAmp_Toggle2,          'tag',  'hAmp_Toggle2');
        clear WP;
    
	WP.name = 'NIDAQ Card';
        WP.handleseed =     'rec.UI.H0.Panelette';
        WP.type =	'RockerSwitch';
        WP.row =        S.PnltCurrent.row;
        WP.column =     S.PnltCurrent.column;
            S.PnltCurrent.column = S.PnltCurrent.column + 1; 
        WP.text = { 'NI PCIe-6323 / NI USB-6251'};
        WP.tip = {	'Select the right NI-DAQ card'};
        WP.inputOptions =   {'NI PCIe-6323','NI USB-6251',''};
        WP.inputDefault =   1;
        Panelette(S, WP, 'rec');  
        rec.UI.H.hNIDAQ_Rocker = rec.UI.H0.Panelette{WP.row,WP.column}.hRocker{1};
        set(rec.UI.H.hNIDAQ_Rocker,         'tag',  'hNIDAQ_Rocker');
        clear WP; 
    
    WP.name =	'NIDAQ Dyn Range';
        WP.handleseed =     'rec.UI.H0.Panelette';
        WP.type =	'ToggleSwitch';   
        WP.row =        S.PnltCurrent.row;
        WP.column =     S.PnltCurrent.column;
            S.PnltCurrent.column = S.PnltCurrent.column + 1; 
        WP.text = { 'NI-DAQ AI','dynamic range'};
        WP.tip = {  'NI-DAQ AI''s dynamic range',...
                    'NI-DAQ AI''s dynamic range'};
        WP.inputOptions = {'10V','5V','2V';'1V','0.5V','0.2V'};
        WP.inputDefault = [2, 0];
        Panelette(S, WP, 'rec'); 
        rec.UI.H.hDR_Toggle1 = rec.UI.H0.Panelette{WP.row,WP.column}.hToggle{1};
        rec.UI.H.hDR_Toggle2 = rec.UI.H0.Panelette{WP.row,WP.column}.hToggle{2};
        set(rec.UI.H.hDR_Toggle1,           'tag',  'hDR_Toggle1');
        set(rec.UI.H.hDR_Toggle2,           'tag',  'hDR_Toggle2');
        clear WP;
    
    WP.name = 'Start / Stop';
        WP.handleseed =     'rec.UI.H0.Panelette';
        WP.type =	'RockerSwitch';
        WP.row =        S.PnltCurrent.row;
        WP.column =     S.PnltCurrent.column;
            S.PnltCurrent.column = S.PnltCurrent.column + 1; 
        WP.text = { 'Start /Stop Recording'};
        WP.tip = {  'Start /Stop Recording'};
        WP.inputOptions =   {'Start','Stop',''};
        WP.inputDefault =   2;
        Panelette(S, WP, 'rec'); 
        rec.UI.H.hStartStop_Rocker = rec.UI.H0.Panelette{WP.row,WP.column}.hRocker{1};
        set(rec.UI.H.hStartStop_Rocker,     'tag',  'hStartStop_Rocker');
        clear WP; 
    
    WP.name = 'Plot / Save';
        WP.handleseed =     'rec.UI.H0.Panelette';
        WP.type =	'MomentarySwitch';
        WP.row =        S.PnltCurrent.row;
        WP.column =     S.PnltCurrent.column;
            S.PnltCurrent.column = S.PnltCurrent.column + 1;
        WP.text = { 'Plot','Save'}; 	
        WP.tip = {  '',''};
        WP.inputEnable = {'on','on'};
        Panelette(S, WP, 'rec');  
        rec.UI.H.hPlot_Momentary = rec.UI.H0.Panelette{WP.row,WP.column}.hMomentary{1};
        rec.UI.H.hSave_Momentary = rec.UI.H0.Panelette{WP.row,WP.column}.hMomentary{2};
        set(rec.UI.H.hPlot_Momentary,       'tag',  'hPlot_Momentary');
        set(rec.UI.H.hSave_Momentary,       'tag',  'hSave_Momentary');
        clear WP;
        
    WP.name = 'Load';
        WP.handleseed =     'rec.UI.H0.Panelette';
        WP.type =	'MomentarySwitch';
        WP.row =        S.PnltCurrent.row;
        WP.column =     S.PnltCurrent.column;
            S.PnltCurrent.column = S.PnltCurrent.column + 1; 
        WP.text = { 'Load',''};	
        WP.tip = {  '',''};
        WP.inputEnable = {'on','off'};
        Panelette(S, WP, 'rec'); 
        rec.UI.H.hLoad_Momentary = rec.UI.H0.Panelette{WP.row,WP.column}.hMomentary{1};
        set(rec.UI.H.hLoad_Momentary,       'tag',  'hLoad_Momentary');
        clear WP;
    
%% Setup Callbacks
set(rec.UI.H.hRecTime_Edit,         'Callback',             'Xrecorder(''GUI_Edit'')');
set(rec.UI.H.hFileNameHead_Edit,	'Callback',             'Xrecorder(''GUI_Edit'')');
set(rec.UI.H.hMicSys_Rocker,        'SelectionChangeFcn',   'Xrecorder(''GUI_Rocker'')');
set(rec.UI.H.hAmp_Toggle1,          'SelectionChangeFcn',	'Xrecorder(''GUI_Toggle'')');
set(rec.UI.H.hAmp_Toggle2,          'SelectionChangeFcn',  	'Xrecorder(''GUI_Toggle'')');
set(rec.UI.H.hNIDAQ_Rocker,         'SelectionChangeFcn',   'Xrecorder(''GUI_Rocker'')');
set(rec.UI.H.hDR_Toggle1,           'SelectionChangeFcn',  	'Xrecorder(''GUI_Toggle'')');
set(rec.UI.H.hDR_Toggle2,           'SelectionChangeFcn',  	'Xrecorder(''GUI_Toggle'')');
set(rec.UI.H.hStartStop_Rocker,     'SelectionChangeFcn',   'Xrecorder(''GUI_Rocker'')');
set(rec.UI.H.hSave_Momentary,       'Callback',             'Xrecorder(''RecordSave'')');
set(rec.UI.H.hPlot_Momentary,       'Callback',             'Xrecorder(''RecordPlot'')');
set(rec.UI.H.hLoad_Momentary,       'Callback',             'Xrecorder(''RecordLoad'')');
% set(rec.H.hLoad_Momentary,      'Callback',             'Xrecorder(''RecordLoad'')');
Xrecorder('GUI_Rocker', 'hNIDAQ_Rocker',    rec.NIDAQ_Card);
Xrecorder('GUI_Rocker', 'hMicSys_Rocker',   rec.MicSys);

function GUI_Edit(varargin)
    global rec 	
    %% Where the Call is from   
    if nargin == 0      % from GUI 
        tag =   get(gcbo,   'tag');
        s =     get(gcbo,   'string');
           
    else                % from Program
        tag =   varargin{1};
        s =     varargin{2};
    end
    %% Update D and GUI
    switch tag
        case 'hRecTime_Edit'
            t = str2double(s);
            t = round(t*10)/10;
            if t>0 && t<60
                rec.sys.RecTime = t;
                set(rec.UI.H.hRecTime_Edit,     'string', sprintf('%5.1f',rec.sys.RecTime));
            else
                t = rec.sys.RecTime;
                set(rec.UI.H.hRecTime_Edit,     'string', sprintf('%5.1f',t));
                errordlg('Recording time is not within 0-60 seconds');
            end
        case 'hFileNameHead_Edit'
            try 
                rec.FileNameHead = s;
                set(rec.UI.H.hFileNameHead_Edit,'string', sprintf('%s',rec.FileNameHead));
            catch
                errordlg('Cycle Number Total input is not valid');
            end       
        otherwise
    end
	%% MSG LOG
    msg = [datestr(now, 'yy/mm/dd HH:MM:SS.FFF') '\tGUI_Edit\t' tag ' updated to ' s '\r\n'];
    disp(msg);

function GUI_Rocker(varargin)
    global rec;
  	%% where the call is from      
    if nargin==0
        % called by GUI:            GUI_Rocker
        label =     get(gcbo,'Tag'); 
        val =       get(get(gcbo,'SelectedObject'),'string');
    else
        % called by general update: GUI_Rocker('hSys_LightPort_Rocker', 'Koehler')
        label =     varargin{1};
        val =       varargin{2};
    end   
    %% Update GUI
    eval(['h = rec.UI.H.', label ';'])
    hc = get(h,     'Children');
    for j = 1:3
        if strcmp( get(hc(j), 'string'), val )
            set(hc(j),	'backgroundcolor', rec.UI.C.SelectB);
            set(h,      'SelectedObject',  hc(j));
            k = j;  % for later reference
        else                
            set(hc(j),	'backgroundcolor', rec.UI.C.TextBG);
        end
    end
    %% Update D & Log
    switch label
        case 'hMicSys_Rocker'
            rec.MicSys =    val;    
            rec.MicSysNum = 4-k;            
            rec.MicSys_Name =           rec.MicSysOptions(rec.MicSysNum).Name;
            rec.MicSys_MIC_Name =       rec.MicSysOptions(rec.MicSysNum).MIC_Name;
            rec.MicSys_MIC_mVperPa =    rec.MicSysOptions(rec.MicSysNum).MIC_mVperPa;
            rec.MicSys_Amp_Name =       rec.MicSysOptions(rec.MicSysNum).Amp_Name;            
            rec.MicSys_Amp_GaindB =     rec.MicSysOptions(rec.MicSysNum).Amp_GaindB;
                GUI_Toggle('hAmp_Toggle1',	[num2str(rec.MicSys_Amp_GaindB) ' dB']);
            rec.MicSys_Amp_DR =         rec.MicSysOptions(rec.MicSysNum).Amp_MaxDR;
                GUI_Toggle('hDR_Toggle1',	[num2str(rec.MicSys_Amp_DR) 'V']);
           switch rec.MicSys
               case '4191+AM1800'
                    ht =  get(rec.UI.H.hAmp_Toggle1, 'Children');	set(ht(3), 'Enable', 'on');
                                                                    set(ht(2), 'Enable', 'on');
                                                                    set(ht(1), 'Enable', 'inactive');
                    ht =  get(rec.UI.H.hAmp_Toggle2, 'Children');   set(ht(3), 'Enable', 'on');
                                                                    set(ht(2), 'Enable', 'inactive');
                                                                    set(ht(1), 'Enable', 'inactive');
                   
               case '4191+Ron''s'
                    ht =  get(rec.UI.H.hAmp_Toggle1, 'Children');	set(ht(3), 'Enable', 'inactive');
                                                                    set(ht(2), 'Enable', 'inactive');
                                                                    set(ht(1), 'Enable', 'inactive');
                    ht =  get(rec.UI.H.hAmp_Toggle2, 'Children');   set(ht(3), 'Enable', 'on');
                                                                    set(ht(2), 'Enable', 'on');
                                                                    set(ht(1), 'Enable', 'on');
               case '4189+2250'
                    ht =  get(rec.UI.H.hAmp_Toggle1, 'Children');	set(ht(3), 'Enable', 'inactive');
                                                                    set(ht(2), 'Enable', 'on');
                                                                    set(ht(1), 'Enable', 'on');
                    ht =  get(rec.UI.H.hAmp_Toggle2, 'Children');   set(ht(3), 'Enable', 'on');
                                                                    set(ht(2), 'Enable', 'on');
                                                                    set(ht(1), 'Enable', 'on');
               otherwise
                   errordlg('Amp identification error')
           end
                        
        case 'hNIDAQ_Rocker'
            rec.NIDAQ_Card =  val;         
            switch rec.NIDAQ_Card
                case 'NI PCIe-6323'
                    rec.NIDAQ_OptionNum = 1;
                    rec.MicSys_Amp_DR =         rec.MicSysOptions(rec.MicSysNum).Amp_MaxDR;
                        GUI_Toggle('hDR_Toggle1',	[num2str(rec.MicSys_Amp_DR) 'V']);
                    % Switch 2V/0.2V GUI
                    ht =  get(rec.UI.H.hDR_Toggle1, 'Children');    set(ht(1), 'Enable', 'inactive');
                    ht =  get(rec.UI.H.hDR_Toggle2, 'Children');    set(ht(2), 'Enable', 'inactive');
                case 'NI USB-6251'
                    rec.NIDAQ_OptionNum = 2;
                    % Switch 2V/0.2V GUI
                    ht =  get(rec.UI.H.hDR_Toggle1, 'Children');    set(ht(1), 'Enable', 'on');
                    ht =  get(rec.UI.H.hDR_Toggle2, 'Children');    set(ht(2), 'Enable', 'on');
                otherwise
            end
        case 'hStartStop_Rocker'       
            switch val
                case 'Start';   rec.recording = 1; RecordStart;
                case 'Stop';    rec.recording = 0;
                otherwise
            end
            %% DO SOMETHING HERE  
        otherwise
            errordlg('Rocker tag unrecognizable!');
    end
	msg = [datestr(now, 'yy/mm/dd HH:MM:SS.FFF'),'\GUI_Rocker\',label,' selected as ',val,'\r\n'];
    disp(msg);
        
function GUI_Toggle(varargin)
    global rec;
  	%% where the call is from      
    if nargin==0
        % called by GUI:            GUI_Toggle
        label =     get(gcbo,'Tag'); 
        val =       get(get(gcbo,'SelectedObject'),'string');
    else
        % called by general update: GUI_Toggle('hSys_LightSource_Toggle', 'Blue')
        label =     varargin{1};
        val =       varargin{2};
    end    
    %% Update GUI
    eval(['h{1} = rec.UI.H.', label(1:end-1) '1;'])
    eval(['h{2} = rec.UI.H.', label(1:end-1) '2;'])   
	hc{1}.h =   get(h{1}, 'Children');
	hc{2}.h =   get(h{2}, 'Children');
  	for i = 1:2
        for j = 1:3
            if strcmp( get(hc{i}.h(j), 'string'), val )
                set(h{i},   'SelectedObject', hc{i}.h(j) );
                set(h{3-i}, 'SelectedObject', '');
                set(hc{i}.h(j),	'backgroundcolor', rec.UI.C.SelectB);
            else                
                set(hc{i}.h(j),	'backgroundcolor', rec.UI.C.TextBG);
            end
        end
    end
	%% Update D & Log
    switch label(1:end-1)
        case 'hAmp_Toggle'      
            rec.MicSys_Amp_GaindB =     str2double(val(1:end-3)); 
            if strcmp(rec.MicSys_Amp_Name, 'Ron''s')
                eval(['rec.MicSys_Amp_GainNum = rec.MicSys_AmpRon.Gain',sprintf('%02d',rec.MicSys_Amp_GaindB),';']);
            else
                rec.MicSys_Amp_GainNum = 10^(rec.MicSys_Amp_GaindB/20);
            end
        case 'hDR_Toggle'
            rec.MicSys_Amp_DR =      str2double(val(1:end-1));
        otherwise
            errordlg('Toggle tag unrecognizable!');
    end
	msg = [datestr(now, 'yy/mm/dd HH:MM:SS.FFF'),'\GUI_Toggle\',label,' selected as ',val,'\r\n'];
    disp(msg);
        
function RecordStart

    global rec

    rec.recordtime = 0; 
    rec.waveform = [];    
    
    rec.NIDAQ_D.Dev.devName =	rec.NIDAQ_Options(rec.NIDAQ_OptionNum).Dev.devName;
    T =                         [];
    T.taskName =                'CO Trigger Task';
    T.chan(1).deviceNames =     rec.NIDAQ_D.Dev.devName;
    T.chan(1).chanIDs =         rec.NIDAQ_Options(rec.NIDAQ_OptionNum).CO.chanIDs;
    T.chan(1).chanNames =       'CO Trigger Channel';
    T.chan(1).lowTime =         0.001;
    T.chan(1).highTime =        0.001;
    T.chan(1).initialDelay =    0.1;
    T.chan(1).idleState =       'DAQmx_Val_Low';
    T.chan(1).units =           'DAQmx_Val_Seconds';
    rec.NIDAQ_D.CO =	T;
    
    T =                             [];
    T.taskName =                    'AI SoundRec Task';
    T.chan(1).deviceNames =         rec.NIDAQ_D.Dev.devName;
    T.chan(1).chanIDs =             rec.NIDAQ_Options(rec.NIDAQ_OptionNum).AI.chanIDs;
    T.chan(1).chanNames =           'AI SoundRec Channel';
    T.chan(1).minVal =          -   rec.MicSys_Amp_DR;
    T.chan(1).maxVal =              rec.MicSys_Amp_DR;
    T.chan(1).units =               'DAQmx_Val_Volts';
    T.chan(1).terminalConfig =      'DAQmx_Val_Diff';
    T.time.rate =                   rec.NIDAQ_SR; 
    T.time.sampleMode =             'DAQmx_Val_ContSamps';
    T.time.sampsPerChanToAcquire =  rec.RecTime*rec.NIDAQ_SR;
    T.trigger.triggerSource =       ['Ctr',num2str(rec.NIDAQ_Options(rec.NIDAQ_OptionNum).CO.chanIDs),'InternalOutput'];
    T.trigger.triggerEdge =         'DAQmx_Val_Rising';
    
    T.everyN.callbackFunc =         @RecordCallback;
    T.everyN.everyNSamples =        round(rec.NIDAQ_SR/rec.NIDAQ_UR);
    T.everyN.readDataEnable =       true;
    T.everyN.readDataTypeOption =   'Scaled';   % versus 'Native'
    
    T.read.outputData =             [];
    rec.NIDAQ_D.AI =    T;    
    
    rec.NIDAQ_H =	CtrlNIDAQ('Creating',                   rec.NIDAQ_D);
                    CtrlNIDAQ('Commiting',  rec.NIDAQ_H,    rec.NIDAQ_D);
                    
    % Putting this function here is easier for callback 
	rec.NIDAQ_H.hTask_AI.registerEveryNSamplesEvent(...
        rec.NIDAQ_D.AI.everyN.callbackFunc,     rec.NIDAQ_D.AI.everyN.everyNSamples,...
        rec.NIDAQ_D.AI.everyN.readDataEnable,   rec.NIDAQ_D.AI.everyN.readDataTypeOption);

                    CtrlNIDAQ('Starting',	rec.NIDAQ_H,    rec.NIDAQ_D);

function RecordPlot
    global rec
        
    rec.sys.Marmoset.AudiogramFreq = 1000*[...
        0.1250	0.2500	0.5000	1.0000	2.0000	4.0000	6.0000	7.0000	8.0000	10.0000	12.0000 16.0000 32.0000 36.0000 ];
    rec.sys.Marmoset.AudiogramLevel = [...
        51.2000 36.4250 26.5250 18.1250 21.2750 18.9500 10.7750 6.8875  10.5500 14.1000 17.5250 20.1500 27.8500 39.0500 ];

    rec.sys.Marmoset.ERB_Freq = [...
        250     500     1000    7000    16000];
    rec.sys.Marmoset.ERBraw = [...
        90.97   126.85  180.51  460.83  2282.71];
    
    %% Calculate the SPL, temporal & spectral
    L = length(rec.waveform);
    t_vol = rec.waveform*1000;
                                            % VOLtage (in mV), dynamic range is 200mV, 16bit sampling
    t_vol = t_vol/rec.MicSys_Amp_GainNum;	% VOLtage (in mV), output @ the microphone
	t_sp = t_vol/rec.MicSys_MIC_mVperPa;	% Sound Pressure (in Pascal), @ the microphone
    t_sprms = sqrt(mean(t_sp.^2));   	% Sound Pressure (in Pascal(rms)), a single number now  
    t_dbspl = 20*log10(t_sprms)+ 94;	% in dB SPL, 94dB SPL = 1 pascal rms
                                                    
    S_sp = fft(t_sp)/L;                             % Sound Pressure (in Pascal/freq bin), nomalized by L 
    S_sp = abs(S_sp(1:(floor(L/2)+1)));             % Sound Pressure (in Pascal/freq bin), through away phase, and cut half
	S_sp(2:ceil(L/2)) = S_sp(2:ceil(L/2))*sqrt(2);  % Sound Pressure (in Pascal/freq bin), combine mirrored power  
    S_dbspl = 10*log10(sum(S_sp.^2))+94;    % dB SPL, abosolute sound level, (1Pascal rms = 94dB SPL)
    S_dbspl_raw = 10*log10(S_sp.^2)+94; 	% the spectrum in dB SPL  
    N = length(S_dbspl_raw);
    freq = ( (0:N-1)*rec.NIDAQ_SR/2/N )';
    switch rec.MicSys_Amp_Name                 % compensate the filter shape
        case 'Ron''s'
            S_dbspl_comp = S_dbspl_raw + 10*log10(1+(freq/rec.MicSys_AmpRon.CufFreq).^2);
        otherwise
            S_dbspl_comp = S_dbspl_raw;
    end
    if abs(t_dbspl - S_dbspl)<0.001         % double check the SPL calculation
        disp(['the total acoutic power is ',num2str(t_dbspl),' dB SPL']);
    else
        disp('what''s the hell?');
    end
    S_FreqERB =     250*2.^(0:0.1:6);
    S_ERB =         interp1(rec.sys.Marmoset.ERB_Freq, rec.sys.Marmoset.ERBraw, S_FreqERB,'spline');
    S_ERB_dbspl =   zeros(1,length(S_ERB));
    for i = 1: length(S_FreqERB)
        ERBmin = S_FreqERB(i) - 0.5*S_ERB(i);
        ERBmax = S_FreqERB(i) + 0.5*S_ERB(i);
        binmin = find(freq>ERBmin,1);
        binmax = find(freq>ERBmax,1) -1;
        S_ERB_dbspl(i) = 10*log10( sum(S_sp(binmin:binmax).^2) )+94;
    end
    
	%% Figure
    t.FigurePosition =      [0.1 0.1 0.15 0.4];
    t.FigureFontSize =      10;
    
    t.AxesSideLeft =        0.11;
    t.AxesSideRight =      	0.12;
    t.AxesWidth =           1 - t.AxesSideLeft - t.AxesSideRight;
    t.AxesHeightT =         0.2;
    t.AxesHeightSpace =     0.05;
    t.AxesHeightS =         0.62;
    t.AxesHeightStart =     0.08;
    
    t.AxesTempYMax =        rec.MicSys_Amp_DR;
    t.AxesTempYLim =        rec.MicSys_Amp_DR*1.1;
    t.AxesTempXLabel =      'Time (in second)';
    t.AxesTempXLabelV =     'Bottom';
    t.AxesTempYLabel =      {'Amplitude','(norm.)'};
    t.AxesTempYLabelV =     'Cap';
    t.LineTempYMaxColor =   [   1       0       0];
    t.LineTempWaveColor =   [   0       0.447   0.741];
    
    t.AxesSpecYTick =       -60:20:100;
    t.AxesSpecXLim =        [50 50e3];
    t.AxesSpecYLim =        [-60 100];
    t.AxesSpecXLabel =      'Frequency (in Hz)';
    t.AxesSpecXLabelV =   	'Cap';
    t.AxesSpecYLabel1 =   	'Sound Pressure Level Density (dB/Hz)';
    t.AxesSpecYLabel1V =   	'Baseline';
    t.AxesSpecYLabel2 =   	'Sound Pressure Level (dB SPL)';
    t.AxesSpecYLabel2V =   	'Cap';
    t.AxesSpecLegText =     {   'Noise floor density (in dB/Hz)',...
                                'Marmoset audiogram (in dB SPL)',...
                                'Marmoset ERB weighted noise (in dB SPL)'};
    t.AxesSpecLegLocation = 'Northeast';    
    t.LineSpecNoiseRColor = [   0       0.447   0.741];
    t.LineSpecAudiogColor = [   1       0       0];
    t.LineSpecNoiseEColor = [   0       1       0];  
    
    % Figure
    figure( 'units',                'normalized',...
            'position',             t.FigurePosition);
    warning('off',                  'all');
    % Temporal Waveform    
    axes(   'Position',             [t.AxesSideLeft,    t.AxesHeightStart+t.AxesHeightS+t.AxesHeightSpace,...
                                    t.AxesWidth,        t.AxesHeightT]);
    hold on;
    plot(rec.waveform,...
            'Color',                t.LineTempWaveColor);
    set(gca,...
            'Xtick',                [1 L],...
            'XTickLabels',          {'0', num2str(L/rec.NIDAQ_SR)},...
            'XLim',                 [1, L],...
            'Box',                  'on');
    h = xlabel(t.AxesTempXLabel,...
            'FontSize',             t.FigureFontSize);
    set(h,  'VerticalAlignment',	t.AxesTempXLabelV);
    
    % Dynamic Range Max/Min lines
    plot(1:L,   +t.AxesTempYMax*ones(1,L),...
            'Color',                t.LineTempYMaxColor);
    plot(1:L,   -t.AxesTempYMax*ones(1,L),...
            'Color',                t.LineTempYMaxColor);
	set(gca,...        
            'Ytick',                [- t.AxesTempYMax  t.AxesTempYMax],...
            'YLim',                 [-t.AxesTempYLim,    t.AxesTempYLim],...
            'YTickLabels',          {'DR-', 'DR+'});
	h = ylabel(t.AxesTempYLabel,...
        	'FontSize',             t.FigureFontSize);
	set(h,  'VerticalAlignment', 	t.AxesTempYLabelV);
    

    % Spectrum
    axes(   'Position',             [t.AxesSideLeft,    t.AxesHeightStart,...
                                    t.AxesWidth,        t.AxesHeightS]);
    semilogx(freq, S_dbspl_comp,...
            'Color',                t.LineSpecNoiseRColor); 
    set(gca,...
            'Xlim',                 t.AxesSpecXLim,...
            'YTick',                t.AxesSpecYTick,...
            'Ylim',                 t.AxesSpecYLim,...
            'XGrid',              	'on',...
            'YGrid',              	'on',...
            'NextPlot',             'add');  
    
    % Marmoset audiogram
    plot(rec.sys.Marmoset.AudiogramFreq, rec.sys.Marmoset.AudiogramLevel,...
            'Color',            	t.LineSpecAudiogColor);
    
    % Marmoset ERB weighted noise
    rec.curve.Freq =    S_FreqERB;
    rec.curve.dBSPL =   S_ERB_dbspl;
    disp(['max peak on the ERB weighted level is ', num2str(max(rec.curve.dBSPL)), ' dB SPL']);
    plot(S_FreqERB, S_ERB_dbspl,...
            'Color',             	t.LineSpecNoiseEColor);
	h = xlabel(t.AxesSpecXLabel,...
           	'FontSize',             t.FigureFontSize);
   	set(h,  'VerticalAlignment', 	t.AxesSpecXLabelV);
    h = ylabel(t.AxesSpecYLabel1,...
         	'FontSize',             t.FigureFontSize);
  	set(h,  'VerticalAlignment', 	t.AxesSpecYLabel1V);
%     legend( t.AxesSpecLegText,...
%             'Location',             t.AxesSpecLegLocation,...
%             'Box',                  'off');
    axes(   'Position',             [t.AxesSideLeft,    t.AxesHeightStart,...
                                    t.AxesWidth,        t.AxesHeightS],...
            'Color',                'none',...
            'XAxisLocation',        'Top',...
            'YAxisLocation',        'Right',...
            'XTick',                [],...
            'YTick',                t.AxesSpecYTick,...
            'Ylim',                 t.AxesSpecYLim);
    h = ylabel(t.AxesSpecYLabel2,...
         	'FontSize',             t.FigureFontSize);
  	set(h,  'VerticalAlignment', 	t.AxesSpecYLabel2V);
        
    warning('on', 'all');
    
    
function RecordSave
    global rec
    
    ds = datestr(now);
    tt = [  rec.MicSys_MIC_Name,'; ',...
            rec.MicSys_Amp_Name,'@Gain=',num2str(rec.MicSys_Amp_GainNum),'; ',...
            'AI@',num2str(rec.NIDAQ_D.AI.chan.maxVal),'V'];
    wholename = [ds(1:11),'_',ds([end-7 end-6 end-4 end-3 end-1 end]),'_',rec.FileNameHead,'.wav'];
    audiowrite([rec.FileDir wholename],...
        int16(32767*rec.waveform/rec.MicSys_Amp_DR), 100e3,...
        'BitsPerSample',    16,...
        'Artist',           tt,...
        'Title',            rec.FileNameHead,...
        'Comment',          'Acoustic Calibration Recording, from Xrecorder by Xindong Song');
    
function RecordLoad
    global rec
    
    [t.filename, t.pathname] = uigetfile([rec.FileDir '*.wav']);
    t.wavefilename  = [t.pathname t.filename];
    t.info          = audioinfo(t.wavefilename);
    disp(t.info.Artist);
    t.sysinfo       = strsplit(t.info.Artist, '; ');
    t.sysinfo2      = strsplit(t.sysinfo{2}, '@Gain=');
    t.sysinfo3      = strsplit(t.sysinfo{3}(4:end), 'V');

    t.sys.MIC.name  = t.sysinfo{1};
    t.sys.Amp.name  = t.sysinfo2{1};
    t.sys.Amp.Gain  = str2double(t.sysinfo2{2});
    t.sys.NIDAQ.AI_ChanVoltage ...
                    = str2double(t.sysinfo3{1});

        [   rec.waveform,   rec.NIDAQ_SR] = audioread(t.wavefilename,'native');
            rec.MicSys_Amp_DR =         t.sys.NIDAQ.AI_ChanVoltage;
            rec.MicSys_Amp_GainNum =    t.sys.Amp.Gain;
            rec.MicSys_Amp_Name =       t.sys.Amp.name;
            rec.MicSys_MIC_Name =       t.sys.MIC.name;

            rec.waveform =              double(rec.waveform)/32767*rec.MicSys_Amp_DR;
    switch rec.MicSys_MIC_Name
        case '4191'
            rec.MicSys_MIC_mVperPa =    13.2;
        case '4189'
            rec.MicSys_MIC_mVperPa =    51.3;
        otherwise
            errordlg('Microphone not recognized!');
    end
                    RecordPlot;

function RecordCallback(~,evnt)
    global rec
    
    % Time maintainence
    rec.recordtime = rec.recordtime + 0.1;    
    set(rec.UI.H.hRecTime_Edit, 'string', sprintf('%5.1f', rec.recordtime));
    if rec.recordtime >= rec.RecTime-0.05
        GUI_Rocker('hStartStop_Rocker', 'Stop');
    end
    
    % Read data
    data = evnt.data;
    rec.waveform = [rec.waveform; data];
    
    % Weather stop
    if rec.recording == 0
%         pause(0.2)
%                     CtrlNIDAQ('Stopping',	rec.NIDAQ_H,    rec.NIDAQ_D);
                    CtrlNIDAQ('Deleting',	rec.NIDAQ_H);
                    RecordPlot;
    end
    
    
    


