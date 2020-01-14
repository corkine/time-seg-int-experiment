% ���ű�����ִ������ʵ�����̣������̼������ɡ��Դεı��š���Ϣ��ָ���
% ���ݽṹ������ʾ��
%   DATA ������������ -- seg��intData ���� Seg��Int ���� -- k{n} ���� k ��ĳһ��ˮƽ������ -- 
%   EXP ĳһ�� k ˮƽ�²�ͬ�����Ա��������ݣ����� seekISI ���ԣ��� isi������ seekNum ���ԣ��� num
% ��������������ʾ��
%   seg/intData.k{n}, EXP.usedK, ���� seekForNum ������ע�룺EXP.prefISI �� EXP.prefISIFs
%   dexpLoad
%       [ADD] prefISI��startTime��seekForISI��name��gender��note��picId
%   initApplication
%       [ADD] EXP.data, SCR.debug, screenSize, EXP.isLearn, EXP.isSeg
%   initScreen
%       [ADD] SCR.window, windowRect, frameDuration, vblSlack, x, y  
%   runISISeeker
%       [ADD] EXP.segStartTime, EXP.intStartTime
%       prepareMaterial 
%           [ADD] EXP.pictures, EXP.isiWithRepeat, EXP.answers, EXP.actionTime, EXP.usedData, EXP.numberWithRepeat[, EXP.userAnswers]
%
%  ����ֱ�ӵ��� Psy4J.jar ����ͼƬ��ͨ���˺������õ� Psy4J.jar �Ὣ������浽 debug_data.mat ��
%  �Ա� debug ģʽʹ�á������ݺ�ͼƬ˳���Ӧ��������ͼƬ�еĵ���ؼ���Ϣ��

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
    useSegFirst = [0, 1];
    if useSegFirst(1) % ����� Seg��Int ˳��
        % ��ָ����
        showIntro(SCR, totalIntro, 0.5);
        % Seg - ��ϰ
        EXP_S_EX = initConditionWithTry(SCR, EXP, CONF, true, true);
        % Seg - ��ʽ
        EXP_S = initCondition(SCR, EXP, CONF, true, false);
        % �м���Ϣ
        fprintf('%-20s Systen will sleep For %d secs\n', '[SLEEP]',CONF.participartRelex);
        showSleep(SCR, CONF.participartRelex, 0.5);
        % Int - ��ϰ
        EXP_I_EX = initConditionWithTry(SCR, EXP, CONF, false, true);
        % Int - ��ʽ
        EXP_I = initCondition(SCR, EXP, CONF, false, false);
    else
        % ��ָ����
        showIntro(SCR, totalIntro, 0.5);
        % Int - ��ϰ
        EXP_I_EX = initConditionWithTry(SCR, EXP, CONF, false, true);
        % Int - ��ʽ
        EXP_I = initCondition(SCR, EXP, CONF, false, false);
        % �м���Ϣ
        fprintf('%-20s Systen will sleep For %d secs\n', '[SLEEP]', CONF.participartRelex);
        showSleep(SCR, CONF.participartRelex, 0.5);
        % Seg - ��ϰ
        EXP_S_EX = initConditionWithTry(SCR, EXP, CONF, true, true);
        % Seg - ��ʽ
        EXP_S = initCondition(SCR, EXP, CONF, true, false);
    end
    
    % ������������
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
    % ��ʼ��Ӧ�ó��򣬰���Ӧ�� DEBUG ģʽ������Ĭ�� EXP ֵ��
    % ���� Java/MAT �ļ���ȡͼƬ�б��Ӧ��������Ϣ��
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
    % ��ʼ�� Screen �� PTB ���
    % [ADD] SCR.window, windowRect, frameDuration, vblSlack
    %��ʼ�� Screen
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
    % �رպ����� PTB ���
    Priority(0);
    Screen('Close',w); 
    Screen('CloseAll'); 
    ShowCursor;
end

function showIntro(SCR, introImage, withDelay)
    % ��ʾָ�������
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
    % ��ʾ��Ϣ����
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
    % ��ʾ��ȷ����Ϣ
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
    % ִ�� initCondition��������ȷ���жϣ������ͨ�������������ԡ�
    if CONF.useUnlimitLearn
        while true
            EXP_SPEC = initCondition(SCR, EXP, CONF, isSeg, isLearn);
            % ��ȡÿ�� k ѡ��� answers, ֮���ۻ���Ϊ a
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
% ��ʼ��ָ�������������� LearnOrNot��SegOrInt��IsiOrNum ���� K ���� seeker ��ʾ�̼����ռ�����
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
    % Seg/Int ָ���� - ��ʽ/��ϰ
    showIntro(SCR, intro);

    % Seg/Int ʵ�� - ��ʽ/��ϰ
    EXP_SPEC = EXP;
    EXP_SPEC.isSeg = isSeg;
    EXP_SPEC.isLearn = isLearn;
    % �������Ҫ�ظ��� K ��
    if ~isLearn
        repKNeed = Shuffle(CONF.repKNeed);
    else
        repKNeed = Shuffle(CONF.learnRepKNeed);
    end
    % ��� ISI �� NUM Seeker �ֱ���� K ������

    % ���� EXP_SPEC �� k �仯��ѭ���в��ϵĽ������Ƹ���һ�� k �ֶΣ�
    % ����˷��ڴ棬��������һ����� struct�������� k{n} д�뵽�� struct �н������
    EXP_SPEC_OUT = EXP_SPEC; 
    % ���� seekForISI ���� seekForNum����Ҫɾ�����ֶβ�ͬ
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
            % ���� ISISeeker ���ԣ�EXP_SPEC ���Ǵ���� EXP struct����Ӧ�ð�����������Ϣ
            % ���Ƕ������Ƕ��ԣ��ⲿ����Ϣ�ڲ�ͬ�� k{n} ���ظ�����˽����� EXP_SPEC_OUT �е����ݼ��ɣ����� k{n} �ֶ��е�ֵɾȥ��
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