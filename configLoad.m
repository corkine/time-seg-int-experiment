function CONF = configLoad()
%CONFIGLOAD �Զ��������������ò���
%   CNF Ϊ struct

%%%%%%%%%%%%% ������������ã��˴�����  %%%%%%%%%%%%

CONF.debug = true;
if CONF.debug 
	CONF.screenSize = [10,10,800,600];
else
	CONF.screenSize = [];
end

CONF.picFolder = "pics";
CONF.debugDataPath = fullfile(CONF.picFolder, "debug_data.mat");
CONF.stimulateJarPath = fullfile(CONF.picFolder, "Psy4J.jar");
CONF.repeat = 100;
CONF.targetNumber = 6;
CONF.cheeseRow = 8;

%% ������Ϣ�� dialogLoad �и���
CONF.seekForISI = 1;
CONF.name = 'DebugName';
CONF.gender = 0;
CONF.note = 'DebugNote'; 

%%%%%%%%%%%%% ʵ����������ã��˴�����  %%%%%%%%%%%%
