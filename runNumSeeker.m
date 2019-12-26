function [SCR, EXP] = runNumSeeker(SCR, EXP, CONF)
% RUNNUMSEEKER 寻找最佳 NUM 的实验 Trial 序列
%
%   [ADD] EXP.segStartTime, EXP.intStartTime, Stimuli.maskOnsetReal, Stimuli.maskOffSetReal
%   prepareMaterial 
% 		[ADD] EXP.pictures, EXP.numberWithRepeat, EXP.answers, EXP.actionTime, 
% 			  EXP.usedData, EXP.userAnswers, EXP.totalStiShowTime

% 准备一些可复用的变量和 PTB 材料
w = SCR.window;
vblSlack = SCR.vblSlack;
textureGray = MakeTexture(w, CONF.GRAY_IMAGE);
duration = CONF.stimulateDurationFs * SCR.frameDuration;
beforeMaskDelay = CONF.beforeMaskDelayFs * SCR.frameDuration;
beforeRectChooseDelay = CONF.beforeRectChooseDelayFs * SCR.frameDuration;
maskDuration = CONF.maskDurationFs * SCR.frameDuration;
prefISI = CONF.prefISIFs * SCR.frameDuration;
repetitionK = EXP.flashcardsRepetitionK;

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

% 准备图片等实验材料，设置 trial
[EXP, trialsCount, textures] = prepareMaterial(CONF, EXP, w);
Stimuli = initMask(SCR, CONF);

% 开始循环呈现 trial
Screen('DrawTexture',w,textureGray,[],[]); Screen('Flip',w);

lastOffSet = GetSecs;
C = 1;
while (C - 1 < trialsCount)

	currentNum = EXP.numberWithRepeat(C,:);

	fprintf('%-20s - %d %s Trial: Number %d, prefISI %1.0f ms, Image %s\n', '[SEEKER][PREPARE]', ...
			C, trialMark, currentNum ,prefISI * 1000, EXP.pictures{C, 3});
	
	t01 = textures{C, 1};
	t02 = textures{C, 2};

	% 先呈现 cross
	fprintf('%-20s Show Fixation Cross in %1.0f ms\n','[SEEKER][SHOW]',CONF.crossDuration * 1000);
	crossOffSet = drawFocusCross(w, lastOffSet, vblSlack, CONF.crossSize, CONF.crossDuration);
	% 循环 repetitionK 次呈现刺激
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
	% 经过 beforeMaskDelay 后呈现 mask
	Screen('FillRect', w, Stimuli.MaskRectsColor,Stimuli.MaskRects);
	Stimuli.maskOnsetReal = Screen('flip', w, t2OffsetReal + beforeMaskDelay - vblSlack);
	Stimuli.maskOffSetReal = Screen('flip', w, Stimuli.maskOnsetReal + maskDuration - vblSlack);
	Priority(0);
	% 经过 beforeRectChooseDelay 后要求被试回答
	delayOffSet = WaitSecs(beforeRectChooseDelay);
	[userAnswer, isRight, lastOffSet] = waitForRectChoose(w, delayOffSet, vblSlack,...
					currentNum, needFeedback, CONF.feedbackSecs);
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
	% 从 pics 文件夹加载图片，并且随机化，创建纹理，同时随机化 ISI，分配给 trials，
	% 将结果保存在 EXP.pictures, 返回需要下一步使用的 textures 和 trialsCount，以及更改后的 EXP
	%
	%   [ADD] EXP.pictures, EXP.isiWithRepeat, EXP.answers, EXP.actionTime，EXP.usedData

	% 获取 ISI
	if EXP.isLearn
		numberNeed = CONF.learnTakeNumberNeed;
		repeatTrial = CONF.learnRepeatTrial;
	else
		numberNeed = CONF.numberNeed;
		repeatTrial = CONF.repeatTrial;
	end
	
	% 计时标记
	time = join(string(clock),'_');
	if EXP.isSeg
		if CONF.debug, fprintf('%-20s Use Debug Mode with Seg...\n','[SEEKER][SEG][DEBUG]'); end
		EXP.segStartTime = time;
	else
		if CONF.debug, fprintf('%-20s Use Debug Mode with Int...\n','[SEEKER][INT][DEBUG]'); end
		EXP.intStartTime = time;
	end

	% 获取图片
	trialsCount = length(numberNeed) * repeatTrial;
	pictures = cell(trialsCount,3);
	data = EXP.data;
	% 对于每一个数字，构造 repeat 张图片
	pictureIndex = 1;
	for number = numberNeed
		% 先找到这个数字的图片编号
		picSNs = data(data(:,1) == -1 * number, 2); %180*1
		currentLine = data(data(:,1) == -1 * number, :); %180*66
		% 添加到所有数组共享的 pictures 数组
		for i = 1: repeatTrial
			picSN = picSNs(i);
			commonFile = sprintf("sti_%d_%d_%d_", number, CONF.cheeseRow, picSN);
			common = fullfile(CONF.picFolder, CONF.picID, commonFile);
			pictures{pictureIndex,1} = char(common + "head.png");
			pictures{pictureIndex,2} = char(common + "tail.png");
			pictures{pictureIndex,3} = char(common + "fusion.png");
			pictures{pictureIndex,4} = number;
			pictures{pictureIndex,5} = currentLine(i,:);
			pictureIndex = pictureIndex + 1;
		end
	end

	% 随机化 pictures
	pictures = Shuffle(pictures,2); %注意，必须使用 row Shuffle，否则行会乱

	% 将图片转换成为纹理
	textures = cell(trialsCount,2);
	for i = 1 : trialsCount
		pic1 = pictures{i, 1};
		textures{i,1} = MakeTexture(w, char(pic1));
		pic2 = pictures{i, 2};
		textures{i,2} = MakeTexture(w, char(pic2));
	end

	EXP.pictures = pictures;
	EXP.numberWithRepeat = cell2mat(pictures(:,4));
	EXP.answers = ones(trialsCount,1) * -1;
	EXP.userAnswers = ones(trialsCount,1) * -1;
	EXP.actionTime = ones(trialsCount,1) * -1;
	EXP.usedData = cell2mat(pictures(:,5));
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