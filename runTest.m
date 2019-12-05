function [SCR, EXP] = runTest(SCR, EXP, CONF, w)
%RUNTEST PTB 执行基准性能测试
%   使用示例图片执行 PTB 基准性能测试
vbl_slack = SCR.vblSlack;
b1 = fullfile("test","001.bmp");
b2 = fullfile("test","002.bmp");
b3 = fullfile("test","whiteBKG.bmp");

t01 = MakeTexture(w, char(b1));
t02 = MakeTexture(w, char(b2)); 
t_whiteBKG = MakeTexture(w, char(b3));

Flashcards_Repetition_K = 15;                 
% K Repetition of a serial including: (Flashcard 1 + ISI + Flashcard 2); There is an ISI between any Repetition (totally K-1 ISIs) 
Flashcard_1_Duration = SCR.frameDuration * 1;
Flashcard_2_Duration = Flashcard_1_Duration;
ISI = SCR.frameDuration * 10;

EXP = initExperiment(EXP, Flashcards_Repetition_K, Flashcard_1_Duration, Flashcard_2_Duration, ISI);
% when ISI = 1,  the integration effect is best, but the segregation is difficult
% when ISI = 10, the segregation effect is best, but the integration is difficult

switch_on=1; K=0; 
Screen('DrawTexture',w,t_whiteBKG,[],[]); Screen('Flip',w);

t01_onset=GetSecs;

while (switch_on==1 && K<Flashcards_Repetition_K)
	%[x,y,bdown]=GetMouse; % ~any(bdown) & 

	% 01: draw a serial including: Flashcards_Repetition_K*(Flashcard_1_Duration + ISI + Flashcard_2_Duration) + (Flashcards_Repetition_K - 1)*ISI
	
	Screen('DrawTexture',w,t01,[],[]);        
	t01_onset_real = Screen('Flip', w, t01_onset - vbl_slack);   
	t01_offset = t01_onset_real + Flashcard_1_Duration;

	Screen('DrawTexture',w,t_whiteBKG,[],[]); 
	t01_offset_real = Screen('Flip', w, t01_offset - vbl_slack); 
	t02_onset = t01_offset_real + ISI;

	Screen('DrawTexture',w,t02,[],[]);        
	t02_onset_real=Screen('Flip', w, t02_onset - vbl_slack);   
	t02_offset = t02_onset_real + Flashcard_2_Duration;

	Screen('DrawTexture',w,t_whiteBKG,[],[]); 
	t02_offset_real=Screen('Flip', w, t02_offset - vbl_slack); 
	t01_onset = t02_offset_real + ISI;
	
	if K==0, Stimuli_onset = t01_onset_real; end 
	switch_on=1; K=K+1;
end

EXP.totalTime = t02_offset_real - Stimuli_onset;
EXP.repeatReal = (EXP.totalTime + ISI) / (Flashcard_1_Duration + ISI + Flashcard_2_Duration + ISI);
EXP.missFrame = ((Flashcard_1_Duration + ISI + Flashcard_2_Duration)* Flashcards_Repetition_K + ...
	(Flashcards_Repetition_K - 1 )* ISI - EXP.totalTime) / SCR.frameDuration;
end

function EXP = initExperiment(EXP, repeat, duration1, duration2, isi)
    EXP.repeat = repeat;
    EXP.duration1 = duration1;
    EXP.duration2 = duration2;
    EXP.isi = isi;
end

function t = MakeTexture(w, pictureName)
    img = imread(pictureName);
    t =Screen('MakeTexture',w,img);  
end