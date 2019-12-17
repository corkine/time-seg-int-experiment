function [SCR, EXP] = runISISeeker(SCR, EXP, CONF)
% RUNISISEEKER 寻找最佳 ISI 的实验 Trial 序列，传入参数 w 为 Window PTR，
% isSeg 表明当前 Seeker 是否是寻找 Seg 的（或者是寻找 Int 的）。isFirst 表明
% 当前 Seeker 首先呈现，意味着在此 Seeker 之后需要休息。
%
%   [ADD] EXP.segStartTime, EXP.intStartTime, EXP.isiNeed, EXP.learnTaskIsiNeed
%   prepareMaterial [ADD] EXP.pictures, EXP.isiWithRepeat, EXP.answers, EXP.actionTime,EXP.usedData

    % 准备一些可复用的变量和 PTB 材料
    w = SCR.window;
    vblSlack = SCR.vblSlack;
	textureGray = MakeTexture(w, CONF.GRAY_IMAGE);
    % duration = CONF.stimulateDuration;
    duration = CONF.stimulateDurationFs * SCR.frameDuration;
    % flashcardsRepetitionK = CONF.flashcardsRepetitionK;
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

    % 开始循环呈现 trial
    Screen('DrawTexture',w,textureGray,[],[]); Screen('Flip',w);
    
    lastOffSet = GetSecs;	
	K = 1;
    while (K - 1 < trialsCount)

        thisTrialISI = EXP.isiWithRepeat(K);

        fprintf('%-20s Trial[%s] - %d with ISI %4.0f ms and Image %s\n', '[SEEKER][SHOW]', ...
                trialMark, K, thisTrialISI * 1000, EXP.pictures{K, 3});
        
        t01 = textures{K, 1};
        t02 = textures{K, 2};

        crossOffSet = drawFocusCross(w, lastOffSet, vblSlack, ...
                                    CONF.crossSize, CONF.crossDuration);
        fprintf('%-20s Show First Image in %1.0f ms\n','[SEEKER][SHOW]',duration * 1000);
        t1OffSet = drawImage(w, crossOffSet, vblSlack, t01, duration);
        fprintf('%-20s Show ISI in %1.0f ms\n','[SEEKER][SHOW]',thisTrialISI * 1000);
        waitOffSet = drawImage(w, t1OffSet, vblSlack, textureGray, thisTrialISI);
        fprintf('%-20s Show Last Image in %1.0f ms\n','[SEEKER][SHOW]',duration * 1000);
        t2OffSet = drawImage(w, waitOffSet, vblSlack, t02, duration);

        currentSti = EXP.usedData(K,:); %66列1行
        % 因为第一列为数字，第二列为编号，因此从第三列开始，找到的数字应该 - 2 
        if isSeg
            findAns = find(currentSti == 1);
            rightNum = findAns(1) - 2;
        else 
            findAns = find(currentSti == 2);
            rightNum = findAns(1) - 2;
        end
        [~, isRight, lastOffSet] = waitForRectChoose(w, t2OffSet, vblSlack, CONF.cheeseRow, CONF.cheeseGridWidth,...
                                    rightNum, needFeedback, CONF.feedbackSecs);
        EXP.answers(K) = isRight;
        EXP.actionTime(K) = lastOffSet - t2OffSet;
        K = K + 1;
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
    trialsCount = length(isiNeed) * repeatTrial;
    pictures = cell(trialsCount,3);
    data = EXP.data;
    picIds = data(data(:,1) == -1,2);
    for i = 1: trialsCount
        picId = picIds(i);
        commonFile = sprintf("sti_%d_%d_%d_", 1, CONF.cheeseRow, picId);
        common = fullfile(CONF.picFolder, CONF.picID, commonFile);
        pictures{i,1} = char(common + "head.png");
        pictures{i,2} = char(common + "tail.png");
        pictures{i,3} = char(common + "fusion.png");
    end

    % 分配 ISI 到每张图片，并且随机化
    isis = repmat(isiNeed, 1, repeatTrial)';
    isiWithRepeat = Shuffle(isis); %n*1 因此 Shuffle 没有问题

    % 将图片转换成为纹理
    textures = cell(trialsCount,2);
    for i = 1 : trialsCount
        pic1 = pictures{i, 1};
        textures{i,1} = MakeTexture(w, char(pic1));
        pic2 = pictures{i, 2};
        textures{i,2} = MakeTexture(w, char(pic2));
    end

    EXP.pictures = pictures;
    EXP.isiWithRepeat = isiWithRepeat;
    EXP.answers = ones(trialsCount,1) * -1;
    EXP.actionTime = ones(trialsCount,1) * -1;
    EXP.usedData = data(data(:,1) == -1, :);
end

function this_offset = drawFocusCross(w, last_offset, vblSlack, fontSize, showTime)
    Screen('TextStyle', w, 0);
    Screen('TextSize', w, fontSize);
    DrawFormattedText(w, '+', 'center','center',[255 0 0]);
    this_onset_real = Screen('Flip', w, last_offset - vblSlack);
    this_offset = this_onset_real + showTime;
end

function this_offset = drawImage(w, last_offset, vblSlack, texture, showTime)
    Screen('DrawTexture',w,texture,[],[]);        
    this_onset_real = Screen('Flip', w, last_offset - vblSlack);   
    this_offset = this_onset_real + showTime;
end

function [rowNumber, isRight, lastOffSet] = waitForRectChoose(w, last_offset, vblSlack, row, width, rightAnswer, needFeedback, feedBackDelaySecs)
    Screen('Flip', w, last_offset - vblSlack);
    ShowCursor;
    cellRects = ArrangeRects(row * row, [0 0 width width],[0 0 width * row, width * row]);
    [wx, wy] = WindowCenter(w);
    offx = wx - width * row / 2;
    offy = wy - width * row / 2;
    cellRects2 = OffsetRect(cellRects, offx, offy);
    rects = cellRects2'; %每列从上到下 x1,y1,x2,y2;

    while true
        [x, y, btns] = GetMouse;
        choosedRect = [];
        for i = 1:length(cellRects2)
            currentRect = cellRects2(i,:);
            if IsInRect(x, y, currentRect)
                Screen('FillRect',w, [0 255 0], currentRect);
                choosedRect = currentRect;
            end
        end
        Screen('FrameRect', w, [0 0 0], rects);
        Screen('Flip',w);
        WaitSecs(0.03);
        if btns(1) && ~isempty(choosedRect)
            fprintf('%-20s Checked Choose Result %d %d %d %d\n','[SEEKER][SELECT]',...
                     choosedRect(1,1), choosedRect(1,2),choosedRect(1,3), choosedRect(1,4));
            break;
        end
    end
    Screen('Flip',w);
    HideCursor;

    [~, rowNumber] = ismember(choosedRect, cellRects2, 'rows');

    fprintf('%-20s RowNumber Choosed is %d, RightNumber is %d, answer Right? %d\n',...
            '[SEEKER][SELECT]', rowNumber, rightAnswer, rowNumber == rightAnswer);

    if rowNumber == rightAnswer
        isRight = 1;
        if needFeedback
            DrawFormattedText(w,'Right Answer!','center','center',[0 0 0]);
            Screen('Flip',w);
            WaitSecs(feedBackDelaySecs);
        end
    else
        isRight = 0;
        if needFeedback
            DrawFormattedText(w,'Wrong Answer!','center','center',[255 0 0]);
            Screen('Flip',w);
            WaitSecs(feedBackDelaySecs);
        end
    end
    lastOffSet = Screen('Flip',w);
end