function [output] = LIP_cal(input_trajectory_1,input_trajectory_2,ARG)
%该函数是计算LIP距离，input1表示输入数据1，input2表示输入数据2，wight表示权重取值情况，wight=1表示计算行为趋势；wight=2表示计算轨迹重合度；
%该函数计算了LIP，并且除以了真实轨迹长度，可以求的相对值，进而比较轨迹行为趋势的优劣；
% tic
%真实轨迹测试数据
% input_trajectory_1 = Truth_no(:,4:5);%表示真实数据，形式是（1+预测步长）*2    x和y
% input_trajectory_2 = output1_part;%表示预测数据，形式是（1+预测步长）*2    x和y
% ARG = 0;%取1是上下1和-1，取0是都是1；
%测试数据
% input_trajectory_1 = [0 0; 1 1; 2 0; 3 1; 4 0 ];
% input_trajectory_2 = [0 0; 1 0; 2 1; 3 0; 4 1 ];
%%
% %做图出来看一看
% plot(input_trajectory_1(:,1),input_trajectory_1(:,2),'b');
% hold on 
% scatter(input_trajectory_1(:,1),input_trajectory_1(:,2),'*','b');
% hold on 
% plot(input_trajectory_2(:,1),input_trajectory_2(:,2),'r');
% hold on 
% scatter(input_trajectory_2(:,1),input_trajectory_2(:,2),'*','r');

%% 找到两个折线的相交点，这个包括起点，并不包括终点。
cro_point = [];%存放相交点
ID_dele = [];%存放需要删掉的相交点，就是当两个线段完全重合的时候
for i = 1:size(input_trajectory_1,1)-1
    for j = 1:size(input_trajectory_2,1)-1
    [output_cro_point] = CrossPoint(input_trajectory_1(i:i+1,:),input_trajectory_2(j:j+1,:));
    cro_point = [cro_point ; output_cro_point];%记录相交点
    end
end
%删掉重合线段导致的相交点错误
for i = 2:size(cro_point,1)
    if_same = abs(cro_point(i,:) - input_trajectory_1) <0.0001 & abs(cro_point(i,:) - input_trajectory_2) <0.0001;
    if max(sum(if_same,2))>=2
        ID_dele = [ID_dele;i];
    end
end
cro_point(ID_dele,:) = [];
% hold on
% scatter(cro_point(:,1),cro_point(:,2),'black','*')

%% 在原始轨迹点中插入连接点
lip_piont_truth = [];%存放每个面域的连接点
lip_piont_predict = [];%存放每个面域的连接点
%对真实轨迹操作
for j = 1 : size(input_trajectory_1,1)-1 %将连接点放到真实轨迹里面，按照顺序
    %判断每个连接点是否在真实线上
    %看哪个连接点在该线内
    ID_ARG = [];%存放每个连接点是否在线上的集合
    for i = 1:size(cro_point,1)
        [outputArg_1] = check_point_line(cro_point(i,:),input_trajectory_1(j,:),input_trajectory_1(j+1,:));
        ID_ARG = [ID_ARG; outputArg_1];
        if outputArg_1 == 1
            ID_Arg = i;%赋予连接点序号
        end
    end
    if sum(ID_ARG) == 1 %若点在线上，则把前一个点和连接点都放到需连接的点集合里
        lip_piont_truth = [lip_piont_truth; [input_trajectory_1(j,:); cro_point(ID_Arg,:)]];
%         disp('有插值')
    else
        lip_piont_truth = [lip_piont_truth; input_trajectory_1(j,:)];
%         disp('无插值')
    end
end
lip_piont_truth = [lip_piont_truth; input_trajectory_1(j+1,:)];%把最后一个插进去

%对预测轨迹操作
for j = 1 : size(input_trajectory_2,1)-1 %将连接点放到预测轨迹里面，按照顺序
    %判断每个连接点是否在预测线上
    %看哪个连接点在该线内
    ID_ARG = [];%存放每个连接点是否在线上的集合
    for i = 1:size(cro_point,1)
        [outputArg_2] = check_point_line(cro_point(i,:),input_trajectory_2(j,:),input_trajectory_2(j+1,:));
        ID_ARG = [ID_ARG; outputArg_2];
        if outputArg_2 == 1
            ID_Arg = i;%赋予连接点序号
        end
    end
    if sum(ID_ARG) == 1 %若点在线上，则把前一个点和连接点都放到需连接的点集合里
        lip_piont_predict = [lip_piont_predict; [input_trajectory_2(j,:); cro_point(ID_Arg,:)]];
