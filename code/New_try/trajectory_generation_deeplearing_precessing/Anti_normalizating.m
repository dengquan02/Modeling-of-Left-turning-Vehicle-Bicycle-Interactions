function [tt_t,yy_y] = Anti_normalizating(tt,yy,mmax,mmin)
%反归一化
%   此处显示详细说明
tt_t=zeros(size(tt,1),size(tt,2));%tt表示真值
yy_y=zeros(size(yy,1),size(yy,2));%表示预测
for i=1:size(tt,2)
    for j=1:size(tt,1)
        tt_t(j,i)=((mmax(i)-mmin(i))*tt(j,i))+mmin(i);   %%对每列（指标）进行反归一化
    end
end
for i=1:size(yy,2)
    for j=1:size(yy,1)
        yy_y(j,i)=((mmax(i)-mmin(i))*yy(j,i))+mmin(i);   %%对每列（指标）进行反归一化
    end
end 
end

