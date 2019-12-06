% 本脚本用来测试 PTB 绘图
if isempty(Screen('Windows'))
	[w,rect]= Screen('OpenWindow',0,[128 128 128],[10,10,800,600]);
end

rightAnswer = 3;
needFeedBack = true;
feedBackDelaySecs = 1.0;

Screen('Flip',w);
answer = Ask(w, 'How much target do you find? ',0, 128,'GetChar',[],'center');
try
	response = str2double(answer);
	if response == rightAnswer
		answerRight = true;
	else
		answerRight = false;
	end
catch exception
	fprintf('%-20s Get Num Error!\n', '[MAIN][RESPONSE]');
	response = -1;
	answerRight = false;
end
Screen('Flip',w);
if needFeedBack
	if answerRight
		DrawFormattedText(w,'Right Answer!','center','center',[0 0 0]);
		Screen('Flip',w);
	else
		DrawFormattedText(w,'Wrong Answer!','center','center',[255 0 0]);
		Screen('Flip',w);
	end
	WaitSecs(feedBackDelaySecs);
end

Screen('Flip',w);

fprintf('%-20s Get Response %d [Right is %d] and is Right? %d!\n', '[MAIN][RESPONSE]',...
		response, rightAnswer, answerRight);
% if nargin == 3
% 	WaitSecs(withDelay);
% end