%         disp('有插值')
    else
        lip_piont_predict = [lip_piont_predict; input_trajectory_2(j,:)];
%         disp('无插值')
    end
end
lip_piont_predict = [lip_piont_predict; input_trajectory_2(j+1,:)];%把最后一个插进去

%% 计算面积
lip = [];%存放各个面积
for i = 1:size(cro_point,1)
    if i==size(cro_point,1)
        area_truth_0 = find((abs(lip_piont_truth(:,1)-cro_point(i,1))<0.001)&(abs(lip_piont_truth(:,2)-cro_point(i,2))<0.001));%找到面积起点在真实轨迹里的ID
%         做到这里了，允许误差的存在
        area_truth_1 = size(lip_piont_truth,1);%找到面积终点在真实轨迹里的ID
        area_predict_0 = find((abs(lip_piont_predict(:,1)-cro_point(i,1))<0.001)&(abs(lip_piont_predict(:,2)-cro_point(i,2))<0.001));%找到面积起点在预测轨迹里的ID
        area_predict_1 = size(lip_piont_predict,1);%找到面积终点在预测轨迹里的ID
    else
        area_truth_0 = find((abs(lip_piont_truth(:,1)-cro_point(i,1))<0.001)&(abs(lip_piont_truth(:,2)-cro_point(i,2))<0.001));%找到面积起点在真实轨迹里的ID
        area_truth_1 = find((abs(lip_piont_truth(:,1)-cro_point(i+1,1))<0.001)&(abs(lip_piont_truth(:,2)-cro_point(i+1,2))<0.001));%找到面积终点在真实轨迹里的ID
        area_predict_0 = find((abs(lip_piont_predict(:,1)-cro_point(i,1))<0.001)&(abs(lip_piont_predict(:,2)-cro_point(i,2))<0.001));%找到面积起点在预测轨迹里的ID
        area_predict_1 = find((abs(lip_piont_predict(:,1)-cro_point(i+1,1))<0.001)&(abs(lip_piont_predict(:,2)-cro_point(i+1,2))<0.001));%找到面积终点在预测轨迹里的ID
    end
    lip_sigle = [lip_piont_truth(area_truth_0:area_truth_1,:); flipud(lip_piont_predict(area_predict_0:area_predict_1,:))];%存放各个面积的连接点  其中预测轨迹做了倒序处理，因为要围成一个圈圈
    area_1 = polyarea(lip_sigle(:,1),lip_sigle(:,2));%计算当前围合的面积
    %判断顺逆时针，计算权重
    if i == 1
        start_truth = lip_piont_truth(area_truth_0+1,:)-lip_piont_truth(area_truth_0,:);%取距离起点一个步长的真实值，并归一化到起点上
        start_predict = lip_piont_predict(area_predict_0+1,:)-lip_piont_predict(area_predict_0,:);%取一个距离起点一个步长的预测值
        [start_truth_theta,~] = cart2pol(start_truth(1,1),start_truth(1,2));%换算成极坐标
        [start_predict_theta,~] = cart2pol(start_predict(1,1),start_predict(1,2));
        if start_truth_theta < start_predict_theta%若真实值比预测值角度小，则赋予权重-1，否则1
            up_down_wight = -1;
        else
            up_down_wight = 1;
        end
    else
        up_down_wight = up_down_wight*-1;%每次经过一个连接点就会转化相反权重
    end
    if ARG == 1%看采用哪种权重方式
        wight = up_down_wight;
    elseif ARG == 0
        wight = 1;
    end
%     %做图
%     if up_down_wight == 1
%         clor = 'r';
%     elseif up_down_wight == -1
%         clor = 'b';
%     end
%     hold on
%     figure(2)
%     fill(lip_sigle(:,1),lip_sigle(:,2),clor);%做个计算的面积的图瞧一瞧
    %记录到面积矩阵中
    lip = [lip; wight*area_1];
end
output_area = sum(lip);%输出等于加和的面积
%% 通过真实轨迹长度输出相对误差值
dist = squareform(pdist(input_trajectory_1));
di = [];
for i = 1:size(input_trajectory_1,1)-1
    di = [di;dist(i,i+1)];
end
output = output_area/(sum(di));

% toc
end