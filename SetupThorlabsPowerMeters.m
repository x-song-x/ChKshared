function SetupThorlabsPowerMeters(MainVarStr)
% This function setup Thorlabs Power Meters in the MainVarStr 
% ('Xin' or 'TP')
%       MainVarStr:     'Xin' or 'TP'

global Xin TP
persistent I
persistent O

%% L: Load In
I = [];
str = ['I.PowerMeter = ', MainVarStr, '.D.Sys.PowerMeter;'];	eval(str);
%% instrreset for clean up !!!
instrreset;
pause(1);

%% Power Meter through NI VISA interface
for i = 1:length(I.PowerMeter)
    O.PM100{i}.name =     I.PowerMeter{i}.Console;
    O.PM100{i}.h =        visa('ni', I.PowerMeter{i}.RSRCNAME);
        fopen(	O.PM100{i}.h);    
        fprintf(O.PM100{i}.h,'*WAI');
        fprintf(O.PM100{i}.h,'*RST');	% Reset the device
        fprintf(O.PM100{i}.h,'*TST?');	% Self test
        temp =  O.PM100{i}.h.fscanf;
    if ~strcmp(temp(1),'0')
        errordlg('The Thorlabs Power Meter cannot pass self test');
        return;
    end 
        fprintf(O.PM100{i}.h,'*IDN?');	% Identification 
        temp =	O.PM100{i}.h.fscanf;
    I.PowerMeter{i}.IDeNtification = temp;
                % Thorlabs,PM100A,P1003352,2.4.0
                % Thorlabs,PM100USB,P2004081,1.4.0
                % THORLABS,MMM,SSS,X.X.X  
                % Where:    MMM  is the model code 
                %           SSS  is the serial number 
                %           X.X.X is the instrument firmware revision level  
        fprintf(O.PM100{i}.h,['SYST:LFR ', num2str(I.PowerMeter{i}.LineFRequency)]);	% Setup line filter
        fprintf(O.PM100{i}.h, 'SYST:SENS:IDN?');	% Sensor 
        temp =	O.PM100{i}.h.fscanf;
   	I.PowerMeter{i}.SENSor = temp;
        % strtok(O.PM100{i}.h.fscanf,',');
                % S140C,11040529,05-Apr-2011,1,18,289
                % S121C,14081201,12-Aug-2014,1,18,289
                % S310C,130801,29-JUL-2013,2,18,289
                % S170C,701207,17-Dec-2014,1,2,33
                % <name>,<sn>,<cal_msg>,<type>, <subtype>,<flags>
                % <name>:       Sensor name in string response format 
                % <sn>:         Sensor serial number in string response format 
                % <cal_msg>:    Calibration message in string response format 
                % <type>:       Sensor type in NR1 format 
                % <subtype>:    Sensor subtype in NR1 format 
                % <flags>:      Sensor flags as bitmap in NR1 format. 
                % Flag:  Dec.value: 
                % Is power sensor           1 
                % Is energy sensor          2 
                % Response settable         16 
                % Wavelength settable       32 
                % Tau settable              64 
                % Has temperature sensor	256 
        fprintf(O.PM100{i}.h,'DISP:BRIG 0');    % Disp Brightness (0-1)  
        fprintf(O.PM100{i}.h,'CAL:STR?');
        temp =	O.PM100{i}.h.fscanf;            % CALibration STRing
    I.PowerMeter{i}.CALibrationSTRing = temp;
        fprintf(O.PM100{i}.h,['SENS:AVER:COUN ', num2str(I.PowerMeter{i}.AVERageCOUNt)]);   % Average Counts (1~=.3ms)
        fprintf(O.PM100{i}.h,['SENS:CORR:WAV ',  num2str(I.PowerMeter{i}.WAVelength)]);     % Wavelength (nm)
        fprintf(O.PM100{i}.h, 'SENS:CORR:WAV?'); 
    if str2double(O.PM100{i}.h.fscanf) ~= I.PowerMeter{i}.WAVelength
        errordlg('The Wavelength is not setup right on one of the power meters');        
    end    
        fprintf(O.PM100{i}.h,['SENS:POW:RANG:AUTO ', num2str(I.PowerMeter{i}.POWerRANGeAUTO)]);
    if I.PowerMeter{i}.POWerRANGeAUTO
        fprintf(O.PM100{i}.h,['SENS:POW:RANG:UPP ', num2str(I.PowerMeter{i}.POWerRANGeUPPer)]);     % Power Range Upper (W)
    end
        fprintf(O.PM100{i}.h,['INP:PDI:FILT:LPAS:STAT ', num2str(I.PowerMeter{i}.INPutFILTering)]); % Sensor Bandwidth (0=High, 1=Low)

    % Send request 1st to save following read time
    if I.PowerMeter{i}.InitialMEAsurement
        fprintf(    O.PM100{i}.h,  'MEAS:POW?'); 
    end
end
str = [MainVarStr, '.HW.Thorlabs.PM100 = O.PM100;'];            eval(str);
str = [MainVarStr, '.D.Sys.PowerMeter = I.PowerMeter;'];        eval(str);

%% LOG MSG
msg = [datestr(now, 'yy/mm/dd HH:MM:SS.FFF') '\tSetupThorlabsPowerMeters\tSetup Thorlabs Power Meters\r\n'];
str = ['updateMsg(', MainVarStr, '.D.Exp.hLog, msg);'];         eval(str);
