function [output] = Risk_Perception(Risk,main,long_Per,short_Per)
%计算预测主体的危险度感知值
% main = extract(1,:);
Risk_all = Risk;
Risk_all(:,1) = Risk(:,1)-main(1,1);%变换坐标
Risk_all(:,2) = Risk(:,2)-main(1,2);
[Risk_pol(:,1),Risk_pol(:,2)] = cart2pol(Risk_all(:,1),Risk_all(:,2));%将直角坐标转换为极坐标； 第1列是角度，第2列是极径
Risk_pol(:,1) = Risk_pol(:,1) + 0;%变换角度  Risk_pol(:,1) = Risk_pol(:,1) + main(1,10);%变换角度
Nu = zeros(size(Risk_pol,1),1);%是否在椭圆内
ecc = (long_Per^2-short_Per^2)^0.5/(long_Per);%离心率，通过长短轴进行计算

for i = 1:size(Risk_pol,1)%对每个点来说，查看他是否在椭圆内
    radius = long_Per*(1-ecc^2)/(1-ecc*cos(Risk_pol(i,1)));%对于当前角度，其椭圆的半径是radius
    if Risk_pol(i,2) <= radius  %如果他的长度小于他的换算长度
        Nu(i,1) = 1;%在椭圆内的标为1
    end
end
output = sum(Nu);
end
    
    

