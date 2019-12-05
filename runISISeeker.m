function [SCR, EXP] = runISISeeker(SCR, EXP, CONF, w)
	
	vbl_slack = SCR.vblSlack;
	t_gray = MakeTexture(w, 'assert/gray.jpg');
	
	pictures = cell(CONF.repeat,3);
	for i = 1: length(EXP.data)
		commonFile = sprintf("sti_%d_%d_%d_", CONF.targetNumber,CONF.cheeseRow,i);
		common = fullfile(CONF.picFolder, commonFile);
		pictures{i,1} = char(common + "head.png");
		pictures{i,2} = char(common + "tail.png");
		pictures{i,3} = char(common + "fusion.png");
	end
	EXP.pictures = pictures;

	textures = cell(CONF.repeat,2);
	for i = 1 : length(EXP.data)
		pic1 = pictures{i, 1};
		textures{i,1} = MakeTexture(w, char(pic1));
		pic2 = pictures{i, 2};
		textures{i,2} = MakeTexture(w, char(pic2));
	end
    
    Flashcards_Repetition_K = 15;                 
    % K Repetition of a serial including: (Flashcard 1 + ISI + Flashcard 2); There is an ISI between any Repetition (totally K-1 ISIs) 
    Flashcard_1_Duration = SCR.frameDuration * 1;
    Flashcard_2_Duration = Flashcard_1_Duration;
    ISI = SCR.frameDuration * 10;
    
    EXP = initExperiment(EXP, Flashcards_Repetition_K, Flashcard_1_Duration, Flashcard_2_Duration, ISI);
    % when ISI = 1,  the integration effect is best, but the segregation is difficult
    % when ISI = 10, the segregation effect is best, but the integration is difficult
    
    Screen('DrawTexture',w,t_gray,[],[]); Screen('Flip',w);
    
    t01_onset=GetSecs;
	
	K = 1;
    while (K - 1 < Flashcards_Repetition_K)
        %[x,y,bdown]=GetMouse; % ~any(bdown) & 
    
        % 01: draw a serial including: Flashcards_Repetition_K*(Flashcard_1_Duration + ISI + Flashcard_2_Duration) + (Flashcards_Repetition_K - 1)*ISI
		t01 = textures{K, 1};
		t02 = textures{K, 2};

        Screen('DrawTexture',w,t01,[],[]);        
        t01_onset_real = Screen('Flip', w, t01_onset - vbl_slack);   
        t01_offset = t01_onset_real + Flashcard_1_Duration;
    
        Screen('DrawTexture',w,t_gray,[],[]); 
        t01_offset_real = Screen('Flip', w, t01_offset - vbl_slack); 
        t02_onset = t01_offset_real + ISI;
    
        Screen('DrawTexture',w,t02,[],[]);        
        t02_onset_real=Screen('Flip', w, t02_onset - vbl_slack);   
        t02_offset = t02_onset_real + Flashcard_2_Duration;
    
        Screen('DrawTexture',w,t_gray,[],[]); 
        t02_offset_real=Screen('Flip', w, t02_offset - vbl_slack); 
        t01_onset = t02_offset_real + ISI;
        
        if K==1, Stimuli_onset = t01_onset_real; end 
        K=K+1;
    end
    
    EXP.totalTime = t02_offset_real - Stimuli_onset;
end

function EXP = initExperiment(EXP, repeat, duration1, duration2, isi)
    EXP.repeat = repeat;
    EXP.duration1 = duration1;
    EXP.duration2 = duration2;
    EXP.isi = isi;
end

function t = MakeTexture(w, pictureName)
    img = imread(pictureName);
    t = Screen('MakeTexture',w,img);  
end