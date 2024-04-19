%% 输入数据
[input_NV]=xlsread('E:\Prediction_of_BIM\DataSet\MyData\剑河路仙霞西路总数据\东进口直行非机动车\东进口直行非机动车.xlsx',1);%读取仙霞路的东进口直行非机动车
[input_V_east]=xlsread('E:\Prediction_of_BIM\DataSet\MyData\剑河路仙霞西路总数据\东进口直行机动车\东进口直行机动车.xlsx',1);%读取仙霞路的东进口直行机动车
[input_V_westLeft]=xlsread('E:\Prediction_of_BIM\DataSet\MyData\剑河路仙霞西路总数据\西进口左转机动车\西进口左转机动车原始数据.xlsx',1);%读取仙霞路的西进口左转机动车

%% datdawash 东进口直行非机动车
%去除问题数据
input_NV(:,1)=[];
% scatter(input_NV(:,2),input_NV(:,3),'.','r');%做图
N=sum(isnan(input_NV(:,1)));%计算轨迹个数
n=0;
for i=1:size(input_NV,1)%给同一个轨迹编上号
    s=isnan(input_NV(i,1));
    if s==1
       n=n+1;
       input_NV(i,12)=n;
    else
       input_NV(i,12)=n;
    end
end
data = [];
index = 1;%计数
for i=1:input_NV(size(input_NV,1),size(input_NV,2))%剔除错误点
    exter = input_NV(find(input_NV(:,size(input_NV,2))==i),:);%提取当前轨迹
    exter(find(isnan(exter(:,2))),:) = [];%去掉nan行
    if isempty(exter) == 1
        continue
    end
    v_conu = sum(sign(exter(size(exter,1)-10:size(exter,1),4)));
    if sum(exter(:,2)>25)&&(v_conu>8)||sum((exter(:,2)<10))%剔除条件，道路右边离开非机动车没有回来的，就是未继续直行的轨迹（横坐标大于25，最后11个点的横向加速度有8个出去的就剔除掉）
        continue
    else
        exter(:,size(exter,2)) = index;%编上新序号
        data = [data ; exter];
        index = index +1;
    end 
end
data = [data zeros(size(data,1),1)];
index_in = 2;%计数开始
data(1,13) = 1;%先填上第一个编号吧
for i=2:size(data,1)%给同一轨迹的每个轨迹点编号
    if data(i,12) == data(i-1,12)%如果当前轨迹点与前一个轨迹点属于同一个轨迹，则编号
       data(i,13) = index_in;
       index_in = index_in + 1;
    else
       data(i,13) = 1;
       index_in = 2;
    end
end



for i=1:size(data,1)%判断是电动车还是自行车
     if data(i,8)>=18%判断速度是否大于18
         aaa18=data(i,12);%读取轨迹编号
         for i1=1:size(data,1)%找到轨迹的起终点
             if data(i1,12)==aaa18
                data(i1,16)=2;%编上号2表示是电动车
             end
         end
     else
         aaa18=data(i,12);%读取轨迹编号
         for i1=1:size(data,1)%找到轨迹的起终点
             if data(i1,12)==aaa18
                data(i1,16)=1;%编上号1表示是自行车
             end
         end
     end
end       
figure(1)
scatter(data(:,2),data(:,3),'.','r');%做图
output=data(~any(isnan(data),2),:);%删掉nan
output(:,14)=[];
%output(:,4:11)=[];
output_cell = num2cell(output); 
% title = {'GlobalTime', 'X[m]', 'Y[m]','ID','ID_in','ID_straight','type'}; 
title = {'GlobalTime', 'X[m]', 'Y[m]','Vx[m/s]','Vy[m/s]','Ax[m/s2]','Ay[m/s2]','Speed[km/h]','Acceleration[m/s2]','Space[m]','Curvature[1/m]','ID','ID_in','ID_straight','type'}; 
result = [title; output_cell];
s = xlswrite('data_XXRoad.xlsx',result,1);  


%% datdawash 东进口直行机动车
%去除问题数据,扭转角度，偏移3.76°
input_V_east(:,1)=[];
% figure(2)
% scatter(input_V_east(:,2),input_V_east(:,3),'.','r');%做图
for i = 1:size(input_V_east,1)%将所有带有坐标式的值都偏移3.76度
    for j = 2:2:7
        [theta,r] = cart2pol(input_V_east(i,j),input_V_east(i,j+1));
        [input_V_east(i,j),input_V_east(i,j+1)] = pol2cart(deg2rad(rad2deg(theta)+3.76),r);
    end
end
        
N=sum(isnan(input_V_east(:,1)));%计算轨迹个数
n=0;
for i=1:size(input_V_east,1)%给同一个轨迹编上号
    s=isnan(input_V_east(i,1));
    if s==1
       n=n+1;
       input_V_east(i,12)=n;
    else
       input_V_east(i,12)=n;
    end
end
data = [];
index = 1;%计数
for i=1:input_V_east(size(input_V_east,1),size(input_V_east,2))%剔除错误点
    exter = input_V_east(find(input_V_east(:,size(input_V_east,2))==i),:);%提取当前轨迹
    exter(find(isnan(exter(:,2))),:) = [];%去掉nan行
    if isempty(exter) == 1
        continue
    end
    v_conu = sum(sign(exter(size(exter,1)-10:size(exter,1),4)));
    if sum(exter(:,2)>21)&&(v_conu>8)||sum((exter(:,2)<10))%剔除条件，道路右边离开非机动车没有回来的，就是未继续直行的轨迹（横坐标大于25，最后11个点的横向加速度有8个出去的就剔除掉）
        continue
    else
        exter(:,size(exter,2)) = index;%编上新序号
        data = [data ; exter];
        index = index +1;
    end 
