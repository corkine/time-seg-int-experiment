function CONF = configLoad()
%CONFIGLOAD 自定义程序的所有配置参数
%   CNF 为 struct

%%%%%%%%%%%%% 程序参数和配置，此处定义  %%%%%%%%%%%%

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

%% 以下信息从 dialogLoad 中覆盖
CONF.seekForISI = 1;
CONF.name = 'DebugName';
CONF.gender = 0;
CONF.note = 'DebugNote'; 

%%%%%%%%%%%%% 实验参数和配置，此处定义  %%%%%%%%%%%%
