function [output] = chose(input,perception_Radius)
%input是一个位置
%功能是找到input的三个选择位置
output = zeros(3,2); %output按照左右中的方式排序
%left
output(1,1) = input(1,1) - perception_Radius;%左边，横坐标-半径
output(1,2) = input(1,2) - (perception_Radius*3^0.5);%左边，横坐标-3^0.5*半径
%right
output(2,1) = input(1,1) - perception_Radius;%y右边，横坐标-半径
output(2,2) = input(1,2) + (perception_Radius*3^0.5);%右边，横坐标-3^0.5*半径
%next
output(3,1) = input(1,1) -(perception_Radius*2);%中间，横坐标减掉两个半径
output(3,2) = input(1,2);%中间，纵坐标相等
end

