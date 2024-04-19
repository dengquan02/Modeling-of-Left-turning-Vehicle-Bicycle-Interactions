%做E的交互图
function [trajectory_block] = inter(trajectory_block,benchmark_E,Num_No,Num_V)
index = 2;%轨迹编号
X_dis = [];%各轨迹的最大偏移距离
Y_dis = [];%最大偏移距离发生时的纵向距离
inter_dis = [];%最大偏移距离发生时的最近交互对象的交互距离
inter_X = [];
while index<=trajectory_block(size(trajectory_block,1),1)
    extract = trajectory_block(find(trajectory_block(:,1)==index),:);%提取出处理的轨迹
%     plot(extract(:,2),extract(:,10),'k');%时间与速度的关系
%     hold on
%     plot(extract(:,2),extract(:,13),'r');%时间与偏向角的关系
%     title(['第',num2str(index),'号轨迹的速度图']); %设置标题
    X_dis = [X_dis;min(extract(:,5))];%求本轨迹最远偏移距离
    Y_dis = [Y_dis;mean(extract((extract(:,5)==min(extract(:,5))),4))];%最远偏移距离的纵坐标
    extract_far = extract((extract(:,5)==min(extract(:,5))),:);%找到最远偏移距离的那个时刻；
    extract_far = extract_far(1,:);%有多个最小值的，只留一个就行了
    extract_far(:,1:3) = [];
    extract_far = reshape(extract_far,11,[])';%变化维度
    extract_far(find(extract_far(:,11)==0),:)=[];%去掉空值
end
    %以下是找了一下交互距离最短的点
%     d = zeros(size(extract_far,1)-1,3);%存在距离
%     d(:,1) = extract_far(2:size(extract_far,1),1)-extract_far(1,1);
%     d(:,2) = extract_far(2:size(extract_far,1),2)-extract_far(1,2);
%     d(:,3) = sqrt(d(:,1).^2+d(:,2).^2);%欧式距离
%     ID = find(d(:,3)==min(d(:,3)));%找到最小的一个
%     if ~isempty(d)
%         inter_dis = [inter_dis;min(d(:,3))];%将最短交互距离保存下来
%         inter_X = [inter_X;extract_far(ID(1,1)+1,2)];%将最近交互的横向坐标
%     else
%         inter_dis = [inter_dis;0];%若是空集，就填上0
%         inter_X = [inter_X;0];
%     end
%     if size(inter_X,1)~=size(X_dis,1)
%         disp(index);
%     end
%     inter_one = extract_far(ID+1,:);%最短交互距离的个体所有信息
%     inter_one = [extract_far(1,:);inter_one];%主体和交互个体放到一块儿
    %找交互距离最短的点end
%     hold on
%     plot(inter_one(:,1),inter_one(:,2));    
        
%     以下是做每个轨迹的移动图
%     index_ID = 1;%轨迹点编号
    for index_ID = 1:22%size(extract,1)
         extract_point = extract(index_ID,:);
         extract_point(:,1:3) = [];%去掉前面没有用的编号和时间；
         own = extract_point(1:11);%这是预测主体的坐标和类型
         NV = extract_point(12:Num_No*11+11);%这是交互非机动车的坐标和类型
         V = extract_point(Num_No*11+12:size(extract_point,2));%这是交互机动车的坐标和类型
         NV = reshape(NV,11,[])';
         V = reshape(V,11,[])';
         NV(find(NV(:,11)==0),:)=[];
         V(find(V(:,11)==0),:)=[];
         %做图
         figure(1)
         
         clf;
         scatter(benchmark_E(:,1),benchmark_E(:,2),'o','k')
         axis([0 50 10 35]); % 设置坐标轴在指定的区间
         hold on
         scatter(own(:,1),own(:,2),'*','b')%预测主体的点
         axis([0 50 10 35]); % 设置坐标轴在指定的区间
         hold on 
         if ~isempty(NV)
         scatter(NV(:,1),NV(:,2),'*','r')%交互非机动车的点
         axis([0 50 10 35]); % 设置坐标轴在指定的区间
         end
         hold on
         if ~isempty(V)
         scatter(V(:,1),V(:,2),'*','m')%交互机动车的点
         axis([0 50 10 35]); % 设置坐标轴在指定的区间
         end
         title(['第',num2str(index),'号轨迹，第',num2str(index_ID),'个轨迹点']); %设置标题
         pause(0.1)
    end
    index = index+1;
end
% end
%做图，最大偏移距离与当时的最短交互距离的点图，稍后做相关性
scatter(inter_X,X_dis,'.','*');

% 做了一下最大横向偏移的直方图
X_dis = 27 - X_dis(:,1);
for i =1: size(X_dis,1)
       if X_dis (i,1)<0
          X_dis(i,1)=0;
       end
end
% X_dis(find(X_dis==0))=[];
intrusion = [X_dis Y_dis];%横纵向距离弄到一块儿
int_1 = intrusion(((35<intrusion(:,2))&(intrusion(:,2)<40.5)),:);%很小的一个纵向区间
int_2 = intrusion(((0.5<intrusion(:,1))&(intrusion(:,1)<1)),:);%很小的一个横向区间,将横向距离切片
scatter(int(:,1),int(:,2),'*','r');%很小的一个纵向区间的图
hist(int(:,1));%对很小的一个纵向区间内的横向偏移距离做分布
hist(int_2(:,2));%对
scatter(X_dis,Y_dis,'*','r');
hist(X_dis);
hist(Y_dis);

%做一下返回行为的距离图
% index = 1;%轨迹编号
% dis = [];
% while index<=trajectory_block(size(trajectory_block,1),1)
%     extract = trajectory_block(find(trajectory_block(:,1)==index),:);%提取出处理的轨迹
%     for i =1:size(extract,1)-1
%         if extract(i,5)<27&&extract(i+1,5)>27%若满足返回条件
%             dis = [dis;0.5*(extract(i,4)+extract(i+1,4))]; %算一下平均值吧
%         end
%     end
%     index = index +1;
% end
% dis = dis -3;
% hist(dis);

