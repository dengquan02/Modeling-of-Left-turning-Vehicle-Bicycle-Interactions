function [trajectory_block,trajectory_no] = trajectory_divide(trajectory,down,up)
%将轨迹分为越线轨迹和非越线轨迹
%fe表示一个轨迹点的参数数目
% trajectory = E;
trajectory_block = [];
trajectory_no = [];
%对于每个轨迹
index = 1;%轨迹编号
ID_block = 1;
ID_no = 1;
while index <= trajectory(size(trajectory,1),1)
    trajectory_current = trajectory((trajectory(:,1)==index),:);%找到当前数据的预测值
    index_block = 0;%越线点计数
    for j = 1:size(trajectory_current,1)
       if (trajectory_current(j,5)>up)||(trajectory_current(j,5)<down) %如果该点越线 22,26
           index_block = index_block + 1;
      end
    end
    if index_block>0 %若index>0,说明至少其中给一个点越线了，则放到干扰集
        trajectory_current(:,1) = ID_block;
        trajectory_block = [trajectory_block;trajectory_current];%干扰集
        ID_block = ID_block + 1;
    else
        trajectory_current(:,1) = ID_no;
        trajectory_no = [trajectory_no;trajectory_current];
        ID_no = ID_no + 1;
    end
    index = index + 1;
end
end

