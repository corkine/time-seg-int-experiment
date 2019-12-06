% 本脚本用来执行整个实验流程，包括刺激的生成、试次的编排、休息、指导语，变量更改如下所示：
% EXP_S, EXP_S_EX, EXP_I, EXP_I_EX
% dialogLoad
%   [ADD] CONF.seekForISI, name, gender, note, startTime
% initApplication
%   [ADD] EXP.data, SCR.debug, screenSize, EXP.isLearn, EXP.isSeg
% initScreen
%   [ADD] SCR.window, windowRect, frameDuration, vblSlack
% runISISeeker
%   [ADD] EXP.segStartTime, EXP.intStartTime
%   prepareMaterial 
%       [ADD] EXP.pictures, EXP.isiWithRepeat, EXP.answers, EXP.actionTime
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
        useSegFirst = Shuffle([0 1]);
        if useSegFirst(1) % 随机化 Seg、Int 顺序
            % 总指导语
            showIntro(SCR, CONF.ISI_INTRO, 0.5);
            % Seg - 练习
            EXP_S_EX = initCondition(SCR, EXP, CONF, true, true);
            % Seg - 正式
            EXP_S = initCondition(SCR, EXP, CONF, true, false);
            % 中间休息
            fprintf('%-20s Systen will sleep For %d secs\n', '[SLEEP]',CONF.participartRelex);
            showSleep(SCR, CONF.participartRelex, 0.5);
            % Int - 练习
            EXP_I_EX = initCondition(SCR, EXP, CONF, false, true);
            % Int - 正式
            EXP_I = initCondition(SCR, EXP, CONF, false, false);
        else
            % 总指导语
            showIntro(SCR, CONF.ISI_INTRO, 0.5);
            % Int - 练习
            EXP_I_EX = initCondition(SCR, EXP, CONF, false, true);
            % Int - 正式
            EXP_I = initCondition(SCR, EXP, CONF, false, false);
            % 中间休息
            fprintf('%-20s Systen will sleep For %d secs\n', '[SLEEP]', CONF.participartRelex);
            showSleep(SCR, CONF.participartRelex, 0.5);
            % Seg - 练习
            EXP_S_EX = initCondition(SCR, EXP, CONF, true, true);
            % Seg - 正式
            EXP_S = initCondition(SCR, EXP, CONF, true, false);
        end
    else
        % TODO 未实现
        % [SCR, EXP] = runNumSeeker(SCR, EXP, CONF);
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

closeScreen(w);

function [SCR, EXP] = initApplication(CONF)
    % 初始化应用程序，包括应用 DEBUG 模式，设置默认 EXP 值，
    % 调用 Java/MAT 文件获取图片列表对应的数据信息。
    % [ADD] EXP.data, SCR.debug, screenSize, EXP.isLearn, EXP.isSeg
    if CONF.debug
        Screen('Preference', 'SkipSyncTests', 1);
        SCR.debug = CONF.debug;
        SCR.screenSize = CONF.screenSize;
        disp("From debug_data.mat Load Test-Defined Data for use...");
        res = load(CONF.debugDataPath);
        EXP.data = res.data;
    else
        SCR.debug = false;
        SCR.screenSize = [];
        disp('Call JVM to generate Stimulate')
        if CONF.seekForISI
            target = 1;
        else
            target = CONF.numberNeed;
        end
        % TODO：删除此部分，手动调用函数完成数据获取，这里从指定文件夹 mat 文件获取信息
        % 因为每次学习/正式/Seg/Int 都使用相同的信息，因此 need 为一次最长的即可
        need = CONF.repeatTrial * length(CONF.isiNeed);
        data = initPics(CONF.picFolder, CONF.stimulateJarFile, SCR.debug, target, int32(need));
        EXP.data = data;
    end
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

function EXP_SPEC = initCondition(SCR, EXP, CONF, isSeg, isLearn)
    % 初始化指定的条件，调用 runISISeeker 显示刺激，收集数据
    if isLearn
        if isSeg
            intro = CONF.ISI_INTRO_S_EX;
            fprintf('%-20s System will First Run SegISISeeker...\n','[MAIN][SEG][LEARN]');
        else
            intro = CONF.ISI_INTRO_I_EX;
            fprintf('%-20s System will First Run IntISISeeker...\n','[MAIN][INT][LEARN]');
        end
    else
        if isSeg
            intro = CONF.ISI_INTRO_S;
            fprintf('%-20s System will First Run SegISISeeker...\n','[MAIN][SEG]');
        else
            intro = CONF.ISI_INTRO_I;
            fprintf('%-20s System will First Run IntISISeeker...\n','[MAIN][INT]');
        end
    end
    % Seg/Int 指导语 - 正式/练习
    showIntro(SCR, intro);

    % Seg/Int 实验 - 正式/练习
    EXP_SPEC = EXP;
    EXP_SPEC.isSeg = isSeg;
    EXP_SPEC.isLearn = isLearn;
    [~, EXP_SPEC] = runISISeeker(SCR, EXP_SPEC, CONF);
end