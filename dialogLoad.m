function CONF = dialogLoad(CONF)
%DIALOGLOAD 从对话框中加载配置，结果写入 CONF struct 中。
%CONF 可不提供，如果提供，务必包含 debug 字段，布尔值。
%   如果是 debug 模式，则自动复写默认值，反之，如果取消，则返回其本身（如果没有参数。则返回空 struct），
%   如果确定则返回对话框中值（包括默认值）。

prompt = {'seek For prefISI? 0 For prefNumber? 1',...
'participartName','participartGender(FeMale 0, Male 1)','participartNote'};
default_ans = {'0','DefaultName','0','DefaltNote'};
title = 'Config Dialog';

if nargin > 0 && CONF.debug
    CONF.seekForISI = 0;
    CONF.name = 'DebugName';
    CONF.gender = 0;
    CONF.note = 'DebugNote'; 
    return;
else
    anst = inputdlg(prompt, title, 1, default_ans);
    if isempty(anst)
        if nargin > 0
            return;
        else
            CONF = struct;
            return;
        end
    else
        CONF.seekForISI = str2double(anst{1,1});
        CONF.name = anst{2,1};
        CONF.gender = str2double(anst{3,1});
        CONF.note = anst{4,1};
    end
end
end