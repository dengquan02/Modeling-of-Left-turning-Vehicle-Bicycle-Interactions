function [path,max_dis] = longest_path(DAG,extract_one,NUm,benchmark_risk,perception_Radius,all_risk)
%%第二次修改的代码%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%long_path是最长路径，max_dis是最长路径的收益，DAG是有向图
%通过贪婪算法计算最长路径
%即每一步都是最长的，最终就是最长的
%找到起点，起点位于时间搓1，纵向位置0，横向位置1
%初始化
% NUm = 3;
% origin = find((DAG(1,:)==1)&(DAG(3,:)==0)&(DAG(4,:)==1));%找到源点
% long_path = zeros(NUm,1);
% long_path(:,:) = origin;%最长路径序号,第一个是源点,三行，每次根据最后一个点寻找下一步
% max_dis = [0;0;0];%叠加的收益值
% time_step = 1;
% 
% while time_step<DAG(1,size(DAG,1))
%     long_path_time = [];%当前步长的路径序号
%     dis = zeros(NUm*3,1);
%     for i = 1:size(long_path,1)%对于每个源点,找到其下一步的点
%         left = find((DAG(1,:)==DAG(1,long_path(i,size(long_path,2)))+1)&(DAG(3,:)==DAG(3,long_path(i,size(long_path,2)))+1)&(DAG(4,:)==DAG(4,long_path(i,size(long_path,2)))+1));%找到后一个时刻左边的点
%         right = find((DAG(1,:)==DAG(1,long_path(i,size(long_path,2)))+1)&(DAG(3,:)==DAG(3,long_path(i,size(long_path,2)))-1)&(DAG(4,:)==DAG(4,long_path(i,size(long_path,2)))+1));%找到后一个时刻右边的点
%         next = find((DAG(1,:)==DAG(1,long_path(i,size(long_path,2)))+1)&(DAG(3,:)==DAG(3,long_path(i,size(long_path,2))))&(DAG(4,:)==DAG(4,long_path(i,size(long_path,2)))+2));%找到后一个时刻前方的点
% %       fixed = find((DAG(1,:)==DAG(1,origin)+1)&(DAG(3,:)==DAG(3,origin))&(DAG(4,:)==DAG(4,origin)));%找到后一个时刻固定不动的点
%         llong = [long_path(i,:) left;long_path(i,:) right; long_path(i,:) next];%该步长的路径
%         long_path_time = [long_path_time;llong];%叠加一步，现在一共有九条路径
%         dis(((i-1)*3)+1,1) = max_dis(i,:) + DAG(long_path(i,size(long_path,2)),left);%第i个点的左边
%         dis(((i-1)*3)+2,1) = max_dis(i,:) + DAG(long_path(i,size(long_path,2)),right);%第i个点的右边
%         dis(((i-1)*3)+3,1) = max_dis(i,:) + DAG(long_path(i,size(long_path,2)),next);%第i个点的中间
%     end
%     %寻找最长的三条路径
%     long_path_time = [dis long_path_time];%给路径编上序号,第1列
%     long_path_time = sortrows(long_path_time, -1);
%     long_path = long_path_time(1:NUm,2:size(long_path_time,2));%读取最优三条路径
% %     disp(long_path)
%     max_dis = long_path_time(1:NUm,1);%读取最优三个收益指
%     time_step = time_step + 1;
% end
% 
% %找到最终最优路径
% long_path_time(:,1) = [];%删掉前面上一把的dis
% long_path_time = [dis long_path_time];%给路径编上序号,第1列
% long_path_time = sortrows(long_path_time, -1);
% long_path = long_path_time(1,2:size(long_path_time,2));%读取最优三条路径
% max_dis = long_path_time(1,1);%读取最优三个收益指
% 
% %把最长路径还原成坐标
% path = zeros(size(long_path,2),2);
% path(1,:) = extract_one(1,4:5);%放入主体坐标 
% for i = 1:size(long_path,2)
%     path(i+1,:) = DAG(long_path(i),5:6);%提取每个离散点的坐标
% end 

