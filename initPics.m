function data = initPics(picPath, jarPath, debugMode, target, count)
%INITPICS ��ʼ��������Ҫʹ�õ���ͼƬ
%   ʹ�� MATLAB ���õ� Java 8 ��������� com.mazhangjing.time �����ɴ̼������ҵ���
%	JavaFx GUI �����̼�ͼƬ��generatePicturesWithArgs �������᷵�� p * c �ľ���p
%	Ϊ������c Ϊÿ�����ظ������������ 0 ����˴���ΪĿ��̼���1 ���� ���ǣ�2 ���� ���Ρ�
%
%	generatePicturesWithArgs ���ܲ���������ǣ�
%	����ģʽ���򿪺�ʹ����ɫ��� Seg Ŀ��λ�ã���Ŀ��ĸ��������̵���������
%	�����ļ���ǰ׺�����ɴ̼��ĸ������ظ�����������Χ�����ɫ�Լ�������ɫ��Ŀ��λ�õ���ɫ��
%	
%	ע�⣬MATLAB GUI Ҳʹ���� JavaFx ��⣬�� JavaFx �������һ��ֻ�ܴ�һ������˺�����
%	һ�� MATLAB ʵ����ֻ�ܵ���һ�Σ��ظ������޷�ͨ������ǰ��⡣���� MATLAB ���ɵ��ô˷�����
%
% 	author: Corkine Ma @ 2019-12-04
switch nargin
	case 0
		picPath = "pics";
		jarPath = fullfile(picPath,"Psy4J.jar");
		debugMode = true;
		target = 6;
		count = 100;
	case 1
		jarPath = fullfile(picPath,"Psy4J.jar");
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
	disp('���ִ���' + string(exception.message));
	data = [];
end
cd(currentDir);
end

