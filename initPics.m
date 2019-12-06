function data = initPics(picPath, jarPath, debugMode, target, count)
%INITPICS 初始化被试需要使用到的图片
%   使用 MATLAB 内置的 Java 8 虚拟机加载 com.mazhangjing.time 包生成刺激，并且调用
%	JavaFx GUI 创建刺激图片，generatePicturesWithArgs 方法将会返回 p * c 的矩阵，p
%	为人数，c 为每个人重复次数。结果中 0 代表此处不为目标刺激，1 代表 三角，2 代表 矩形。
%
%	generatePicturesWithArgs 接受侧参数依次是：
%	调试模式（打开后，使用绿色填充 Seg 目标位置），目标的个数，棋盘的行列数，
%	生成文件的前缀，生成刺激的个数（重复次数），周围填充颜色以及背景颜色（目标位置的颜色）
%	
%	注意，MATLAB GUI 也使用了 JavaFx 类库，而 JavaFx 类库限制一次只能打开一个，因此函数在
%	一个 MATLAB 实例中只能调用一次，重复调用无法通过启动前检测。重启 MATLAB 即可调用此方法。
%
% 	author: Corkine Ma @ 2019-12-04

% TODO: 和程序解耦，单独调用函数生成图片，并且支持批量生成图片，每个被试所需图片放置在一个文件夹中，
% 且将信息和图片以编号命名放置在一起 23334.mat xxxx.png 合起来放在 23334 文件夹中，然后使用时指定文件夹
% 注意，对 ISISeeker 和 NumSeeker 生成单独的 xxxxx.mat 信息

switch nargin
	case 0
		picPath = "pics";
		jarPath = "Psy4J.jar";
		debugMode = true;
		target = 6;
		count = 100;
	case 1
		jarPath = "Psy4J.jar";
		debugMode = true;
		target = 6;
		count = 100;
	case 2
		debugMode = true;
		target = 6;
		count = 100;
	case 3
		target = 6;
		count = 100;
	case 4
		count = 100;
	otherwise
end
currentDir = pwd;
cd(fullfile(currentDir,picPath));
try
	javaaddpath(jarPath);
	h = com.mazhangjing.time.MATLABHelper;
	data = h.generatePicturesWithArgs(debugMode, target, 8, 30, 'sti',count,'black','white');
catch exception
	disp('出现错误' + string(exception.message));
	data = [];
end
cd(currentDir);
end

