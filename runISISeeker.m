function [SCR, EXP] = runISISeeker(SCR, EXP, CONF, w, isSeg, isFirst)
% RUNISISEEKER 寻找最佳 ISI 的实验 Trial 序列，传入参数 w 为 Window PTR，
% isSeg 表明当前 Seeker 是否是寻找 Seg 的（或者是寻找 Int 的）。isFirst 表明
% 当前 Seeker 首先呈现，意味着在此 Seeker 之后需要休息。

    % 准备图片等实验材料，设置 trial
    [EXP, trialsCount, textures] = prepareMaterial(CONF, w, isSeg);

    % 准备一些可复用的变量和 PTB 材料
    vblSlack = SCR.vblSlack;
	t_gray = MakeTexture(w, CONF.GRAY_IMAGE);
    duration = CONF.stimulateDuration;
    if isSeg
        trialMark = 'SEG';
    else
        trialMark = 'INT';
    end
    Screen('DrawTexture',w,t_gray,[],[]); Screen('Flip',w);

    % 总的指导语

    % 开始循环呈现 trial
    lastOffSet = GetSecs;	
	K = 1;
    while (K - 1 < trialsCount)

        thisTrialISI = EXP.isiWithRepeat(K);

        fprintf('Trial[%s] - %d with ISI %4.0f ms and Image %s\n', ...
                trialMark, K, thisTrialISI * 1000, EXP.pictures{K, 3});
        
        t01 = textures{K, 1};
        t02 = textures{K, 2};

        crossOffSet = drawFocusCross(w, lastOffSet, vblSlack, ...
                                    CONF.crossSize, CONF.crossDuration);

        t1OffSet = drawImage(w, crossOffSet, vblSlack, t01, duration);
        waitOffSet = drawImage(w, t1OffSet, vblSlack, t_gray, thisTrialISI);
        lastOffSet = drawImage(w, waitOffSet, vblSlack, t02, duration);

        % TODO 添加被试选择和数据收集
        K = K + 1;
    end
end

function t = MakeTexture(w, pictureName)
    img = imread(pictureName);
    t = Screen('MakeTexture',w,img);  
end

function [EXP, trialsCount, textures] = prepareMaterial(CONF, w, isSeg)
    % 从 pics 文件夹加载图片，并且随机化，创建纹理，同时随机化 ISI，分配给 trials，
    % 将结果保存在 EXP.pictures, isiWithRepeat 中，返回需要下一步使用的 textures 
    % 和 trialsCount，以及更改后的 EXP

    % 计时标记
    time = join(string(clock),'_');
    if isSeg
        if CONF.debug, fprintf('Use Debug Mode with Seg...\n'); end
        EXP.segStartTime = time;
    else
        if CONF.debug, fprintf('Use Debug Mode with Int...\n'); end
        EXP.intStartTime = time;
    end

    % 获取图片
    trialsCount = length(CONF.isiNeed) * CONF.repeatTrial;
    pictures = cell(trialsCount,3);
    for i = 1: trialsCount
        commonFile = sprintf("sti_%d_%d_%d_", 1, CONF.cheeseRow, i);
        common = fullfile(CONF.picFolder, commonFile);
        pictures{i,1} = char(common + "head.png");
        pictures{i,2} = char(common + "tail.png");
        pictures{i,3} = char(common + "fusion.png");
    end

    % 分配 ISI 到每张图片，并且随机化
    isis = repmat(CONF.isiNeed, 1, CONF.repeatTrial)';
    isiWithRepeat = Shuffle(isis);

    % 随机化图片顺序（图片随机，本质上没有必要）
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
    EXP.isiWithRepeat = isiWithRepeat;
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