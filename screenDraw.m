% 本脚本用来测试 PTB 绘图
if isempty(Screen('Windows'))
	[w,~]= Screen('OpenWindow',0,[128 128 128],[10,10,800,600]);
end

[wCenterX, wCenterY] = WindowCenter(w);
rect = [0 0 200 200];
loop = 1000;
lastS = GetSecs;
for i= 1:loop
	if mod(i,2) == 0
		color = [0 0 0];
	else
		color = [255, 255, 255];
	end
	centeredRect = CenterRectOnPoint(rect, wCenterX, wCenterY);
	Screen('FillRect', w, color, centeredRect);
	lastS = Screen('Flip',w, lastS + 0.033);
	WaitSecs(0.002);
end