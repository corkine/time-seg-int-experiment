function allData = prefISIDraw(DATA)
	assert(nargin == 1,'just input DATA struct!');
	assert(DATA.segData.seekForISI == 1,'the DATA struct: segData.seekForISI must be 1');
	assert(DATA.intData.seekForISI == 1, 'the DATA struct: intData.seekForISI must be 1');
	assert(DATA.segData.isSeg == 1 && DATA.segData.isLearn == 0, 'segData check failed!');
	assert(DATA.intData.isSeg == 0 && DATA.intData.isLearn == 0, 'intData check failed!');

	conf = DATA.conf;
	repKNeed = conf.repKNeed;
	segData = DATA.segData;
	intData = DATA.intData;

	% 所有数据输出，方便拟合：每个 field k 条曲线，isi 列
	allData.seg = zeros(length(repKNeed), length(conf.isiNeedFs));
	allData.int = zeros(length(repKNeed), length(conf.isiNeedFs));
	% 对于每个 k 的 seg/int 计算每个 isi 的正确率
	% 每个k循环,每个 k 单独一种颜色线表示
	figure('Name','prefISI Result');
	hold on
	for isSeg = [1 0]
		disp("For Seg? " + isSeg);
		for ki = 1:length(repKNeed)
			k = repKNeed(ki);
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
				% 对于每个 isi，寻找其在 trial 中对应的行，然后计算正确率
				thisISIAnswer = answers(isis == isi);
				rate = sum(thisISIAnswer)/length(thisISIAnswer);
				rateComputed(1,i) = rate;
				if isSeg
					allData.seg(ki, i) = rate;
				else
					allData.int(ki, i) = rate;
				end
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
	allData.isi = isiUsed;
	allData.k = repKNeed;

	figure('Name','prefISI Curve Fitting')
	hold on
	for isSeg = [1, 0]
		if isSeg
			ys = allData.seg;
		else
			ys = allData.int;
		end
		for ki = 1: length(repKNeed)
			y = ys(ki,:);
			model = fitlm(isiUsed * 1000, y, 'poly5');
			p = plot(model);
			p(2).LineWidth = 2;
		end
	end
	
	legendSeg = "Seg k=" + repKNeed;
	legendInt = "Int k=" + repKNeed;
	legend([legendSeg legendInt]);
	title = sprintf('prefISI Result for %s@%s', DATA.segData.name, DATA.segData.picID);
	set(get(gca, 'Title'), 'String', title);
	set(get(gca, 'XLabel'), 'String', 'ISI ms');
	set(get(gca, 'YLabel'), 'String', 'CorrectRate %');
	hold off

end