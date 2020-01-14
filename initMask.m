function [Stimuli] = initMask(SCR, CONF)
% ���㲢����������ڰ� Mask

    Stimuli.ObjAreaSizeP = CONF.cheeseRow * CONF.cheeseGridWidth * 1.6;
    Stimuli.MaskRectSizeP = CONF.cheeseGridWidth / 5;

    %% masks 
    %�˴�mask��ʱ�Ǵ�С��ͬ����ɫ�������ɫ����
    % loc  
    Stimuli.MaskRectNum = ceil(Stimuli.ObjAreaSizeP/Stimuli.MaskRectSizeP); % num = length/size
    Stimuli.PointMetrix = combineFactors(0:Stimuli.MaskRectNum-1,0:Stimuli.MaskRectNum-1);   % mask��ÿ��С���鶼������ĳһ�У�ͬ�е�x������ͬ����Ȼ���ٹ�����ĳһ�У�ͬ�е�y������ͬ����
    Stimuli.referencePoint = [SCR.x - Stimuli.ObjAreaSizeP/2, SCR.y - Stimuli.ObjAreaSizeP/2];%���ϽǶ�������
    LeftUpPoints(:,1) = Stimuli.PointMetrix(:,1) * Stimuli.MaskRectSizeP+Stimuli.referencePoint(1,1);%����rect�����Ͻ�����
    LeftUpPoints(:,2) = Stimuli.PointMetrix(:,2) * Stimuli.MaskRectSizeP+Stimuli.referencePoint(1,2);
    RightBotomPoints(:,1) = LeftUpPoints(:,1) + Stimuli.MaskRectSizeP;%����rect���½�����
    RightBotomPoints(:,2) = LeftUpPoints(:,2) + Stimuli.MaskRectSizeP;
    Stimuli.MaskRects = [LeftUpPoints,RightBotomPoints];
    Stimuli.MaskRects = Stimuli.MaskRects';
    %color
    Stimuli.PointMetrixSize = size(Stimuli.MaskRects);
    rectsNum = Stimuli.PointMetrixSize(2);
    Stimuli.MaskRectsColor = ones(3,rectsNum);

    for rowindex = 1:rectsNum
        tmp1=randperm(2); %������ڰ�-�ڰ�Mask
        if tmp1(1)==1, Stimuli.MaskRectsColor(:,rowindex)=0;   end
        if tmp1(1)==2, Stimuli.MaskRectsColor(:,rowindex)=255; end
    end
    
end

function R = combineFactors(varargin)
    tmpNum = 1;
    for i=1:length(varargin)
        tmpNum = tmpNum*length(varargin{i});
    end
    R = zeros(tmpNum,length(varargin));
    for i = 1:size(R,1)
        tmp = tmpNum;
        for j = 1:length(varargin)
            if j~=1
                tmp = tmp/length(varargin{j-1});
            end
            for k = 1:length(varargin{j})
                R(i,j)=varargin{j}(ceil((mod(i-1,tmp)+1)/(tmp/length(varargin{j}))));
            end
        end
    end
end