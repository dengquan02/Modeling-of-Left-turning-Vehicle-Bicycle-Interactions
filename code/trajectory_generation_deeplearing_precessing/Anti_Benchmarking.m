function [prediction,T_V] = Anti_Benchmarking(tt_t,yy_y)
%基准点为非机动车和机动车边界，停车线的点    point_N=(12.5,50)   point_E=(47.43, 25.49)
%从基准点轴向上的比例转化为坐标点
T_V=zeros(size(tt_t,1),size(tt_t,2));
prediction=zeros(size(yy_y,1),size(yy_y,2));
for i=1:3:size(tt_t,2) %列
    for j=1:size(tt_t,1)
        T_V(j,i)=(tt_t(j,i)*(15-47.43))+47.43;  %x值
        T_V(j,i+1)=(tt_t(j,i+1)*(35-25.49))+25.49;   %y值
    end
end
for i=1:3:size(yy_y,2) %列
    for j=1:size(yy_y,1)
        prediction(j,i)=(yy_y(j,i)*(15-47.43))+47.43;  %x值
        prediction(j,i+1)=(yy_y(j,i+1)*(35-25.49))+25.49;   %y值
    end
end
end

