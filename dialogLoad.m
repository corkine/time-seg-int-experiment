function CONF = dialogLoad(CONF)
%DIALOGLOAD 从对话框中加载配置，结果写入 CONF struct 中。参见 CONFIGLOAD。
%CONF struct should contains debug, seekForISI, name, gender, note fields。
%   如果是 SeekForISI 第一部分，如果是 debug 模式，则返回，反之，如果取消，则返回，如果确定则返回设定后的值。
%   如果是 SeekForNumber 第二部分，则继续弹出对话框要求被试输入计算的 prefISI 以供接下来的实验

assert(nargin > 0, ...
'Should Input CONF struct contains debug, seekForISI, name, gender, note fields');

prompt = {'seek For prefISI? 1 For prefNumber? 0',...
'participartName','participartGender(FeMale 0, Male 1)','participartNote','participartPicId'};
default_ans = {num2str(CONF.seekForISI), CONF.name, num2str(CONF.gender), CONF.note, CONF.picID};
title = 'Config Dialog';

% DEBUG 模式第一步或者第二步，都使用默认配置
if CONF.debug
    CONF.startTime = join(string(clock),'_');
    return;
else
% 正式实验，如果第一步，则只弹一个对话框。
% 如果第二步，则弹两个对话框
    anst = inputdlg(prompt, title, 1, default_ans);
    if isempty(anst)
        return;
    else
        CONF.seekForISI = str2double(anst{1,1});
        CONF.name = anst{2,1};
        CONF.gender = str2double(anst{3,1});
        CONF.note = anst{4,1};
        CONF.startTime = join(string(clock),'_');
        CONF.picID = anst{5,1};
    end
    CONF = getPrefISI(CONF);
end
end

function CONF = getPrefISI(CONF)
    if ~CONF.seekForISI
        anste = inputdlg({'prefISI'}, 'PrefISI Load Dialog', 1, {char(CONF.prefISI)}); 
        if isempty(anste)
            fprintf('%-20s Not load prefISI... Use Default %2.2f now...\n', '[MAIN][CONFIG]', CONF.prefISI);
            return;
        else
            CONF.prefISI = str2double(anste{1,1});
            fprintf('%-20s Setting prefISI %2.2f for %s now...\n', '[MAIN][CONFIG]', CONF.prefISI, CONF.name);
        end
    else
        fprintf('%-20s Dialog Get Conf.seekForISI for %s with pic %s\n', '[MAIN][CONFIG]', CONF.name, CONF.picID);
    end 
end
