% 本脚本用来测试 PTB 绘图
if isempty(Screen('Windows'))
	[w,~]= Screen('OpenWindow',0,[128 128 128],[10,10,800,600]);
end

imgArray = getMask(10, 50);
tId = Screen('MakeTexture', w, imgArray);
Screen('DrawTexture', w, tId, [0 0 50 50], [0 0 350 350]);
Screen('Flip',w);

function imgArray = getMask(gridWidthPixel, gridEachRow)
	seek = zeros(gridEachRow, 1);
	for c = 1: length(seek)
		for r = 1 : length(seek)
			seek(c, r) = round(rand(1)) * 255;
		end
	end
	imgArray = seek;
end