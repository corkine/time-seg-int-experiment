% 本脚本用来执行整个实验流程，包括刺激的生成、试次的编排、休息、指导语，变量更改如下所示：
% dialogLoad
%   [ADD] CONF.seekForISI, name, gender, note, startTime
% initApplication
%   [ADD] EXP.data, SCR.debug, screenSize
% initScreen
%   [ADD] SCR.window, windowRect, frameDuration, vblSlack
% runISISeeker
%   [ADD] EXP.segStartTime, EXP.intStartTime
%   prepareMaterial 
%       [ADD] EXP.pictures, EXP.isiWithRepeat

CONF = configLoad();
CONF = dialogLoad(CONF);
[SCR, EXP] = initApplication(CONF); 
SCR = initScreen(SCR);

try
    % [SCR, EXP] = runTest(SCR, EXP, CONF, w);
    if CONF.seekForISI
        useSegFirst = Shuffle([0 1]);
        if useSegFirst(1)
            % 总指导语
            showIntro(SCR, CONF.ISI_INTRO, 0.5);
            % Seg 指导语
            fprintf('System will First Run SegISISeeker...\n');
            showIntro(SCR, CONF.ISI_INTRO_S);
            % Seg 实验
            [SCR, EXP] = runISISeeker(SCR, EXP, CONF, true);
            % 中间休息
            fprintf('Systen will sleep For %d secs', CONF.participartRelex);
            showSleep(SCR, CONF.participartRelex, 0.5);
            % Int 指导语
            fprintf('System will Run IntISISeeker...\n');
            showIntro(SCR, CONF.ISI_INTRO_I);
            % Int 实验
            [SCR, EXP] = runISISeeker(SCR, EXP, CONF, false);
        else
            % 总指导语
            showIntro(SCR, CONF.ISI_INTRO, 0.5);
            % Int 指导语
            fprintf('System will First Run IntISISeeker...\n');
            showIntro(SCR, CONF.ISI_INTRO_I);
            % Int 实验
            [SCR, EXP] = runISISeeker(SCR, EXP, CONF, false);
            % 中间休息
            fprintf('Systen will sleep For %d secs', CONF.participartRelex);
            showSleep(SCR, CONF.participartRelex, 0.5);
            % Seg 指导语
            fprintf('System will Run SegISISeeker...\n');
            showIntro(SCR, CONF.ISI_INTRO_S);
            % Seg 实验
            [SCR, EXP] = runISISeeker(SCR, EXP, CONF, true);
        end
    else
        % TODO 未实现
        [SCR, EXP] = runNumSeeker(SCR, EXP, CONF);
    end
catch exception
    disp("Run PTB Error: " + string(exception.message) + ...
    ", For more info, check exception variable");
end

closeScreen(w);

function [SCR, EXP] = initApplication(CONF)
    % [ADD] EXP.data, SCR.debug, screenSize
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
        data = initPics(CONF.picFolder, CONF.stimulateJarPath, SCR.debug, 6, 100);
        EXP.data = data;
    end
end

function SCR = initScreen(SCR)
    % [ADD] SCR.window, windowRect, frameDuration, vblSlack
    %初始化 Screen
    [w,rect]= Screen('OpenWindow',0,[128 128 128],SCR.screenSize); 
    SCR.window = w;
    SCR.windowRect = rect;
    SCR.frameDuration = Screen('GetFlipInterval',w); 
    SCR.vblSlack = SCR.frameDuration / 2;   
    HideCursor;
    Priority(2); % request the maximum amount of CPU time
end

function closeScreen(w)
    Priority(0);
    Screen('Close',w); 
    Screen('CloseAll'); 
    ShowCursor;
end

function showIntro(SCR, introImage, withDelay)
    w = SCR.window;
    fprintf('Showing Intro %s now...', introImage);
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
    w = SCR.window;
    fprintf('Sleeping now...');
    text = sprintf('Please Relex for min %d secs, Counting...', sleepMinSecs);
    DrawFormattedText(w, text, 'center', 'center');
    Screen('Flip',w);
    WaitSecs(sleepMinSecs);
    Screen('Flip',w);
    space = KbName('space');
    DrawFormattedText(w, 'Press Space to Continue', 'center', 'center');
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