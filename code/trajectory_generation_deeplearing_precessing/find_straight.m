function [output] = find_straight(E1,start_x_0,start_x_1,start_y_0,start_y_1,end_x_0,end_x_1,end_y_0,end_y_1)
%后面参数分别表示起点左右下上约束，终点左右下上约束
input = E1;
add = zeros(size(E1,1),2);
input = [input add];
AA=0;
AAA=0;
for i=1:size(input,1)%找到轨迹的起终点
    if input(i,12)==1&&start_x_0<input(i,2)&&input(i,2)<start_x_1&&start_y_0<input(i,3)&&input(i,3)<start_y_1%判断起点是否在指定区域，input(i,12)==1表示第一个点
        sp=i;
        AAA=AAA+1;
           while input(sp,12)<input(sp+1,12)%找到对应的终点(只要后一个编号小于前一个编号，说明换轨迹了，此时的sp对应的就是终点)
               if (sp+1)>=size(input,1)
                   break
               else
                   sp=sp+1; 
               end
           end
        if end_x_0<input(sp,2)&&input(sp,2)<end_x_1&&end_y_0<input(sp,3)&&input(sp,3)<end_y_1%判断终点是否在指定区域
           AA=AA+1;
             aaa=input(i,13);%读取轨迹编号
               for i1=1:size(input,1)%找到轨迹的起终点
                   if input(i1,13)==aaa
                       input(i1,15)=1;%编上号1表示是直行非机动车
                       input(i1,16)=AA;
                   end
               end
        end
    end
end

for i=1:size(input,1)%将不是直行的轨迹点弄成nan
    if input(i,15)~=1
        input(i,:)=nan;
    end
end
% scatter(input(:,2),input(:,3),'.','r');%做图
% scatter(E1(:,2),E1(:,3),'.','r');%做图
output=input(~any(isnan(input),2),:);%删掉nan
output(:,15)=[];%删掉表示直行的编号
output(:,13)=[];%删掉旧编号ID
end

