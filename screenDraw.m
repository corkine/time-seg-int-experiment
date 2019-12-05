% 本脚本用来测试 PTB 绘图
if isempty(Screen('Windows'))
	[w,rect]= Screen('OpenWindow',0,[128 128 128],[10,10,800,600]);
end

Screen('Flip',w);
row = 8;
width = 30;
cellRects = ArrangeRects(row * row, [0 0 width width],[0 0 width * row, width * row]);
[wx, wy] = WindowCenter(w);
offx = wx - width * row / 2;
offy = wy - width * row / 2;
cellRects2 = OffsetRect(cellRects, offx, offy);
rects = cellRects2'; %每列从上到下 x1,y1,x2,y2;

while true
	[x, y, btns] = GetMouse;
	choosedRect = [];
	for i = 1:length(cellRects2)
		currentRect = cellRects2(i,:);
		if IsInRect(x, y, currentRect)
			Screen('FillRect',w, [0 255 0], currentRect);
			choosedRect = currentRect;
		end
	end
	Screen('FrameRect', w, [0 0 0], rects);
	Screen('Flip',w);
	WaitSecs(0.03);
	if btns(1) && ~isempty(choosedRect)
		fprintf('Checked Choose Result %d %d %d %d', choosedRect(1,1), choosedRect(1,2),...
				choosedRect(1,3), choosedRect(1,4));
		break;
	end
end
Screen('Flip',w);

[~, rowNumber] = ismember(choosedRect, cellRects2, 'rows');
rowNumber


