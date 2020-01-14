function [SCR, EXP] = runNumSeeker(SCR, EXP, CONF)
% RUNNUMSEEKER Ѱ����� NUM ��ʵ�� Trial ����
%
%   [ADD] EXP.segStartTime, EXP.intStartTime, Stimuli.maskOnsetReal, Stimuli.maskOffSetReal
%   prepareMaterial 
% 		[ADD] EXP.pictures, EXP.numberWithRepeat, EXP.answers, EXP.actionTime, 
% 			  EXP.usedData, EXP.userAnswers, EXP.totalStiShowTime

% ׼��һЩ�ɸ��õı����� PTB ����
w = SCR.window;
vblSlack = SCR.vblSlack;
textureGray = MakeTexture(w, CONF.GRAY_IMAGE);
duration = CONF.stimulateDurationFs * SCR.frameDuration;
beforeMaskDelay = CONF.beforeMaskDelayFs * SCR.frameDuration;
beforeRectChooseDelay = CONF.beforeRectChooseDelayFs * SCR.frameDuration;
maskDuration = CONF.maskDurationFs * SCR.frameDuration;
feedbackSecs = CONF.feedbackFs * SCR.frameDuration;
crossDuration = CONF.crossDurationFs * SCR.frameDuration;
prefISI = EXP.prefISIFs * SCR.frameDuration;
repetitionK = EXP.usedK;

isLearn = EXP.isLearn;
isSeg = EXP.isSeg;

if isLearn
	needFeedback = true;
else
	needFeedback = false;
end
if isSeg
	trialMark = 'SEG';
else
	trialMark = 'INT';
end

% ׼��ͼƬ��ʵ����ϣ����� trial
[EXP, trialsCount, textures] = prepareMaterial(CONF, EXP, w);
Stimuli = initMask(SCR, CONF);

% ��ʼѭ������ trial
Screen('DrawTexture',w,textureGray,[],[]); Screen('Flip',w);

lastOffSet = GetSecs;
C = 1;
while (C - 1 < trialsCount)

	t01 = textures{C, 1};
	t02 = textures{C, 2};
	pictureUsed = EXP.pictures{C, 3};
	segNum = EXP.pictures{C, 4};
	intNum = EXP.pictures{C, 5};
	currentNum = EXP.numberWithRepeat(C);

	fprintf('%-20s -- %d %s Trial, seg %1.0f, int %1.0f, repK %1.0f, Number %d, prefISI %1.0f ms, Image %s\n', '[SEEKER][PREPARE]', ...
			C, trialMark, segNum, intNum, repetitionK, currentNum ,prefISI * 1000, pictureUsed);

	% �ȳ��� cross
	fprintf('%-20s Show Fixation Cross in %1.0f ms\n','[SEEKER][SHOW]', crossDuration * 1000);
	crossOffSet = drawFocusCross(w, lastOffSet, vblSlack, CONF.crossSize, crossDuration);
	% ѭ�� repetitionK �γ��ִ̼�
	Priority(2);
	K = 0; 
	lastOffSetInner = crossOffSet;
	fprintf('%-20s Show First Image %1.0f ms, ISI %1.0f ms, Last Image %1.0f ms with %1.0f repeat\n', ...
			'[SEEKER][SHOW]',duration * 1000, prefISI * 1000, duration * 1000, repetitionK);
	while K < repetitionK
		[t1OffSet, t1OnsetReal] = drawImage(w, lastOffSetInner, vblSlack, t01, duration);
		waitOffSet = drawImage(w, t1OffSet, vblSlack, textureGray, prefISI);
		t2OffSet = drawImage(w, waitOffSet, vblSlack, t02, duration);
		[lastOffSetInner, t2OffsetReal] = drawImage(w, t2OffSet, vblSlack, textureGray, prefISI);
		if K == 0, stimuliOnset = t1OnsetReal; end
		K = K + 1;
	end
	% ���� beforeMaskDelay ����� mask
	Screen('FillRect', w, Stimuli.MaskRectsColor,Stimuli.MaskRects);
	Stimuli.maskOnsetReal = Screen('flip', w, t2OffsetReal + beforeMaskDelay - vblSlack);
	Stimuli.maskOffSetReal = Screen('flip', w, Stimuli.maskOnsetReal + maskDuration - vblSlack);
	Priority(0);
	% ���� beforeRectChooseDelay ��Ҫ���Իش�
	delayOffSet = WaitSecs(beforeRectChooseDelay);
	[userAnswer, isRight, lastOffSet] = waitForRectChoose(w, delayOffSet, vblSlack,...
					currentNum, needFeedback, feedbackSecs);
	EXP.answers(C) = isRight;
	EXP.userAnswers(C) = userAnswer;
	EXP.actionTime(C) = lastOffSet - delayOffSet;
	EXP.totalStiShowTime(C) = t2OffsetReal - stimuliOnset;
	C = C + 1;
end

end
	
function t = MakeTexture(w, pictureName)
	img = imread(pictureName);
	t = Screen('MakeTexture',w,img);  
end

