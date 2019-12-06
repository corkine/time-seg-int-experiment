function [folderName, data] = initPics()
%INITPICS ��ʼ��������Ҫʹ�õ���ͼƬ
%   ʹ�� MATLAB ���õ� Java 8 ��������� com.mazhangjing.time �����ɴ̼������ҵ���
%	JavaFx GUI �����̼�ͼƬ��generatePicturesWithArgs �������᷵�� p * c �ľ���p
%	Ϊ������c Ϊÿ�����ظ������������ 0 ����˴���ΪĿ��̼���1 ���� ���ǣ�2 ���� ���Ρ�
%	
%	ע�⣬MATLAB GUI Ҳʹ���� JavaFx ��⣬�� JavaFx �������һ��ֻ�ܴ�һ������˺�����
%	һ�� MATLAB ʵ����ֻ�ܵ���һ�Σ��ظ������޷�ͨ������ǰ��⡣���� MATLAB ���ɵ��ô˷�����
%
% 	author: Corkine Ma @ 2019-12-04

% TODO: �ͳ������������ú�������ͼƬ������֧����������ͼƬ��ÿ����������ͼƬ������һ���ļ����У�
% �ҽ���Ϣ��ͼƬ�Ա������������һ�� 23334.mat xxxx.png ���������� 23334 �ļ����У�Ȼ��ʹ��ʱָ���ļ���
% ע�⣬�� ISISeeker �� NumSeeker ���ɵ����� xxxxx.mat ��Ϣ

debugMode = CONF.debug;
target = CONF.targetNumber;
row = CONF.cheeseRow;
wid = CONF.cheeseGridWidth;
picPath = CONF.picFolder;
jarPath = CONF.stimulateJarFile;
count = CONF.repeatTrial * length(CONF.isiNeed);
currentDir = pwd;
cd(fullfile(currentDir,picPath));
try
	javaaddpath(jarPath);
	h = com.mazhangjing.time.MATLABHelper;
	data = h.generatePicturesWithArgsInRandomFolder(...
			debugMode, target, row, wid, 'sti',count,'black','white');
	folderName = javaMethod('folder','com.mazhangjing.time.MATLABHelper');
catch exception
	disp('���ִ���' + string(exception.message));
	data = [];
	folderName = '';
end
cd(currentDir);
end

