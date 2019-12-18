function [SCR, EXP] = runNumSeeker(SCR, EXP, CONF)
% RUNNUMSEEKER 寻找最佳 NUM 的实验 Trial 序列，传入参数 w 为 Window PTR，
%
%   [ADD] EXP.segStartTime, EXP.intStartTime, Stimuli.maskOnsetReal, Stimuli.maskOffSetReal
%   prepareMaterial 
% 		[ADD] EXP.pictures, EXP.numberWithRepeat, EXP.answers, EXP.actionTime, 
% 			  EXP.usedData, EXP.numberWithRepeat, EXP.userAnswers, EXP.totalStiShowTime

% 准备一些可复用的变量和 PTB 材料
w = SCR.window;
vblSlack = SCR.vblSlack;
textureGray = MakeTexture(w, CONF.GRAY_IMAGE);
duration = CONF.stimulateDurationFs * SCR.frameDuration;
beforeMaskDelay = CONF.beforeMaskDelayFs * SCR.frameDuration;
maskDuration = CONF.MaskDurationFs * SCR.frameDuration;
% TODO: 更改 prefISI 的来源，由输入定义
prefISI = CONF.prefISIFs * SCR.frameDuration;
repetitionK = CONF.flashcardsRepetitionK;

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
Stimuli = maskCalculation(SCR);

% 开始循环呈现 trial
Screen('DrawTexture',w,textureGray,[],[]); Screen('Flip',w);

lastOffSet = GetSecs;	
C = 1;
while (C - 1 < trialsCount)

	currentNum = EXP.numberWithRepeat(C,:);

	fprintf('%-20s Trial[%s] - %d with Number %d, prefISI %4.0f ms and Image %s\n', '[SEEKER][SHOW]', ...
			trialMark, C, currentNum ,prefISI * 1000, EXP.pictures{C, 3});
	
	t01 = textures{C, 1};
	t02 = textures{C, 2};

	% 先呈现 cross
	fprintf('%-20s Show Fixation Cross in %1.0f ms\n','[SEEKER][SHOW]',CONF.crossDuration * 1000);
	crossOffSet = drawFocusCross(w, lastOffSet, vblSlack, CONF.crossSize, CONF.crossDuration);
	Priority(2);
	K = 0; 
	lastOffSetInner = crossOffSet;
	% 再呈现刺激
	while K < repetitionK
		fprintf('%-20s Show First Image in %1.0f ms\n','[SEEKER][SHOW]',duration * 1000);
		[t1OffSet, t1OnsetReal] = drawImage(w, lastOffSetInner, vblSlack, t01, duration);
		fprintf('%-20s Show ISI1 in %1.0f ms\n','[SEEKER][SHOW]',prefISI * 1000);
		waitOffSet = drawImage(w, t1OffSet, vblSlack, textureGray, prefISI);
		fprintf('%-20s Show Last Image in %1.0f ms\n','[SEEKER][SHOW]',duration * 1000);
		t2OffSet = drawImage(w, waitOffSet, vblSlack, t02, duration);
		fprintf('%-20s Show ISI2 in %1.0f ms\n','[SEEKER][SHOW]',prefISI * 1000);
		[lastOffSetInner, t2OffsetReal] = drawImage(w, t2OffSet, vblSlack, textureGray, prefISI);
		if K == 0, stimuliOnset = t1OnsetReal; end
		K = K + 1;
	end
	% 再呈现 mask //TODO 优化代码
	Screen('FillRect', w, Stimuli.MaskRectsColor,Stimuli.MaskRects);
	Stimuli.maskOnsetReal = Screen('flip', w, t2OffsetReal + beforeMaskDelay - vblSlack);
	Stimuli.maskOffSetReal = Screen('flip', w, Stimuli.maskOnsetReal + maskDuration - vblSlack);
	Priority(0);
	% 经过一个延时
	delayOffSet = WaitSecs(CONF.beforeRectChooseDelay);
	% 要求被试回答
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
	% 将结果保存在 EXP.pictures, isiWithRepeat 中，返回需要下一步使用的 textures 
	% 和 trialsCount，以及更改后的 EXP
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

	fprintf('%-20s Get Response %d [Right is %d] and is Right? %d!\n', '[MAIN][RESPONSE]',...
			response, rightAnswer, answerRight);
end

function R = CombineFactors(varargin)
	tmpNum = 1;
	for i=1:length(varargin)
		tmpNum = tmpNum*length(varargin{i});
	end
	R = zeros(tmpNum,length(varargin));
	for i = 1:size(R,1)
		tmp = tmpNum;
		for j = 1:length(varargin)
			if j~=1
				tmp = tmp/length(varargin{j-1});
			end
			for k = 1:length(varargin{j})
				R(i,j)=varargin{j}(ceil((mod(i-1,tmp)+1)/(tmp/length(varargin{j}))));
			end
		end
	end
end


function [Stimuli] = maskCalculation(SCR)
	Stimuli.ObjAreaSizeP = 600;
	Stimuli.MaskRectSizeP = 12;

	%% masks 
	%此处mask暂时是大小相同、颜色随机的颜色方块
	% loc  
	Stimuli.MaskRectNum = ceil(Stimuli.ObjAreaSizeP/Stimuli.MaskRectSizeP); % num = length/size
	Stimuli.PointMetrix = CombineFactors(0:Stimuli.MaskRectNum-1,0:Stimuli.MaskRectNum-1);   % mask中每个小方块都归属于某一列（同列的x坐标相同），然后再归属于某一行（同行的y坐标相同）！
	Stimuli.referencePoint = [SCR.x - Stimuli.ObjAreaSizeP/2, SCR.y - Stimuli.ObjAreaSizeP/2];%左上角顶点坐标
	LeftUpPoints(:,1) = Stimuli.PointMetrix(:,1) * Stimuli.MaskRectSizeP+Stimuli.referencePoint(1,1);%所有rect的左上角坐标
	LeftUpPoints(:,2) = Stimuli.PointMetrix(:,2) * Stimuli.MaskRectSizeP+Stimuli.referencePoint(1,2);
	RightBotomPoints(:,1) = LeftUpPoints(:,1) + Stimuli.MaskRectSizeP;%所有rect右下角坐标
	RightBotomPoints(:,2) = LeftUpPoints(:,2) + Stimuli.MaskRectSizeP;
	Stimuli.MaskRects = [LeftUpPoints,RightBotomPoints];
	Stimuli.MaskRects = Stimuli.MaskRects';
	%color
	Stimuli.PointMetrixSize = size(Stimuli.MaskRects);
	rectsNum = Stimuli.PointMetrixSize(2);
	Stimuli.MaskRectsColor = ones(3,rectsNum);

	for rowindex = 1:rectsNum
		tmp1=randperm(2); %随机掷黑白-黑白Mask
		if tmp1(1)==1, Stimuli.MaskRectsColor(:,rowindex)=0;   end
		if tmp1(1)==2, Stimuli.MaskRectsColor(:,rowindex)=255; end
	end
	
end