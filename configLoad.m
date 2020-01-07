function CONF = configLoad()
%CONFIGLOAD 自定义程序的所有配置参数
%   CNF 为 struct

%%%%%%%%%%%%% 程序参数和配置，此处定义  %%%%%%%%%%%%

CONF.debug = false;
CONF.noDebugSkipSyncTest = true; % 在正式实验前，去除这里的标记以让程序同步刷新
CONF.defaultSeekForISI = 1;

if CONF.debug 
	CONF.screenSize = [10,10,900,700];
else
	CONF.screenSize = [];
end

CONF.picFolder = "pics";
CONF.stimulateJarFile = "Psy4J.jar";
CONF.targetNumber = 6;
CONF.cheeseRow = 8;
CONF.cheeseGridWidth = 60;

CONF.defaultName = 'DebugName';
CONF.defaultGender = 0;
CONF.defaultNote = 'DebugNote'; 
CONF.defaultPicID = '1779';
CONF.defaultISI = 0.04;

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

if CONF.debug
	CONF.isiNeedFs = [0, 1, 2];
	CONF.learnTakeIsiNeedFs = [0, 1];
	CONF.numberNeed = [2, 6];
	CONF.learnTakeNumberNeed = 2;
	CONF.repeatTrial = 4;
	CONF.learnRepeatTrial = 4;
	CONF.participartRelex = 1;
	CONF.useUnlimitLearn = true;
	CONF.minCurrent = 0.5;
	CONF.repKNeed = [5, 6];
	CONF.learnRepKNeed = 5;
else
	CONF.isiNeedFs = [0, 1, 2, 3, 4, 5];
	CONF.learnTakeIsiNeedFs = 0;
	CONF.numberNeed = [1, 2, 3, 4, 5];
	CONF.learnTakeNumberNeed = [2, 4];
	%这里指的是得到每个结果重复的次数(在 ISISeeker 中指得到一个 ISI 在 Seg/Int 条件下的值重复的次数)，
	%而非是一种具体条件的重复次数，在 ISISeeker 中 repeatTrial 和 learnRepeatTrial 需要为 4 的倍数，
	%因为做了 fullCross，因此重复被分配给 Target-NoTarget 1-0 1-1 0-1 0-0 四种情况,
	%在 NUMSeeker 中需要为 5 的倍数，因为做了 fullCross 后，1,2,3,4,5 五个数字至少保证每个分配到 1 次
	%但是因为在调试中最小公倍数为 20，因此在代码中有判断，如果值不可用，则选择 1.
	CONF.repeatTrial = 20;
	CONF.learnRepeatTrial = 20;
	CONF.participartRelex = 60;
	CONF.useUnlimitLearn = true;
	CONF.minCurrent = 0.9;
	CONF.repKNeed = [2, 3, 4];
	CONF.learnRepKNeed = 4;
end

% when ISI = 1,  the integration effect is best, but the segregation is difficult
% when ISI = 10, the segregation effect is best, but the integration is difficult
% CONF.stimulateDuration = 0.033; 废弃，使用 Fs 计算
% CONF.crossDuration = 1;
% CONF.feedbackSecs = 0.5;
CONF.crossDurationFs = 60;
CONF.feedbackFs = 30;
CONF.stimulateDurationFs = 1;
CONF.beforeMaskDelayFs = 5;
CONF.beforeRectChooseDelayFs = 5;
CONF.maskDurationFs = 5;