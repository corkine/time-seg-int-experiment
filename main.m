% 本脚本用来执行整个实验流程，包括刺激的生成、试次的编排、休息、指导语，变量更改如下所示：
% EXP_S, EXP_S_EX, EXP_I, EXP_I_EX
% dialogLoad
%   [ADD] CONF.seekForISI, name, gender, note, startTime, prefISI
% initApplication
%   [ADD] EXP.data, SCR.debug, screenSize, EXP.isLearn, EXP.isSeg
% initScreen
%   [ADD] SCR.window, windowRect, frameDuration, vblSlack
% runISISeeker
%   [ADD] EXP.segStartTime, EXP.intStartTime
%   prepareMaterial 
%       [ADD] EXP.pictures, EXP.isiWithRepeat, EXP.answers, EXP.actionTime, EXP.usedData
%
%  请勿直接调用 Psy4J.jar 生成图片，通过此函数调用的 Psy4J.jar 会将结果保存到 debug_data.mat 中
%  以备 debug 模式使用。此数据和图片顺序对应，包含了图片中的点阵关键信息。

CONF = configLoad();
CONF = dialogLoad(CONF);
[SCR, EXP] = initApplication(CONF); 
SCR = initScreen(SCR);

try
    % [SCR, EXP] = runTest(SCR, EXP, CONF, w);
    if CONF.seekForISI
        totalIntro = CONF.ISI_INTRO;
    else
        totalIntro = CONF.NUM_INTRO;
    end
    useSegFirst = Shuffle([0 1]);
    if useSegFirst(1) % 随机化 Seg、Int 顺序
        % 总指导语
        showIntro(SCR, totalIntro, 0.5);
        % Seg - 练习
        EXP_S_EX = initConditionWithTry(SCR, EXP, CONF, true, true);
        % Seg - 正式
        EXP_S = initCondition(SCR, EXP, CONF, true, false);
        % 中间休息
        fprintf('%-20s Systen will sleep For %d secs\n', '[SLEEP]',CONF.participartRelex);
        showSleep(SCR, CONF.participartRelex, 0.5);
        % Int - 练习
        EXP_I_EX = initConditionWithTry(SCR, EXP, CONF, false, true);
        % Int - 正式
        EXP_I = initCondition(SCR, EXP, CONF, false, false);
    else
        % 总指导语
        showIntro(SCR, totalIntro, 0.5);
        % Int - 练习
        EXP_I_EX = initConditionWithTry(SCR, EXP, CONF, false, true);
        % Int - 正式
        EXP_I = initCondition(SCR, EXP, CONF, false, false);
        % 中间休息
        fprintf('%-20s Systen will sleep For %d secs\n', '[SLEEP]', CONF.participartRelex);
        showSleep(SCR, CONF.participartRelex, 0.5);
        % Seg - 练习
        EXP_S_EX = initConditionWithTry(SCR, EXP, CONF, true, true);
        % Seg - 正式
        EXP_S = initCondition(SCR, EXP, CONF, true, false);
    end
    
    % 保存所有数据
    DATA.segData = EXP_S;
    DATA.intData = EXP_I;
    DATA.scrInfo = SCR;
    DATA.conf = CONF;
    fileName = sprintf('%s@%s.mat',CONF.name, CONF.startTime);
    save(fileName,'DATA');

catch exception
    disp("Run PTB Error: " + string(exception.message) + ...
    ", For more info, check exception variable");
end

closeScreen(SCR.window);

function [SCR, EXP] = initApplication(CONF)
    % 初始化应用程序，包括应用 DEBUG 模式，设置默认 EXP 值，
    % 调用 Java/MAT 文件获取图片列表对应的数据信息。
    % [ADD] EXP.data, SCR.debug, screenSize, EXP.isLearn, EXP.isSeg
    if CONF.debug
        Screen('Preference', 'SkipSyncTests', 1);
        SCR.debug = CONF.debug;
        SCR.screenSize = CONF.screenSize;
    else
        Screen('Preference', 'SkipSyncTests', 1);
        SCR.debug = false;
        SCR.screenSize = [];
    end
    fprintf('%-20s Load Data from %s/%s\n','[MAIN]',CONF.picID, 'data.mat');
    res = load(fullfile('pics',CONF.picID,'data.mat'));
    EXP.data = res.data;
    EXP.isSeg = false;
    EXP.isLearn = false;
end

function SCR = initScreen(SCR)
    % 初始化 Screen 和 PTB 句柄
    % [ADD] SCR.window, windowRect, frameDuration, vblSlack
    %初始化 Screen
    if isempty(SCR.screenSize)
        Screen('Preference', 'SkipSyncTests', 1);
        [w,rect]= Screen('OpenWindow',0,[128 128 128]); 
    else
        [w,rect]= Screen('OpenWindow',0,[128 128 128],SCR.screenSize); 
    end
    SCR.window = w;
    SCR.windowRect = rect;
    SCR.frameDuration = Screen('GetFlipInterval',w); 
    SCR.vblSlack = SCR.frameDuration / 2;   
    HideCursor;
    Priority(2); % request the maximum amount of CPU time
