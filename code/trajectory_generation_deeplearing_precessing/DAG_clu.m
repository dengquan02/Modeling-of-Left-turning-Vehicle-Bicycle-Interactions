function [DAG] = DAG_clu(all_risk,benchmark_risk)
%构造有向图
%all_risk是离散化后的点和风险 ,第5列是x，后面是y
%benchmark_risk是基准风险，最小的可以现算
% benchmark_risk = 40;%这个是瞎弄的
min_risk = min(all_risk(:,7));
DAG = [zeros(size(all_risk,2)) all_risk';all_risk zeros(size(all_risk,1))];%构造邻接矩阵
%下面开始赋值
for i =8:size(DAG,1)
    for j =8:size(DAG,2)
        if DAG(i,j)==0
            DAG(i,j)=-inf;%先将所有值都赋予-inf
        end
    end
end

for i =1:size(DAG,1)
    if DAG(i,1)~=0
        time_step = DAG(i,1);%提取时间戳
        longcood = DAG(i,3);%提取纵坐标
        crosscood = DAG(i,4);%提取横坐标
        left = find((DAG(1,:)==time_step+1)&(DAG(3,:)==longcood-1)&(DAG(4,:)==crosscood+1));%找到后一个时刻左边的点
        right = find((DAG(1,:)==time_step+1)&(DAG(3,:)==longcood+1)&(DAG(4,:)==crosscood+1));%找到后一个时刻右边的点
        next = find((DAG(1,:)==time_step+1)&(DAG(3,:)==longcood)&(DAG(4,:)==crosscood+2));%找到后一个时刻前方的点
%         fixed = find((DAG(1,:)==time_step+1)&(DAG(3,:)==longcood)&(DAG(4,:)==crosscood));%找到后一个时刻固定不动的点
        connection = [left right next];%有可能四个连接点不全
%         DAG(i,fixed) = 0;%位置没动的收益就定为0吧
        if length(connection)>1%找到这个点的所有连接点
            for j = 1:size(connection,2)
%                 reduction = 1-((DAG(connection(j),7)-min_risk)/(benchmark_risk-min_risk));%计算风险折减系数，大于1则表示负值
                DAG(i,connection(j)) = DAG(connection(j),7);%行程收益*折减系数   改变计算方法，去掉了核减系数，包括上一行和这一行   DAG(i,connection(j)) = (abs(DAG(i,5)-DAG(connection(j),5)))*(reduction);%行程收益*折减系数
            end
        end
    end
end


end

% x=(0:0.1:10);
% scatter(x,1-((x-0.1)/(2-0.1)))