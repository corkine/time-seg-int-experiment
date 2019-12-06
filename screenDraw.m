% 本脚本用来测试 PTB 绘图
if isempty(Screen('Windows'))
	[w,rect]= Screen('OpenWindow',0,[128 128 128],[10,10,800,600]);
end

Screen('Flip',w);
needP = 0.9;
currentP = 0.0056;
text = sprintf('Your Accuracy is %2.2f%% < %2.2f%%\nPress the space bar to try again', currentP * 100, needP * 100);
DrawFormattedText(w, text, 'center', 'center', [0 0 0]); 
Screen('Flip',w);
space = KbName('space');
while true
	[~, ~, keycode] = KbCheck();
	if keycode(space), break; end
	WaitSecs(0.1);
end
Screen('Flip', w);
% if nargin == 3
% 	WaitSecs(withDelay);
% end