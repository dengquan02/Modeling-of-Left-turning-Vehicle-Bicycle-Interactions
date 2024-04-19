
%优化参数
options = gaoptimset('PopInitRange',[pi,1.5;pi,1.5],'PopulationSize',100, 'Generations', 800,'CrossoverFraction',0.8,'MigrationFraction',0.02 ); % 遗传算法相关配置   'StallGenLimit',20  
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
a_limit = (E_trajectory(find(E_trajectory(:,14)==1),9));
a_limit = sort(a_limit);
global extract_one
if extract_one(1,14)==2%若是2，则为电动车
    a_limit = 2;%其实电动车为-3~3.3m/s^2
elseif extract_one(1,14)==1%若是1，则为自行车
    a_limit = 1;%其实自行车车为-2~1.3m/s^2
end
%上下界
lb = zeros(20,1);
ub = zeros(20,1);
lb(1:20,1) = -a_limit;
ub(1:20,1) = a_limit;%加速度的上界  单位m/s
%利用遗传算法进行计算
[OPT,FVAL,EXITFLAG,OUTPUT] =ga(@Excur_predict_3,20,[],[],[],[],lb,ub,@nonlcon_3,options);%利用遗传算法进行参数标定  