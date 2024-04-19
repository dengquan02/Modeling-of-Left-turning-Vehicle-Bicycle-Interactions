% V = extract_one(1,10)/3.6*0.12;%根据当前的计算出一个步长的距离，当成离散点半径  extract_one(1,10)
% A = zeros(80,40);b = zeros(80,1);
% for i = 1:40%极径和角度都要大于0
%    A(i,i) = -1; 
%    b(i,1) = 0;
% end
% for i = 1:20%角度要小于2pi
%    A(i+40,i) = 1; 
%    b(i+40,1) = 2*pi;
% end
% for i = 1:20%极径都要小于0.24
%    A(i+60,i+20) = 1; 
%    b(i+60,1) = 1;
% end
%查看预测对象车型
% input_data = E_trajectory;
% % input_data = sample_test(:,2:size(sample_test,2));
% input_data(find(abs(input_data(:,6))>50),:)=[];
% a_limit = (input_data(find(input_data(:,14)==2),6));%10是速度，11是加速度    
% % a_limit = sort(abs(a_limit));
% % % % % % a_limit = prctile(a_limit ,85);%求百分位数
% % % % a_limit(size(a_limit,1)-2:size(a_limit,1),:) = [];
% % median(a_limit)%中位数median
% mean(abs(a_limit))%平均值
% hist(a_limit)
% % % mode(a_limit)
% % hist(a_limit);
global extract_one
if extract_one(1,14)==2%若是2，则为电动车
    a_limit = 0.2703;%0.2703;%最大值：3.8   %0.259结果用的是0.2703；效果好的时候是平均值0.4；取得是平均值和当前值的最大值  ，目前在尝试百分位数0.74、中位数0.31、众数0.03
elseif extract_one(1,14)==1%若是1，则为自行车
    a_limit = 0.05934;%最大值：1.58   0.259结果用的是0.05934效果好的时候是平均值0.26；取得是平均值和当前值的最大值，目前在尝试百分位数0.5、中位数0.2、众数0.01
end
a_limit = max(a_limit,extract_one(1,11)+0.01);%当前加速度和我给的约束，取大值
%上下界
% a_limit = prctile(sort(abs(a_limit)),85);%求百分位数
%% 开始优化
% Nu_point表示基于几个点表征的轨迹趋势
% perception_time = 25;
generating_lengh = 9;

Nu_point = (perception_time-1)/(generating_lengh-1);%两个点，终点和中间点

lb = zeros(Nu_point*2,1);
ub = zeros(Nu_point*2,1);
ub(1:Nu_point,1) = 2*pi;
ub(Nu_point+1:Nu_point*2,1) = a_limit;%a_limit;%加速度的上界  单位m/s  0.2是加速度的平均值，从数据中来

%优化参数  
options = gaoptimset('PopInitRange',[pi,0.15;pi,0.15],'PopulationSize',50, 'Generations', 200,'CrossoverFraction',0.8,'MigrationFraction',0.04 ); % 遗传算法相关配置   'StallGenLimit',20  

%利用遗传算法进行计算
[OPT,FVAL,EXITFLAG,OUTPUT] =ga(@Excur_predict_1,(Nu_point*2),[],[],[],[],lb,ub,@nonlcon,options);%利用遗传算法进行参数标定  