function [EXP, trialsCount, textures] = prepareMaterial(CONF, EXP, w)
	% �� pics �ļ��м���ͼƬ���������������������ͬʱ����� ISI������� trials��
	% ����������� EXP.pictures, ������Ҫ��һ��ʹ�õ� textures �� trialsCount���Լ����ĺ�� EXP
	%
	%   [ADD] EXP.pictures, EXP.isiWithRepeat, EXP.answers, EXP.actionTime��EXP.usedData

	% ��ȡ ISI
	if EXP.isLearn
		numberNeed = CONF.learnTakeNumberNeed;
		% �˴����ظ�Ϊ full-cross ÿ�־����������ظ�������Ϊ 20 / 5 �����֣�ÿ����������ظ� 4 ��
		% ����ľ�������ָ���� Seg-Int �������������������ʹ�� 4 �����������������ͼƬʵ�֡�
		repeatTrial = ceil(CONF.learnRepeatTrial / length(numberNeed));
	else
		numberNeed = CONF.numberNeed;
		repeatTrial = ceil(CONF.repeatTrial / length(numberNeed));
	end
	
	% ��ʱ���
	time = join(string(clock),'_');
	if EXP.isSeg
		targetNumberIndex = 4;
		if CONF.debug, fprintf('%-20s Use Debug Mode with Seg...\n','[SEEKER][SEG][DEBUG]'); end
		EXP.segStartTime = time;
	else
		targetNumberIndex = 5;
		if CONF.debug, fprintf('%-20s Use Debug Mode with Int...\n','[SEEKER][INT][DEBUG]'); end
		EXP.intStartTime = time;
	end

	% ��ȡͼƬ
	trialsCount = length(numberNeed) * length(numberNeed) * repeatTrial;
	pictures = cell(trialsCount,5);
	data = EXP.data;
	% ����ÿһ�����֣����� repeat ��ͼƬ
	pictureIndex = 1;
	for segNumber = numberNeed
		for intNumber = numberNeed
			% �Ȼ�ȡ��ӦͼƬ�����п������ݣ����� data.mat ���壬
			% ÿһ�д�����֡�̼�����һ��Ϊ seg ���ĸ�ֵ���ڶ���Ϊ int ���ĸ�ֵ��
			% ������Ϊ�ںϺ�����ϵ��µ�ÿ֡�̼�����ɫΪ 1 ��ɫΪ 0
			targetPictures = data(data(:,1) == -1 * segNumber & data(:,2) == -1 * intNumber, :); %180*67
			% ��ӵ��������鹲��� pictures ����
			for i = 1: repeatTrial
				targetPictures = Shuffle(targetPictures, 2);
				targetLine = targetPictures(1,:);
				picSN = targetLine(3);
				commonFile = sprintf("sti_%d_%d_%d_%d_", segNumber, intNumber, CONF.cheeseRow, picSN);
				common = fullfile(CONF.picFolder, EXP.picID, commonFile);
				pictures{pictureIndex,1} = char(common + "head.png");
				pictures{pictureIndex,2} = char(common + "tail.png");
				pictures{pictureIndex,3} = char(common + "fusion.png");
				pictures{pictureIndex,4} = segNumber;
				pictures{pictureIndex,5} = intNumber;
				pictures{pictureIndex,6} = targetLine;
				%�޸Ĵ˴�����ע���޸� EXP.usedData��EXP.numberWithRepeat(targetNumberIndex) ����
                %�޸Ĵ̼�����ѭ���� segNum �� intNum, pictureUsed, t01, t02 ���塣
				pictureIndex = pictureIndex + 1;
			end
		end
	end

	% ����� pictures
	pictures = Shuffle(pictures,2); %ע�⣬����ʹ�� row Shuffle�������л���

	% ��ͼƬת����Ϊ����
	textures = cell(trialsCount,2);
	for i = 1 : trialsCount
		pic1 = pictures{i, 1};
		textures{i,1} = MakeTexture(w, char(pic1));
		pic2 = pictures{i, 2};
		textures{i,2} = MakeTexture(w, char(pic2));
	end

	EXP.pictures = pictures;
	EXP.numberWithRepeat = cell2mat(pictures(:,targetNumberIndex));
	EXP.usedData = cell2mat(pictures(:, 6));
	EXP.answers = ones(trialsCount,1) * -1;
	EXP.userAnswers = ones(trialsCount,1) * -1;
	EXP.actionTime = ones(trialsCount,1) * -1;
	EXP.totalStiShowTime = ones(trialsCount,1) * -1;
end

function this_offset = drawFocusCross(w, last_offset, vblSlack, fontSize, showTime)
	Screen('TextStyle', w, 0);
	Screen('TextSize', w, fontSize);
	DrawFormattedText(w, '+', 'center','center',[255 0 0]);
	this_onset_real = Screen('Flip', w, last_offset - vblSlack);
	this_offset = this_onset_real + showTime;
end

function [this_offset, this_onset_real] = drawImage(w, last_offset, vblSlack, texture, showTime)
	Screen('DrawTexture',w,texture,[],[]);        
	this_onset_real = Screen('Flip', w, last_offset - vblSlack);   
	this_offset = this_onset_real + showTime;
end

function [response, answerRight, lastOffSet] = waitForRectChoose(w, last_offset, vblSlack, rightAnswer, needFeedback, feedBackDelaySecs)
	ListenChar(2);
	Screen('Flip', w, last_offset - vblSlack);

	answer = Ask(w, 'How much target do you find? ',0, 128,'GetChar',[],'center');
	try
		response = str2double(answer);
		if response == rightAnswer
			answerRight = true;
		else
			answerRight = false;
		end
	catch
		fprintf('%-20s Get Num Error!\n', '[MAIN][RESPONSE]');
		response = -1;
		answerRight = false;
	end

	Screen('Flip',w);

	if needFeedback
		if answerRight
			DrawFormattedText(w,'Right Answer!','center','center',[0 0 0]);
			Screen('Flip',w);
		else
			DrawFormattedText(w,'Wrong Answer!','center','center',[255 0 0]);
			Screen('Flip',w);
		end
		WaitSecs(feedBackDelaySecs);
	end

	lastOffSet = Screen('Flip',w);

	fprintf('%-20s Get Response %d [Right is %d] and is Right? %d!\n', '[SEEKER][ANSWER]',...
			response, rightAnswer, answerRight);
	ListenChar(0);
end