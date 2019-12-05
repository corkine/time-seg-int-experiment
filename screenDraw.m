% 本脚本用来测试 PTB 绘图
if isempty(Screen('Windows'))
	[w,rect]= Screen('OpenWindow',0,[128 128 128],[10,10,800,600]);
end

sleepTime = 10;
text = sprintf('Please Relex for min %d secs\nPress space to continue', sleepTime);
DrawFormattedText(w, text,...
				 'center', 'center');
Screen('Flip',w);
WaitSecs(sleepTime);
Screen('Flip',w);
