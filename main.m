CONF = configLoad();
CONF = dialogLoad(CONF);
[SCR, EXP] = initApplication(CONF); 
[w, rect, SCR] = initScreen(SCR);

try
    % [SCR, EXP] = runTest(SCR, EXP, CONF, w);
    if CONF.seekForISI
        useSegFirst = Shuffle([0 1]);
        if useSegFirst(1)
            fprintf('System will First Run SegISISeeker...\n');
            [SCR, EXP] = runISISeeker(SCR, EXP, CONF, w, true, true);
            fprintf('System will First Run IntISISeeker...\n');
            [SCR, EXP] = runISISeeker(SCR, EXP, CONF, w, false, false);
        else
            fprintf('System will First Run IntISISeeker...\n');
            [SCR, EXP] = runISISeeker(SCR, EXP, CONF, w, false, true);
            fprintf('System will First Run SegISISeeker...\n');
            [SCR, EXP] = runISISeeker(SCR, EXP, CONF, w, true, false);
        end
    else
        [SCR, EXP] = runNumSeeker(SCR, EXP, CONF, w);
    end
catch exception
    disp("Run PTB Error: " + string(exception.message) + ...
    ", For more info, check exception variable");
end

closeScreen(w);

function [SCR, EXP] = initApplication(CONF)
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

function [w,rect,SCR] = initScreen(SCR)
    %初始化 Screen
    [w,rect]= Screen('OpenWindow',0,[128 128 128],SCR.screenSize); 
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