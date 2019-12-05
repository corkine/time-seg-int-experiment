if isempty(Screen('Windows'))
	[w,rect]= Screen('OpenWindow',0,[128 128 128],[10,10,800,600]);
end

DrawFormattedText(w, '+', 'center','center',[255 0 0]);
Screen('TextStyle', w, 0);
Screen('TextSize', w, 50);
Screen('Flip', w);
