function [SCR, EXP] = runISISeeker(SCR, EXP, CONF)
% RUNISISEEKER 寻找最佳 ISI 的实验 Trial 序列
%
%   [ADD] EXP.segStartTime, EXP.intStartTime, EXP.isiNeed, EXP.learnTaskIsiNeed, 
%   Stimuli.maskOnsetReal, Stimuli.maskOffSetReal
%   prepareMaterial 
%       [ADD] EXP.pictures, EXP.isiWithRepeat, EXP.answers, EXP.actionTime, 
%             EXP.usedData, EXP.totalStiShowTime

% 准备一些可复用的变量和 PTB 材料
w = SCR.window;
vblSlack = SCR.vblSlack;
textureGray = MakeTexture(w, CONF.GRAY_IMAGE);
duration = CONF.stimulateDurationFs * SCR.frameDuration;
beforeMaskDelay = CONF.beforeMaskDelayFs * SCR.frameDuration;
beforeRectChooseDelay = CONF.beforeRectChooseDelayFs * SCR.frameDuration;
maskDuration = CONF.maskDurationFs * SCR.frameDuration;
repetitionK = EXP.flashcardsRepetitionK;

EXP.isiNeed = CONF.isiNeedFs * SCR.frameDuration;
EXP.learnTakeIsiNeed = CONF.learnTakeIsiNeedFs * SCR.frameDuration;

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

    thisTrialISI = EXP.isiWithRepeat(C);
    currentNum = EXP.pictures(C,4);

    fprintf('%-20s - %d %s Trial: ISI %1.0f ms and Image %s\n', '[SEEKER][PREPARE]', ...
            C, trialMark, thisTrialISI * 1000, EXP.pictures{C, 3});
    
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
            '[SEEKER][SHOW]',duration * 1000, thisTrialISI * 1000, duration * 1000, repetitionK);
    while K < repetitionK
        [t1OffSet, t1OnsetReal] = drawImage(w, lastOffSetInner, vblSlack, t01, duration);
        waitOffSet = drawImage(w, t1OffSet, vblSlack, textureGray, thisTrialISI);
        t2OffSet = drawImage(w, waitOffSet, vblSlack, t02, duration);
        [lastOffSetInner, t2OffsetReal] = drawImage(w, t2OffSet, vblSlack, textureGray, thisTrialISI);
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
    [isRight, lastOffSet] = waitForRectChoose(w, delayOffSet, vblSlack, currentNum, needFeedback, CONF.feedbackSecs);
    EXP.answers(C) = isRight;
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
        isiNeed = EXP.learnTakeIsiNeed;
        repeatTrial = CONF.learnRepeatTrial;
    else
        isiNeed = EXP.isiNeed;
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
    singleTrialsCount = length(isiNeed) * repeatTrial; % 0 和 1 每一个数值的 Trial 数
    trialsCount = singleTrialsCount * 2; % 一共的 Trial 数
    pictures = cell(trialsCount,3);
    data = EXP.data;
    % 最终构造的包含 number 数字的重复 repeatTrial 次的 pictures Cell 的索引
    pictureIndex = 1;
    for number = [0 1]
        % 先获取对应图片的所有可用数据
        picSNs = data(data(:,1) == -1 * number, 2); %180*1
        currentLine = data(data(:,1) == -1 * number, :); %180*66
        for i = 1 : repeatTrial
            for isi = isiNeed
                % 再从中获取 repeatTrial 行图片
                picSN = picSNs(i);
                commonFile = sprintf("sti_%d_%d_%d_", number, CONF.cheeseRow, picSN);
                common = fullfile(CONF.picFolder, CONF.picID, commonFile);
                pictures{pictureIndex,1} = char(common + "head.png");
                pictures{pictureIndex,2} = char(common + "tail.png");
                pictures{pictureIndex,3} = char(common + "fusion.png");
                pictures{pictureIndex,4} = number;
                pictures{pictureIndex,5} = isi;
                pictures{pictureIndex,6} = currentLine(i,:);
                pictureIndex = pictureIndex + 1;
            end
        end
    end

    % 随机化 pictures
    pictures = Shuffle(pictures,2);

    % 将图片转换成为纹理
    textures = cell(trialsCount,2);
    for i = 1 : trialsCount
        pic1 = pictures{i, 1};
        textures{i,1} = MakeTexture(w, char(pic1));
        pic2 = pictures{i, 2};
        textures{i,2} = MakeTexture(w, char(pic2));
    end

    EXP.pictures = pictures;
    EXP.isiWithRepeat = cell2mat(pictures(:,5));
    EXP.answers = ones(trialsCount,1) * -1;
    EXP.actionTime = ones(trialsCount,1) * -1;
    EXP.usedData = cell2mat(pictures(:,6));
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

function [answerRight, lastOffSet] = waitForRectChoose(w, last_offset, vblSlack, rightAnswer, needFeedback, feedBackDelaySecs)
    ListenChar(2);
	Screen('Flip', w, last_offset - vblSlack);

	answer = Ask(w, 'How much target do you find, 0 or 1? ',0, 128, 'GetChar',[],'center');
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