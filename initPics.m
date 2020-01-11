function [folderName, data] = initPics()
%INITPICS 初始化被试需要使用到的图片
%   使用 MATLAB 内置的 Java 8 虚拟机加载 com.mazhangjing.time 包生成刺激，并且调用
%	JavaFx GUI 创建刺激图片，generatePicturesWithArgs 方法将会返回 p * c 的矩阵，p
%	为人数，c 为每个人重复次数。结果中 0 代表此处不为目标刺激，1 代表 三角，2 代表 矩形。
%	
%	注意，MATLAB GUI 也使用了 JavaFx 类库，而 JavaFx 类库限制一次只能打开一个，因此函数在
%	一个 MATLAB 实例中只能调用一次，重复调用无法通过启动前检测。重启 MATLAB 即可调用此方法。
%
% 	author: Corkine Ma @ 2019-12-04

% TODO: 和程序解耦，单独调用函数生成图片，并且支持批量生成图片，每个被试所需图片放置在一个文件夹中，
% 且将信息和图片以编号命名放置在一起 23334.mat xxxx.png 合起来放在 23334 文件夹中，然后使用时指定文件夹
% 注意，对 ISISeeker 和 NumSeeker 生成单独的 xxxxx.mat 信息

fprintf('%-20s Loading Config From configLoad()\n','[CONFIG]');
CONF = configLoad();
debugMode = CONF.debug;
target = CONF.targetNumber;
row = CONF.cheeseRow;
wid = CONF.cheeseGridWidth;
picPath = CONF.picFolder;
jarPath = CONF.stimulateJarFile;
count = int32(CONF.repeatTrial * length(CONF.isiNeedFs) / 5);
currentDir = pwd;
cd(fullfile(currentDir,picPath));
try
	javaaddpath(jarPath);
	h = com.mazhangjing.time.MATLABHelper;
	data = h.generatePicturesWithArgsInRandomFolder(...
			debugMode, target, target, row, wid, count, 'sti', 'gray','black');
	folderString = javaMethod('folder','com.mazhangjing.time.MATLABHelper');
	folderName = char(folderString);
	fprintf('%-20s Saved Data to data.mat at folder %s\n','[CONFIG]', folderName);
	save(fullfile(folderName,'data.mat'),'data');
catch exception
	disp('出现错误' + string(exception.message));
	data = [];
	folderName = '';
end
cd(currentDir);
end

