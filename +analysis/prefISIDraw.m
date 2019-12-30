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
	
	% 拟合曲线
	
	allData.segFit = cell(length(repKNeed),1);
	allData.intFit = cell(length(repKNeed),1);
	degree = 'poly2';
	figure('Name',sprintf('prefISI Curve Fitting - %s', degree))
	hold on
	for isSeg = [1, 0]
		if isSeg
			ys = allData.seg;
			data = allData.segFit;
		else
			ys = allData.int;
			data = allData.intFit;
		end
		for ki = 1: length(repKNeed)
			y = ys(ki,:);
			% 注意，这个模型计算使用的是 ms 而非 s
			model = fitlm(isiUsed * 1000, y, degree);
			data{ki,1} = model;
			p = plot(model);
			p(2).LineWidth = 2;
		end
		if isSeg
			allData.segFit = data;
		else
			allData.intFit = data;
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

	fitDataX = min(isiUsed):0.001:max(isiUsed);
	segDataAll = zeros(length(repKNeed), length(fitDataX));
	intDataAll = zeros(length(repKNeed), length(fitDataX));
	diffDataAll = zeros(length(repKNeed), length(fitDataX));
	minDataAll = zeros(length(repKNeed), 3);
	for ki = 1: length(repKNeed)
		k = repKNeed(ki);
		segDataY = zeros(1, length(fitDataX));
		intDataY = zeros(1, length(fitDataX));
		diffDataY = zeros(1, length(fitDataX));
		segModel = allData.segFit{ki,1};
		intModel = allData.intFit{ki,1};
		for xi = 1: length(fitDataX)
			x = fitDataX(xi);
			sy = predict(segModel, x * 1000);
			iy = predict(intModel, x * 1000);
			dy = abs(sy - iy);
			segDataY(1,xi) = sy;
			intDataY(1,xi) = iy;
			diffDataY(1,xi) = dy;
		end
		segDataAll(ki,:) = segDataY;
		intDataAll(ki,:) = intDataY;
		diffDataAll(ki,:) = diffDataY;
		[minIsiDiffValue, minIsiIndex] = min(diffDataY);
		equalIsiSegValue = segDataY(1,minIsiIndex);
		equalIsiIntValue = intDataY(1,minIsiIndex);
		fprintf('For k= %d, equalIsiDiffValue is %1.3fs, seg is %1.3fs, int is %1.3fs\n', ...
				k, minIsiDiffValue, equalIsiSegValue, equalIsiIntValue);
		minDataAll(ki,1) = minIsiDiffValue;
		minDataAll(ki,2) = equalIsiSegValue;
		minDataAll(ki,3) = equalIsiIntValue;
	end
	allData.diff = minDataAll;
	allData.usedXPredict = fitDataX;
	allData.segPredict = segDataAll;
	allData.intPredict = intDataAll;
	allData.diffPredict = diffDataAll;

	figure('Name','prefISI Equal ISI Seek Result')
	hold on
	xs = allData.usedXPredict;
	for ki = 1: length(allData.k)
		segYs = allData.segPredict(ki,:);
		intYs = allData.intPredict(ki,:);
		plot(xs * 1000, segYs);
		plot(xs * 1000, intYs);
	end

	hold off
	legendSeg = "Seg k=" + repKNeed;
	legendInt = "Int k=" + repKNeed;
	legend([legendSeg legendInt]);
	title = sprintf('prefISI Result for %s@%s', DATA.segData.name, DATA.segData.picID);
	set(get(gca, 'Title'), 'String', title);
	set(get(gca, 'XLabel'), 'String', 'ISI ms');
	set(get(gca, 'YLabel'), 'String', 'CorrectRate %');

end