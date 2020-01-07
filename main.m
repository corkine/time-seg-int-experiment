% 本脚本用来执行整个实验流程，包括刺激的生成、试次的编排、休息、指导语：
% 数据结构如下所示：
%   DATA 保存所有数据 -- seg、intData 保存 Seg、Int 数据 -- k{n} 保存 k 在某一个水平下数据 -- 
%   EXP 某一个 k 水平下不同操纵自变量的数据，对于 seekISI 而言，是 isi，对于 seekNum 而言，是 num
% 变量更改如下所示：
%   seg/intData.k{n}, EXP.usedK, 仅在 seekForNum 条件下注入：EXP.prefISI 和 EXP.prefISIFs
%   dexpLoad
%       [ADD] prefISI、startTime、seekForISI、name、gender、note、picId
%   initApplication
%       [ADD] EXP.data, SCR.debug, screenSize, EXP.isLearn, EXP.isSeg
%   initScreen
%       [ADD] SCR.window, windowRect, frameDuration, vblSlack, x, y  
%   runISISeeker
%       [ADD] EXP.segStartTime, EXP.intStartTime
%       prepareMaterial 
%           [ADD] EXP.pictures, EXP.isiWithRepeat, EXP.answers, EXP.actionTime, EXP.usedData, EXP.numberWithRepeat[, EXP.userAnswers]
%
%  请勿直接调用 Psy4J.jar 生成图片，通过此函数调用的 Psy4J.jar 会将结果保存到 debug_data.mat 中
%  以备 debug 模式使用。此数据和图片顺序对应，包含了图片中的点阵关键信息。

CONF = configLoad();
EXP = struct();
EXP = expLoad(CONF, EXP);
[SCR, EXP] = initApplication(CONF, EXP); 
SCR = initScreen(SCR);
if ~EXP.seekForISI
    EXP = computePrefIsiFs(SCR, EXP);
else 
    EXP = rmfield(EXP,'prefISI');
end

try
    if EXP.seekForISI
        totalIntro = CONF.ISI_INTRO;
    else
        totalIntro = CONF.NUM_INTRO;
    end
    % useSegFirst = Shuffle([0 1]);
    useSegFirst = [1, 0];
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
    fileName = sprintf('%s@%s.mat',EXP.name, EXP.startTime);
    save(fileName,'DATA');

catch exception
    fprintf("[ERROR INFO] %s", exception.getReport);
end

closeScreen(SCR.window);

function [SCR, EXP] = initApplication(CONF, EXP)
    % 初始化应用程序，包括应用 DEBUG 模式，设置默认 EXP 值，
    % 调用 Java/MAT 文件获取图片列表对应的数据信息。
    % [ADD] EXP.data, SCR.debug, screenSize, EXP.isLearn, EXP.isSeg
    Screen('Preference','SuppressAllWarnings', true);
    if CONF.debug
        fprintf('%-20s Use Debug mode, Skip Sync Test\n','[MAIN]');
        Screen('Preference', 'SkipSyncTests', 1);
        SCR.debug = CONF.debug;
        SCR.screenSize = CONF.screenSize;
    else
        if CONF.noDebugSkipSyncTest
            fprintf('%-20s !!!!!!!!!! Warning, Skip Sync Test in no Debug mode !!!!!!!!\n','[MAIN]');
            Screen('Preference', 'SkipSyncTests', 1);
        else
            Screen('Preference', 'SkipSyncTests', 0);
        end
        SCR.debug = false;
        SCR.screenSize = [];
    end
    fprintf('%-20s Load Data from %s/%s\n','[MAIN]',EXP.picID, 'data.mat');
    res = load(fullfile('pics',EXP.picID,'data.mat'));
    EXP.data = res.data;
    EXP.isSeg = false;
    EXP.isLearn = false;
end

function SCR = initScreen(SCR)
    % 初始化 Screen 和 PTB 句柄
    % [ADD] SCR.window, windowRect, frameDuration, vblSlack
    %初始化 Screen
    if isempty(SCR.screenSize)
        [w,rect]= Screen('OpenWindow',0,[128 128 128]); 
    else
        [w,rect]= Screen('OpenWindow',0,[128 128 128],SCR.screenSize); 
    end
    SCR.window = w;
    SCR.x = (rect(3) - rect(1))/2;
    SCR.y = (rect(4) - rect(2))/2;
    SCR.windowRect = rect;
    SCR.frameDuration = Screen('GetFlipInterval',w); 
    SCR.vblSlack = SCR.frameDuration / 2;   
    HideCursor;
    Priority(2); % request the maximum amount of CPU time
