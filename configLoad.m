function CONF = configLoad()
%CONFIGLOAD �Զ��������������ò���
%   CNF Ϊ struct

%%%%%%%%%%%%% ������������ã��˴�����  %%%%%%%%%%%%

CONF.debug = false;
CONF.noDebugSkipSyncTest = true; % ����ʽʵ��ǰ��ȥ������ı�����ó���ͬ��ˢ��
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

%%%%%%%%%%%%% ʵ����������ã��˴�����  %%%%%%%%%%%%
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
	CONF.isiNeedFs = [0, 1, 2, 3, 4];
	CONF.learnTakeIsiNeedFs = [2, 3];
	CONF.numberNeed = [1, 2, 3, 4, 5];
	CONF.learnTakeNumberNeed = [2, 4];
	%����ָ���ǵõ�ÿ������ظ��Ĵ������� ISISeeker �� repeatTrial �� learnRepeatTrial ��ҪΪ 4 �ı�����
	%��Ϊ���� fullCross������ظ�������� Seg-Int 1-0 1-1 0-1 0-0 �������
	CONF.repeatTrial = 20;
	CONF.learnRepeatTrial = 4;
	CONF.participartRelex = 60;
	CONF.useUnlimitLearn = true;
	CONF.minCurrent = 0.9;
	CONF.repKNeed = [5, 6, 7];
	CONF.learnRepKNeed = [5, 6, 7];
end

% when ISI = 1,  the integration effect is best, but the segregation is difficult
% when ISI = 10, the segregation effect is best, but the integration is difficult
% CONF.stimulateDuration = 0.033; ������ʹ�� Fs ����
% CONF.crossDuration = 1;
% CONF.feedbackSecs = 0.5;
CONF.crossDurationFs = 60;
CONF.feedbackFs = 30;
CONF.stimulateDurationFs = 1;
CONF.beforeMaskDelayFs = 5;
CONF.beforeRectChooseDelayFs = 5;
CONF.maskDurationFs = 5;