%%第一次的代码%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%下面是原来代码
% origin = find((DAG(1,:)==1)&(DAG(3,:)==0)&(DAG(4,:)==1));%找到源点
% long_path = [];%最长路径序号
% max_dis = 0;%叠加的收益值
% time_step = 1;
% while time_step<DAG(1,size(DAG,1))
%    left = find((DAG(1,:)==DAG(1,origin)+1)&(DAG(3,:)==DAG(3,origin)+1)&(DAG(4,:)==DAG(4,origin)+1));%找到后一个时刻左边的点
%    right = find((DAG(1,:)==DAG(1,origin)+1)&(DAG(3,:)==DAG(3,origin)-1)&(DAG(4,:)==DAG(4,origin)+1));%找到后一个时刻右边的点
%    next = find((DAG(1,:)==DAG(1,origin)+1)&(DAG(3,:)==DAG(3,origin))&(DAG(4,:)==DAG(4,origin)+2));%找到后一个时刻前方的点
% %    fixed = find((DAG(1,:)==DAG(1,origin)+1)&(DAG(3,:)==DAG(3,origin))&(DAG(4,:)==DAG(4,origin)));%找到后一个时刻固定不动的点
%    ID_dis = [left right next;DAG(origin,left) DAG(origin,right) DAG(origin,next)];%第一行是ID（DAG的），第二行是他们的综合收益  ID_dis = [left right next fixed;DAG(origin,left) DAG(origin,right) DAG(origin,next) DAG(origin,fixed)];
%    max_dis = max_dis + ID_dis(2,(ID_dis(2,:)==max(ID_dis(2,:))));%叠加该步长内最大收益路程
%    ID = ID_dis(1,(ID_dis(2,:)==max(ID_dis(2,:))));%找到ID  （DAG内）
%    if size(ID,2)>1%若出现两个一样的话，就随机选一个
%        ID = ID(1,randperm(size(ID,2),1));
%    end
%    long_path = [long_path ID];%叠加该步长内最大收益序号(DAG内)
%    %更新标号
%    origin = ID;%找到下个步长的源点，即现在步长的终点
%    time_step = time_step + 1;
% end
% %把最长路径还原成坐标
% path = zeros(size(long_path,2),2);
% path(1,:) = extract_one(1,4:5);%放入主体坐标 
% for i = 1:size(long_path,2)
%     path(i+1,:) = DAG(long_path(i),5:6);%提取每个离散点的坐标
% end  
% end

%%第三次的代码%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
min_risk = min(all_risk(:,7));%求最小风险值
origin = find((DAG(1,:)==1)&(DAG(3,:)==0)&(DAG(4,:)==1));%找到源点
long_path = [];%最长路径序号
max_dis = 0;%叠加的收益值
time_step = 1;
while time_step<DAG(1,size(DAG,1))
   left = find((DAG(1,:)==(DAG(1,origin)+1))&(DAG(3,:)==(DAG(3,origin)-1))&(DAG(4,:)==(DAG(4,origin)+1)));%找到后一个时刻左边的点
   right = find((DAG(1,:)==(DAG(1,origin)+1))&(DAG(3,:)==(DAG(3,origin)+1))&(DAG(4,:)==(DAG(4,origin)+1)));%找到后一个时刻右边的点
   next = find((DAG(1,:)==(DAG(1,origin)+1))&(DAG(3,:)==(DAG(3,origin)))&(DAG(4,:)==(DAG(4,origin)+2)));%找到后一个时刻前方的点
%    fixed = find((DAG(1,:)==DAG(1,origin)+1)&(DAG(3,:)==DAG(3,origin))&(DAG(4,:)==DAG(4,origin)));%找到后一个时刻固定不动的点
   ID_dis = [left right next;DAG(origin,left) DAG(origin,right) DAG(origin,next)];%第一行是ID（DAG的），第二行是他们的风险  ID_dis = [left right next fixed;DAG(origin,left) DAG(origin,right) DAG(origin,next) DAG(origin,fixed)];
   if DAG(origin,next)<benchmark_risk%若直走的风险比较低，下一步就直走
       max_dis = max_dis + perception_Radius*2;
       best_ID = ID_dis(1,3);%找到ID
   else%否则的话，就计算三个方向的综合收益综合收益
       ID_dis(2,1) = perception_Radius*(1-((DAG(origin,left)-min_risk)/(benchmark_risk-min_risk)));
       ID_dis(2,2) = perception_Radius*(1-((DAG(origin,right)-min_risk)/(benchmark_risk-min_risk)));
       ID_dis(2,3) = perception_Radius*2*(1-((DAG(origin,next)-min_risk)/(benchmark_risk-min_risk)));
       max_dis = max_dis + ID_dis(2,(ID_dis(2,:)==max(ID_dis(2,:))));%叠加该步长内最大收益路程
       best_ID = ID_dis(1,(ID_dis(2,:)==max(ID_dis(2,:))));%找到ID  （DAG内）
       if size(best_ID,2)>1%若出现两个一样的话，就随机选一个
          best_ID = best_ID(1,randperm(size(best_ID,2),1));
       end
   end
   long_path = [long_path best_ID];%叠加该步长内最大收益序号(DAG内)
   %更新标号
   origin = best_ID;%找到下个步长的源点，即现在步长的终点
   time_step = time_step + 1;
end
%把最长路径还原成坐标
path = zeros(size(long_path,2),2);
path(1,:) = extract_one(1,4:5);%放入主体坐标 
for i = 1:size(long_path,2)
    path(i+1,:) = DAG(long_path(i),5:6);%提取每个离散点的坐标
end  

end
