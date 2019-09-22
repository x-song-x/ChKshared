function varargout = CtrlNIDAQ(varargin)
% This is the control software for Xindong's NIDAQ simple control 
% NIDAQ Simple Controls:
%   CO task:    chan# = 1,	as a trigger
%   AO task:    chan# >=0,	as palyback or stimulation 
%   AI task:    chan# >=0,	as recordings
%   All chans should from a single Device, NI PICe-6323, USB-6251 tested

%% For Standarized SubFunction Callback Control
import dabs.ni.daqmx.*
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
import dabs.ni.daqmx.*

function H = Creating(D)
    import dabs.ni.daqmx.*
    H.hDevice =         Device(D.Dev.devName);
    H.hDevice.reset();
        H.hTask_CO =    Task(D.CO.taskName);
            H.hTask_CO.createCOPulseChanTime(...
                D.CO.chan(1).deviceNames,	D.CO.chan(1).chanIDs,...
                D.CO.chan(1).chanNames,     ...
                D.CO.chan(1).lowTime,       D.CO.chan(1).highTime,...
                D.CO.chan(1).initialDelay,	D.CO.chan(1).idleState,...
                D.CO.chan(1).units);
    if isfield(D, 'AO')
        H.hTask_AO =    Task(D.AO.taskName);
        for i = 1:length(D.AO.chan)
            H.hTask_AO.createAOVoltageChan(...
                D.AI.chan(i).deviceNames,	D.AI.chan(i).chanIDs,...
                D.AI.chan(i).chanNames,     ...
                D.AI.chan(i).minVal,        D.AI.chan(i).maxVal,...
                D.AI.chan(i).units);  
        end
    end
    if isfield(D, 'AI')
        H.hTask_AI =    Task(D.AI.taskName);
        for i = 1:length(D.AI.chan)
            H.hTask_AI.createAIVoltageChan(...
                D.AI.chan(i).deviceNames,	D.AI.chan(i).chanIDs,...
                D.AI.chan(i).chanNames,     ...
                D.AI.chan(i).minVal,        D.AI.chan(i).maxVal,...
                D.AI.chan(i).units);  
        end
    end
    pause(0.2);

function Commiting(H, D)
% AO_wave should be a matrix of (sample# x chan#)
% No registerDoneEvent like: H.hTask_AI.registerDoneEvent(D.AI_Task_DoneEvent);
    try H.hTask_CO.abort();                             catch;  end
    try H.hTask_AO.control('DAQmx_Val_Task_Unreserve');	catch;  end
    try H.hTask_AI.control('DAQmx_Val_Task_Unreserve');	catch;  end
    if isfield(D, 'AO')
        H.hTask_AO.cfgSampClkTiming(...
            D.AO.time.rate,                 D.AO.time.sampleMode,...
            D.AO.time.sampsPerChanToAcquire);
        H.hTask_AO.cfgDigEdgeStartTrig(...
            D.AO.trigger.triggerSource,     D.AO.trigger.triggerEdge);
        H.hTask_AO.writeAnalogData(...
            D.AO.write.writeData);
    end
    if isfield(D, 'AI')
        H.hTask_AI.cfgSampClkTiming(...
            D.AI.time.rate,                 D.AI.time.sampleMode,...
            D.AI.time.sampsPerChanToAcquire);
        H.hTask_AI.cfgDigEdgeStartTrig(...
            D.AI.trigger.triggerSource,     D.AI.trigger.triggerEdge);
    end

function Starting(H, D)
    if isfield(D, 'AO');    H.hTask_AO.start(); end
    if isfield(D, 'AI');    H.hTask_AI.start(); end
                            H.hTask_CO.start(); 

function D = Stopping(H, D)
    if ~isfield(D.AI, 'everyN') 
        D.AI.read.outputData = H.hTask_AI.readAnalogData();
    end
    if isfield(D, 'AO');    H.hTask_AO.stop();  end
    if isfield(D, 'AI');    H.hTask_AI.stop();  end
                            H.hTask_CO.stop();  

function Deleting(H)
    try H.hTask_CO.abort();      catch;  end
    try H.hTask_AO.abort();      catch;  end
    try H.hTask_AI.abort();      catch;  end

    try H.hTask_CO.delete();     catch;  end
    try H.hTask_AO.delete();     catch;  end                  
    try H.hTask_AI.delete();     catch;  end

    try H.hDevice.reset();       catch;  end
    try H.hDevice.delete();      catch;  end