end

function closeScreen(w)
    % 关闭和清理 PTB 句柄
    Priority(0);
    Screen('Close',w); 
    Screen('CloseAll'); 
    ShowCursor;
end

function showIntro(SCR, introImage, withDelay)
    % 显示指导语界面
    w = SCR.window;
    fprintf('%-20s Showing Intro %s now...\n', '[INTRO]',introImage);
    img = imread(introImage);
    t = Screen('MakeTexture',w,img); 
    Screen('DrawTexture',w,t,[],[]); 
    Screen('Flip', w);
    space = KbName('space');
    while true
        [~, ~, keycode] = KbCheck();
        if keycode(space), break; end
        WaitSecs(0.1);
    end
    Screen('Flip', w);
    if nargin == 3
        WaitSecs(withDelay);
    end
end

function showSleep(SCR, sleepMinSecs, withDelay)
    % 显示休息界面
    w = SCR.window;
    text = sprintf('Please Relex for min %d secs, Counting...', sleepMinSecs);
    DrawFormattedText(w, text, 'center', 'center', [0 0 0]);
    Screen('Flip',w);
    WaitSecs(sleepMinSecs);
    Screen('Flip',w);
    space = KbName('space');
    DrawFormattedText(w, 'Press Space to Continue', 'center', 'center', [0 0 0]);
    Screen('Flip',w);
    while true
        [~, ~, keycode] = KbCheck();
        if keycode(space), break; end
        WaitSecs(0.1);
    end
    Screen('Flip', w);
    if nargin == 3
        WaitSecs(withDelay);
    end
end

function showAcc(SCR, CONF, currentP, withDelay)
    % 显示正确率信息
    w = SCR.window;
    Screen('Flip',w);
    needP = CONF.minCurrent;
    accText = sprintf('Your Accuracy is %2.2f%% < %2.2f%%\nPress the space bar to try again', ...
                    currentP * 100, needP * 100);
    DrawFormattedText(w, char(accText), 'center', 'center', [0 0 0]); 
    Screen('Flip',w);
    space = KbName('space');
    while true
        [~, ~, keycode] = KbCheck();
        if keycode(space), break; end
        WaitSecs(0.1);
    end
    Screen('Flip', w);
    if nargin == 4
        WaitSecs(withDelay);
    end
end

function EXP_SPEC = initConditionWithTry(SCR, EXP, CONF, isSeg, isLearn)
    % 执行 initCondition，根据正确率判断，如果不通过，则无限重试。
    if CONF.useUnlimitLearn
        while true
            EXP_SPEC = initCondition(SCR, EXP, CONF, isSeg, isLearn);
            a = EXP_SPEC.answers;
            acc = length(a(a(:,1) == 1)) / length(a);
            if acc >= CONF.minCurrent
                fprintf('%-20s ACC is %2.2f...\n', '[MAIN][SEG][LEARN]', acc);
                break;
            else
                fprintf('%-20s Retry Learn again...\n', '[MAIN][SEG][LEARN]');
                showAcc(SCR, CONF, acc, 0.5);
            end
        end
    else
        EXP_SPEC = initCondition(SCR, EXP, CONF, isSeg, isLearn);
    end
end

function EXP_SPEC = initCondition(SCR, EXP, CONF, isSeg, isLearn)
    % 初始化指定的条件，调用 runISISeeker 显示刺激，收集数据
    if isLearn
        if isSeg
            if CONF.seekForISI
                intro = CONF.ISI_INTRO_S_EX;
            else
                intro = CONF.NUM_INTRO_S_EX;
            end
            fprintf('%-20s System will First Run SegISISeeker...\n','[MAIN][SEG][LEARN]');
        else
            if CONF.seekForISI
                intro = CONF.ISI_INTRO_I_EX;
            else
                intro = CONF.NUM_INTRO_I_EX;
            end
            fprintf('%-20s System will First Run IntISISeeker...\n','[MAIN][INT][LEARN]');
        end
    else
        if isSeg
            if CONF.seekForISI
                intro = CONF.ISI_INTRO_S;
            else
                intro = CONF.NUM_INTRO_S;
            end
            fprintf('%-20s System will First Run SegISISeeker...\n','[MAIN][SEG]');
        else
            if CONF.seekForISI
                intro = CONF.ISI_INTRO_I;
            else
                intro = CONF.NUM_INTRO_I;
            end
            fprintf('%-20s System will First Run IntISISeeker...\n','[MAIN][INT]');
        end
    end
    % Seg/Int 指导语 - 正式/练习
    showIntro(SCR, intro);

    % Seg/Int 实验 - 正式/练习
    EXP_SPEC = EXP;
    EXP_SPEC.isSeg = isSeg;
    EXP_SPEC.isLearn = isLearn;
    if CONF.seekForISI
        [~, EXP_SPEC] = runISISeeker(SCR, EXP_SPEC, CONF);
    else 
        [~, EXP_SPEC] = runNumSeeker(SCR, EXP_SPEC, CONF);
    end
end