end
data = [data zeros(size(data,1),1)];
index_in = 2;%计数开始
data(1,13) = 1;%先填上第一个编号吧
for i=2:size(data,1)%给同一轨迹的每个轨迹点编号
    if data(i,12) == data(i-1,12)%如果当前轨迹点与前一个轨迹点属于同一个轨迹，则编号
       data(i,13) = index_in;
       index_in = index_in + 1;
    else
       data(i,13) = 1;
       index_in = 2;
    end
end



for i=1:size(data,1)%判断是电动车还是自行车
     if data(i,8)>=18%判断速度是否大于18
         aaa18=data(i,12);%读取轨迹编号
         for i1=1:size(data,1)%找到轨迹的起终点
             if data(i1,12)==aaa18
                data(i1,16)=3;%编上号3表示全是机动车
             end
         end
     else
         aaa18=data(i,12);%读取轨迹编号
         for i1=1:size(data,1)%找到轨迹的起终点
             if data(i1,12)==aaa18
                data(i1,16)=3;%编上号3表示全是机动车
             end
         end
     end
end       
figure(2)
scatter(data(:,2),data(:,3),'.','r');%做图
output=data(~any(isnan(data),2),:);%删掉nan
output(:,14)=[];
%output(:,4:11)=[];
output_cell = num2cell(output); 
% title = {'GlobalTime', 'X[m]', 'Y[m]','ID','ID_in','ID_straight','type'}; 
title = {'GlobalTime', 'X[m]', 'Y[m]','Vx[m/s]','Vy[m/s]','Ax[m/s2]','Ay[m/s2]','Speed[km/h]','Acceleration[m/s2]','Space[m]','Curvature[1/m]','ID','ID_in','ID_straight','type'}; 
result = [title; output_cell];
s = xlswrite('data_XXRoad.xlsx',result,2);  

%% datdawash 西进口左转机动车
%去除问题数据
input_V_westLeft(:,1)=[];
input_V_westLeft(:,12:size(input_V_westLeft,2))=[];
% figure(2)
% scatter(input_V_westLeft(:,2),input_V_westLeft(:,3),'.','r');%做图
% for i = 1:size(input_V_westLeft,1)%将所有带有坐标式的值都偏移3.76度
%     for j = 2:2:7
%         [theta,r] = cart2pol(input_V_westLeft(i,j),input_V_westLeft(i,j+1));
%         [input_V_westLeft(i,j),input_V_westLeft(i,j+1)] = pol2cart(deg2rad(rad2deg(theta)-3.76),r);
%     end
% end
        
N=sum(isnan(input_V_westLeft(:,1)));%计算轨迹个数
n=0;
for i=1:size(input_V_westLeft,1)%给同一个轨迹编上号
    s=isnan(input_V_westLeft(i,1));
    if s==1
       n=n+1;
       input_V_westLeft(i,12)=n;
    else
       input_V_westLeft(i,12)=n;
    end
end
data = [];
index = 1;%计数
for i=1:input_V_westLeft(size(input_V_westLeft,1),size(input_V_westLeft,2))%剔除错误点
    exter = input_V_westLeft(find(input_V_westLeft(:,size(input_V_westLeft,2))==i),:);%提取当前轨迹
    exter(find(isnan(exter(:,2))),:) = [];%去掉nan行
    if isempty(exter) == 1
        continue
    end
    v_conu = sum(sign(exter(size(exter,1)-10:size(exter,1),4)));
    if 0>1%剔除条件，这里表示全都要
        continue
    else
        exter(:,size(exter,2)) = index;%编上新序号
        data = [data ; exter];
        index = index +1;
    end 
end
data = [data zeros(size(data,1),1)];
index_in = 2;%计数开始
data(1,13) = 1;%先填上第一个编号吧
for i=2:size(data,1)%给同一轨迹的每个轨迹点编号
    if data(i,12) == data(i-1,12)%如果当前轨迹点与前一个轨迹点属于同一个轨迹，则编号
       data(i,13) = index_in;
       index_in = index_in + 1;
    else
       data(i,13) = 1;
       index_in = 2;
    end
end



for i=1:size(data,1)%判断是电动车还是自行车
     if data(i,8)>=18%判断速度是否大于18
         aaa18=data(i,12);%读取轨迹编号
         for i1=1:size(data,1)%找到轨迹的起终点
             if data(i1,12)==aaa18
                data(i1,16)=3;%编上号3表示全是机动车
             end
         end
     else
         aaa18=data(i,12);%读取轨迹编号
         for i1=1:size(data,1)%找到轨迹的起终点
             if data(i1,12)==aaa18
                data(i1,16)=3;%编上号3表示全是机动车
             end
         end
     end
end         
figure(3)
scatter(data(:,2),data(:,3),'.','r');%做图
output=data(~any(isnan(data),2),:);%删掉nan
output(:,14)=[];
%output(:,4:11)=[];
output_cell = num2cell(output); 
% title = {'GlobalTime', 'X[m]', 'Y[m]','ID','ID_in','ID_straight','type'}; 
title = {'GlobalTime', 'X[m]', 'Y[m]','Vx[m/s]','Vy[m/s]','Ax[m/s2]','Ay[m/s2]','Speed[km/h]','Acceleration[m/s2]','Space[m]','Curvature[1/m]','ID','ID_in','ID_straight','type'}; 
result = [title; output_cell];
s = xlswrite('data_XXRoad.xlsx',result,3);  

        