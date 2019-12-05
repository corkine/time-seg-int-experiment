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
CONF.targetNumber = 6;
CONF.cheeseRow = 8;

%% 以下信息从 dialogLoad 中覆盖
CONF.seekForISI = 1;
CONF.name = 'DebugName';
CONF.gender = 0;
CONF.note = 'DebugNote'; 

%%%%%%%%%%%%% 实验参数和配置，此处定义  %%%%%%%%%%%%
CONF.ISI_INTRO= fullfile('assert','part1_intro.png');
CONF.ISI_INTRO_S= fullfile('assert','part1_intro_s.png');
CONF.ISI_INTRO_I = fullfile('assert','part1_intro_i.png');
CONF.ISI_INTRO_S_EX = fullfile('assert','part1_intro_s_ex.png');
CONF.ISI_INTRO_I_EX = fullfile('assert','part1_intro_i_ex.png');

CONF.NUM_INTRO= fullfile('assert','part2_intro.png');
CONF.NUM_INTRO_S= fullfile('assert','part2_intro_s.png');
CONF.NUM_INTRO_I = fullfile('assert','part2_intro_i.png');
CONF.NUM_INTRO_S_EX = fullfile('assert','part2_intro_s_ex.png');
CONF.NUM_INTRO_I_EX = fullfile('assert','part2_intro_i_ex.png');
CONF.GRAY_IMAGE = fullfile('assert','gray.jpg');

CONF.crossSize = 50;
CONF.crossDuration = 1;
CONF.stimulateDuration = 0.03;
CONF.maxAnswerDelaySeconds = 2;

if CONF.debug
	CONF.isiNeed = [0, 0.02, 0.5];
	CONF.numberNeed = [2,6];
	CONF.learnTakeIsiNeed = [0];
	CONF.repeatTrial = 2;
	CONF.participartRelex = 1;
else
	CONF.isiNeed = [0, 0.01, 0.02, 0.05, 0.1, 0.2, 0.3, 0.4, 0.5];
	CONF.numberNeed = [2,3,4,5,6];
	CONF.learnTakeIsiNeed = [0, 60];
	CONF.repeatTrial = 20;
	CONF.participartRelex = 60;
end


