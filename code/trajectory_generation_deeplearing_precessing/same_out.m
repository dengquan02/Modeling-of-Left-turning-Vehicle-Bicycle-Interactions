function [output_E] = same_out(E1)
%%%%做单独一条轨迹的图%%%%%
% shunxu = 649;
% figure(2);
% while shunxu<=E1(size(E1,1),5)
% clf %清除前面的图用的
% current = E1(find(E1(:,5)==shunxu),:);
% scatter(current(:,2),current(:,3),'*','r');%预测数据
% title(['编号为',num2str(shunxu)]);
% pause(0.2)
% shunxu = shunxu+1;
% end
%%%去除相同的数据
index = max(E1(:,12));%求出最大轨迹点数
E = [];
for i = 1:E1(size(E1,1),13)
    alone = zeros(1,index*14);%存放每个轨迹的矩阵
    current = E1(find(E1(:,13)==i),:);
%     current_out_in_X = unique(current(:,2));%若x出现相同的则不要这个数据了
%     current_out_in_Y = unique(current(:,3));%若y出现相同的则不要这个数据了
%     if size(current,1)/size(current_out_in_X,1)>2||size(current,1)/size(current_out_in_Y,1)>2
%         break
%     end
    current(:,13)=[];
    current = reshape(current',1,[]);%resap是竖着数的
    alone(1,1:size(current,2)) = current;
    E = [E;alone];
end
E_handle = unique(E,'rows');  
output_E =[];
index = 1;
for i = 1:size(E_handle ,1)
    if mod(size(E_handle,2),13) ~=0
       alone = [E_handle(i,:),zeros(1,13-mod(size(E_handle,2),13))];
    else
       alone = E_handle(i,:);
    end
    current_after = reshape(alone,13,[])';
    current_after(find(current_after(:,1)==0),:)=[];
    current_after(:,13) = max(current_after(:,13));%把类型搞清楚，不要模棱两可
    if ~isempty(current_after)
            index_M = zeros(size(current_after,1),1);
            index_M(:,1) = index;%赋予新编号
            current_after = [current_after(:,1:12),index_M,current_after(:,13)];
            output_E = [output_E;current_after];
            index = index + 1;
    end
end
end


%     %做图
%     figure(2);
  
%     for i = 1:size(E,1)
%         clf %清除前面的图用的
%        for j = 1:5:size(E,2)
%            scatter(E(i,j+1),E(i,j+2),'*','r');%预测数据
%            hold on
%        end
%        pause(0.5)
%     end
           