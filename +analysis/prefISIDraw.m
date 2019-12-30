function prefISI = prefISIDraw(DATA)
	assert(nargin == 1,'just input DATA struct!');
	assert(DATA.segData.seekForISI == 1,'the DATA struct: segData.seekForISI must be 1');
	assert(DATA.intData.seekForISI == 1, 'the DATA struct: intData.seekForISI must be 1');
	assert(DATA.segData.isSeg == 1 && DATA.segData.isLearn == 0, 'segData check failed!');
	assert(DATA.intData.isSeg == 0 && DATA.intData.isLearn == 0, 'intData check failed!');

	conf = DATA.conf;
	repKNeed = conf.repKNeed;
	segData = DATA.segData;
	intData = DATA.intData;
	% 对于每个 k 的 seg/int 计算每个 isi 的正确率
	% 每个k循环,每个 k 单独一种颜色线表示
	figure
	hold on
	for isSeg = [1 0]
		disp("For Seg? " + isSeg);
		for k = repKNeed
			disp("For k=" + k);
			if isSeg
				data = segData.("k" + k);
			else
				data = intData.("k" + k);
			end
			isiUsed = data.isiNeed;
			rateComputed = zeros(1, length(isiUsed));
			isis = data.isiWithRepeat; % 360*1 array
			answers = data.answers; % 360*1 array
			% isi 作为 x 轴，rate 作为 y 轴
			for i = 1: length(isiUsed)
				isi = isiUsed(i);
				disp("For isi=" + isi);
				% 对于每个 isi，寻找其在 trial 中对应的行，然后计算正确率
				thisISIAnswer = answers(isis == isi);
				rate = sum(thisISIAnswer)/length(thisISIAnswer);
				disp("Rate=" + rate);
				rateComputed(1,i) = rate;
			end
			if isSeg
				dotChoose = '-^';
			else
				dotChoose = '-o';
			end
			plot(isiUsed * 1000, rateComputed, dotChoose, 'LineWidth', 2);
		end
	end

	title = sprintf('prefISI Result for %s@%s', DATA.segData.name, DATA.segData.picID);
	set(get(gca, 'Title'), 'String', title);
	set(get(gca, 'XLabel'), 'String', 'ISI ms');
	set(get(gca, 'YLabel'), 'String', 'CorrectRate %');
	legendSeg = "Seg k=" + repKNeed;
	legendInt = "Int k=" + repKNeed;
	legend([legendSeg legendInt]);
	hold off
	prefISI = 10;
end