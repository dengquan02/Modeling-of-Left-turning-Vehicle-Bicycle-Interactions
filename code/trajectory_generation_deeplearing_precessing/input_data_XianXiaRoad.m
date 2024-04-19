function [E_trajectory] = input_data_XianXiaRoad(E1,E1V,W1V,Num_No,Num_V)
%%% 读取数据      %将每个轨迹点对应的机动车和非机动车坐标放到同一行上,14列
tic
E1(:,14) = [];
E1V(:,14) = [];
W1V(:,14) = [];
E1= [E1(:,1:11) E1(:,13) E1(:,12) E1(:,14)];
E1V= [E1V(:,1:11) E1V(:,13) E1V(:,12) E1V(:,14)];
W1V= [W1V(:,1:11) W1V(:,13) W1V(:,12) W1V(:,14)];

%%% 扭转一下，后面的就不用改了
[E1] = change_rad(E1,90);
[E1V] = change_rad(E1V,90);
[W1V] = change_rad(W1V,90);

%%% 输入必要参数
% Num_No=6;%交互的非机动车对象的个数（目前是按照距离最短的计算,参考齐骁6个）
% Num_V=6;%交互的机动车个数

% csvwrite('intrusion_cood_EXXRoad.csv',intrusion_cood_EXXRoad)


%%%去除相同数据
[E1] = same_out(E1);
[E1V] = same_out(E1V);
[W1V] = same_out(W1V);

%%%找到直行非机动车
[E_straight] = [E1(:,1:12) E1(:,14) E1(:,13)];%find_straight(E1,35,60,15,40,-10,10,20,40);

%%%%%%%对E和N处理成特征交互矩阵%%%%%%%
[NVinterract,Vinterract] = DATA_merge (E1,[],E1V,W1V,[]);%%DATA merge

[E_trajectory] = data_handle(E_straight,NVinterract,Vinterract,Num_No,Num_V,1);%将原始数据处理后，弄成特征矩阵 ,最后一个数字表示轨迹中0的个数不能超过此限制

toc
end