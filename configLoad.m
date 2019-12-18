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
CONF.stimulateJarFile = "Psy4J.jar";
CONF.targetNumber = 6;
CONF.cheeseRow = 8;
CONF.cheeseGridWidth = 60;

CONF.seekForISI = 0;
CONF.name = 'DebugName';
CONF.gender = 0;
CONF.note = 'DebugNote'; 
CONF.picID = '1779';
CONF.prefISI = 0.04;

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
CONF.feedbackSecs = 0.5;


if CONF.debug
	CONF.isiNeedFs = [0, 1, 2];
	CONF.learnTakeIsiNeedFs = [0, 1];
	CONF.numberNeed = [2, 6];
	CONF.learnTakeNumberNeed = [2];
	CONF.repeatTrial = 2;
	CONF.learnRepeatTrial = 2;
	CONF.participartRelex = 1;
	CONF.useUnlimitLearn = true;
	CONF.minCurrent = 0.5;
else
	CONF.isiNeedFs = [0, 1, 2, 3, 4, 5, 6, 7, 8];
	CONF.learnTakeIsiNeedFs = [2, 3];
	CONF.numberNeed = [2, 3, 4, 5, 6];
	CONF.learnTakeNumberNeed = [2, 4];
	CONF.repeatTrial = 20;
	CONF.learnRepeatTrial = 10;
	CONF.participartRelex = 60;
	CONF.useUnlimitLearn = true;
	CONF.minCurrent = 0.9;
end

% when ISI = 1,  the integration effect is best, but the segregation is difficult
% when ISI = 10, the segregation effect is best, but the integration is difficult
CONF.flashcardsRepetitionK = 5/1;
CONF.stimulateDuration = 0.033;
CONF.stimulateDurationFs = 1;
CONF.prefISIFs = 1*1;
CONF.beforeMaskDelayFs = 5;
CONF.beforeRectChooseDelayFs = 5;
CONF.maskDurationFs = 5;