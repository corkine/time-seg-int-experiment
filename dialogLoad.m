function CONF = dialogLoad(CONF)
%DIALOGLOAD 从对话框中加载配置，结果写入 CONF struct 中。参见 CONFIGLOAD。
%CONF struct should contains debug, seekForISI, name, gender, note fields。
%   如果是 debug 模式，则返回，反之，如果取消，则返回，如果确定则返回设定后的值。

assert(nargin > 0, ...
'Should Input CONF struct contains debug, seekForISI, name, gender, note fields');

prompt = {'seek For prefISI? 1 For prefNumber? 0',...
'participartName','participartGender(FeMale 0, Male 1)','participartNote'};
default_ans = {num2str(CONF.seekForISI), CONF.name, num2str(CONF.gender), CONF.note};
title = 'Config Dialog';

if CONF.debug
    return;
else
    anst = inputdlg(prompt, title, 1, default_ans);
    if isempty(anst)
        return;
    else
        CONF.seekForISI = str2double(anst{1,1});
        CONF.name = anst{2,1};
        CONF.gender = str2double(anst{3,1});
        CONF.note = anst{4,1};
        CONF.startTime = join(string(clock),'_');
    end
end
end