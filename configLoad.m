function CONF = configLoad()
%CONFIGLOAD �Զ��������������ò���
%   CNF Ϊ struct
CONF.picFolder = "pics";
CONF.debugDataPath = fullfile(CONF.picFolder, "debug_data.mat");
CONF.stimulateJarPath = fullfile(CONF.picFolder, "Psy4J.jar");
CONF.repeat = 100;
CONF.targetNumber = 6;
CONF.cheeseRow = 8;

CONF.debug = true;
if CONF.debug 
	CONF.screenSize = [10,10,800,600];
else
	CONF.screenSize = [];
end

