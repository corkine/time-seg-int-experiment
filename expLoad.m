function EXP = expLoad(CONF, EXP)
%DIALOGLOAD �ӶԻ����м������ã����д�� EXP struct �С�
%�������� EXP ��д���� prefISI��startTime��seekForISI��name��gender��note��picId ��Ϣ��
%CONF struct contains debug, defaultSeekForISI, defaultName, defaultGender, defaultNote, defaultISI, defaultPicID fields
%   ����� SeekForISI ��һ���֣������ debug ģʽ���򷵻أ���֮�����ȡ�����򷵻أ����ȷ���򷵻��趨���ֵ��
%   ����� SeekForNumber �ڶ����֣�����������Ի���Ҫ������������ prefISI �Թ���������ʵ��

assert(nargin > 1, ...
'Should Input CONF struct contains debug, defaultSeekForISI, defaultName, defaultGender, defaultNote, defaultISI fields and EXP struct');

prompt = {'seek For prefISI? 1 For prefNumber? 0',...
'participartName','participartGender(FeMale 0, Male 1)','participartNote','participartPicId'};
default_ans = {num2str(CONF.defaultSeekForISI), CONF.defaultName, num2str(CONF.defaultGender), CONF.defaultNote, CONF.defaultPicID};
title = 'Config Dialog';

EXP.prefISI = CONF.defaultISI;

if CONF.debug
    % DEBUG ģʽ��һ�����ߵڶ�������ʹ��Ĭ������
    EXP.seekForISI = CONF.defaultSeekForISI;
    EXP.name = CONF.defaultName;
    EXP.gender = CONF.defaultGender;
    EXP.note = CONF.defaultNote;
    EXP.startTime = join(string(clock),'_');
    EXP.picID = CONF.defaultPicID;
else
    % ��ʽʵ�飬�����һ������ֻ��һ���Ի���
    % ����ڶ������������Ի���
    anst = inputdlg(prompt, title, 1, default_ans);
    if ~isempty(anst)
        EXP.seekForISI = str2double(anst{1,1});
        EXP.name = anst{2,1};
        EXP.gender = str2double(anst{3,1});
        EXP.note = anst{4,1};
        EXP.startTime = join(string(clock),'_');
        EXP.picID = anst{5,1};
    else
        error('�˲��費�����������ϣ��ʹ��Ĭ�����ã�����ȷ�����ı����н���ֵ��ʹ�ã��������رմ���');
    end
    EXP = getPrefISI(CONF, EXP);
end
end

function EXP = getPrefISI(CONF, EXP)
    if ~CONF.defaultSeekForISI
        anste = inputdlg({'prefISI'}, 'PrefISI Load Dialog', 1, {char(CONF.defaultISI)}); 
        if isempty(anste)
            fprintf('%-20s Not load prefISI... Use Default %2.2f now...\n', '[MAIN][CONFIG]', EXP.prefISI);
        else
            EXP.prefISI = str2double(anste{1,1});
            fprintf('%-20s Setting prefISI %2.2f for %s now...\n', '[MAIN][CONFIG]', EXP.prefISI, CONF.defaultName);
        end
    else
        fprintf('%-20s Dialog Get Conf.seekForISI for %s with pic %s\n', '[MAIN][CONFIG]', EXP.name, EXP.picID);
    end 
end
