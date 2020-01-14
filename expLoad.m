function EXP = expLoad(CONF, EXP)
%DIALOGLOAD 从对话框中加载配置，结果写入 EXP struct 中。
%本程序往 EXP 中写入了 prefISI、startTime、seekForISI、name、gender、note、picId 信息。
%CONF struct contains debug, defaultSeekForISI, defaultName, defaultGender, defaultNote, defaultISI, defaultPicID fields
%   如果是 SeekForISI 第一部分，如果是 debug 模式，则返回，反之，如果取消，则返回，如果确定则返回设定后的值。
%   如果是 SeekForNumber 第二部分，则继续弹出对话框要求被试输入计算的 prefISI 以供接下来的实验

assert(nargin > 1, ...
'Should Input CONF struct contains debug, defaultSeekForISI, defaultName, defaultGender, defaultNote, defaultISI fields and EXP struct');

prompt = {'seek For prefISI? 1 For prefNumber? 0',...
'participartName','participartGender(FeMale 0, Male 1)','participartNote','participartPicId'};
default_ans = {num2str(CONF.defaultSeekForISI), CONF.defaultName, num2str(CONF.defaultGender), CONF.defaultNote, CONF.defaultPicID};
title = 'Config Dialog';

EXP.prefISI = CONF.defaultISI;

if CONF.debug
    % DEBUG 模式第一步或者第二步，都使用默认配置
    EXP.seekForISI = CONF.defaultSeekForISI;
    EXP.name = CONF.defaultName;
    EXP.gender = CONF.defaultGender;
    EXP.note = CONF.defaultNote;
    EXP.startTime = join(string(clock),'_');
    EXP.picID = CONF.defaultPicID;
else
    % 正式实验，如果第一步，则只弹一个对话框。
    % 如果第二步，则弹两个对话框
    anst = inputdlg(prompt, title, 1, default_ans);
    if ~isempty(anst)
        EXP.seekForISI = str2double(anst{1,1});
        EXP.name = anst{2,1};
        EXP.gender = str2double(anst{3,1});
        EXP.note = anst{4,1};
        EXP.startTime = join(string(clock),'_');
        EXP.picID = anst{5,1};
    else
        error('此步骤不可跳过，如果希望使用默认配置，请点击确定从文本框中解析值并使用，请勿点击关闭窗口');
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