end

function EXP = computePrefIsiFs(SCR, EXP)
    EXP.prefISIFs = EXP.prefISI / SCR.frameDuration;
    fprintf('%-20s Setting EXP.prefISIFs %1.2f by EXP.prefISI %1.0f ms and SCR.frameDuration %1.0f ms\n', ...
            '[MAIN]', EXP.prefISIFs, EXP.prefISI * 1000, SCR.frameDuration * 1000);
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
            % 获取每个 k 选项的 answers, 之后累积成为 a
            if ~isLearn
                repKNeed = CONF.repKNeed;
            else
                repKNeed = CONF.learnRepKNeed;
            end
            a = zeros(length(EXP_SPEC.("k" + repKNeed(1)).answers) * length(repKNeed),1) * -1;
            aIndex = 1;
            for k = repKNeed
                kAnswers = EXP_SPEC.("k" + k).answers;
                for i = 1:length(kAnswers)
                    a(aIndex) = kAnswers(i);
                    aIndex = aIndex + 1;
                end
            end
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

function EXP_SPEC_OUT = initCondition(SCR, EXP, CONF, isSeg, isLearn)
% 初始化指定的条件，根据 LearnOrNot、SegOrInt、IsiOrNum 遍历 K 调用 seeker 显示刺激，收集数据
    if isLearn
        if isSeg
            if EXP.seekForISI
                intro = CONF.ISI_INTRO_S_EX;
            else
                intro = CONF.NUM_INTRO_S_EX;
            end
            fprintf('%-20s System will First Run SegISISeeker...\n','[MAIN][SEG][LEARN]');
        else
            if EXP.seekForISI
                intro = CONF.ISI_INTRO_I_EX;
            else
                intro = CONF.NUM_INTRO_I_EX;
            end
            fprintf('%-20s System will First Run IntISISeeker...\n','[MAIN][INT][LEARN]');
        end
    else
        if isSeg
            if EXP.seekForISI
                intro = CONF.ISI_INTRO_S;
            else
                intro = CONF.NUM_INTRO_S;
            end
            fprintf('%-20s System will First Run SegISISeeker...\n','[MAIN][SEG]');
        else
            if EXP.seekForISI
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
    % 随机化需要重复的 K 次
    if ~isLearn
        repKNeed = Shuffle(CONF.repKNeed);
    else
        repKNeed = Shuffle(CONF.learnRepKNeed);
    end
    % 针对 ISI 和 NUM Seeker 分别遍历 K 次试验

    % 由于 EXP_SPEC 在 k 变化的循环中不断的将自身复制给下一个 k 字段，
    % 因此浪费内存，所以设置一个输出 struct，将所有 k{n} 写入到此 struct 中进行输出
    EXP_SPEC_OUT = EXP_SPEC; 
    % 对于 seekForISI 或者 seekForNum，需要删除的字段不同
    if EXP_SPEC.seekForISI
        fields = {'name','gender','note','startTime','picID','seekForISI'};
    else
        fields = {'name','gender','note','startTime','picID','prefISI','seekForISI'};
    end
    if EXP.seekForISI
        for k = repKNeed
            fprintf('%-20s System will Use repK %1.3f\n','[MAIN][ISI][SET-K]',k);
            EXP_SPEC.usedK = k;
            [~, EXP_SPEC_K] = runISISeeker(SCR, EXP_SPEC, CONF);
            % 对于 ISISeeker 而言，EXP_SPEC 即是传入的 EXP struct，其应该包含了所有信息
            % 但是对于我们而言，这部分信息在不同的 k{n} 中重复，因此仅保留 EXP_SPEC_OUT 中的数据即可，而将 k{n} 字段中的值删去。
            EXP_SPEC_K = rmfield(EXP_SPEC_K, fields);
            EXP_SPEC_OUT.("k" + k) = EXP_SPEC_K;
        end
    else 
        for k = repKNeed
            fprintf('%-20s System will Use repK %1.3f\n','[MAIN][NUM][SET-K]',k);
            EXP_SPEC.usedK = k;
            [~, EXP_SPEC_K] = runNumSeeker(SCR, EXP_SPEC, CONF);
            EXP_SPEC_K = rmfield(EXP_SPEC_K, fields);
            EXP_SPEC_OUT.("k" + k) = EXP_SPEC_K;
        end
    end
end