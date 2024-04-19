[input]=xlsread('E:\Prediction_NV\Data_preprocessing\数据清洗整理\原始数据\昌吉东路墨玉路机动车.xlsx',1);
%datdawash
%寻找起终点在特定区域的轨迹
%去除问题数据
input(:,1)=[];
scatter(input(:,2),input(:,3),'.','r');%做图
N=sum(isnan(input(:,1)));%计算轨迹个数
n=0;
for i=1:size(input,1)%给同一个轨迹编上号
    s=isnan(input(i,1));
    if s==1
       n=n+1;
       input(i,12)=n;
    else
       input(i,12)=n;
    end
end
for i=1:size(input,1)%剔除错误点
    if 18<input(i,2)||input(i,2)<-4||60<input(i,3)||input(i,3)<0%剔除条件，孤立点
       aaa1=input(i,12);%读取轨迹编号
       for i2=1:size(input,1)%找到轨迹的起终点
          if input(i2,12)==aaa1
             input(i2,:)=nan;%编上号1表示是直行非机动车
          end
       end
    end
end

for i=1:size(input,1)%给同一轨迹的每个轨迹点编号
    s2=isnan(input(i,1)); 
    if s2==1
       n_in=0;
    else
       n_in=n_in+1;
    end
    input(i,13)=n_in;
end
% AA=0;
% AAA=0;
% for i=1:size(input,1)%找到轨迹的起终点
%     if input(i,13)==1&&4<input(i,2)&&input(i,2)<18&&-10<input(i,3)&&input(i,3)<60%判断起点是否在指定区域
%         AAA=AAA+1;
%         sp=i;
%            while input(sp+1,13)~=0%找到对应的终点
%                if (sp+1)>=size(input,1)
%                    break
%                else
%                    sp=sp+1; 
%                end
%            end
%         if -10<input(sp,2)&&input(sp,2)<38&&-10<input(sp,3)&&input(sp,3)<70%判断终点是否在指定区域
%            AA=AA+1;
%              aaa=input(i,12);%读取轨迹编号
%                for i1=1:size(input,1)%找到轨迹的起终点
%                    if input(i1,12)==aaa
%                        input(i1,14)=1;%编上号1表示是直行非机动车
%                        input(i1,15)=AA;
%                    end
%                end
%         end
%     end
% end
% 
% for i=1:size(input,1)%将不是直行的轨迹点弄成nan
%     if input(i,14)~=1
%         input(i,:)=nan;
%     end
% end
for i=1:size(input,1)
    input(i,16)=3;%编上号3表示是机动车
end     
scatter(input(:,2),input(:,3),'.','r');%做图
output=input(~any(isnan(input),2),:);%删掉nan
output(:,14)=[];
%output(:,4:11)=[];
output_cell = num2cell(output); 
% title = {'GlobalTime', 'X[m]', 'Y[m]','ID','ID_in','ID_straight','type'}; 
title = {'GlobalTime', 'X[m]', 'Y[m]','Vx[m/s]','Vy[m/s]','Ax[m/s2]','Ay[m/s2]','Speed[km/h]','Acceleration[m/s2]','Space[m]','Curvature[1/m]','ID','ID_in','ID_straight','type'}; 
result = [title; output_cell];
s = xlswrite('data.xlsx',result,9);  

        