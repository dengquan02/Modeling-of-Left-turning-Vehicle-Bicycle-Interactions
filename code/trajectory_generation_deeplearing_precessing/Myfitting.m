function [all_output] = Myfitting(X)
%threshold_Risk = X(1);
% G=X(7);
R_b = 1;%表示道路条件，文献里给出了1的参数
k1 = X(1);
k3 = X(2);
char_intrusion = X(3);%原来是2
char_end = X(4);%原来是6
index_end = X(5);
k4 = X(6);
char_intrusion_right = X(7);
char_end_right = X(8);
index_end_right = X(9);
% tic
hitss = 10;%采样数
prop = 2;%加速度生成的比例
% threshold_Risk = 0.5;
G=X(10);%G=0.01;
% R_b = 1;
% M_b = 2000;%这个在计算风险里面有
% k1 = 1;
% k3 = 0.05;
% char_intrusion = 2;%原来是200
% char_end = 0.2;%原来是6
% index_end = 2;
% k4 = 1.2;
若果运行了这个，就会报错
%本函数的目标是在已知真实轨迹的情况下，以收益和风险为目标，取真实轨迹比生成轨迹更优秀的参数集合
global data_cal;%标定的数据  形式与E_trajectory一样，但是ID是其中一部分
perception_time = 20;%预测步长数量
global intrusion_cood_E
% intrusion_cood_E = [47.43 27;47.43 23.5;3 27;3 23.5];
input = data_cal;
index_cal = unique(data_cal(:,1)');%提取编号
output = 0;%记录生成样本轨迹的目标值是否大于目标值。越少越好
index_output = 0;%记录总样本
for index = 1:size(index_cal,2)%对于每条轨迹
    extract_trajectory = input((input(:,1)==index_cal(index)),:);%提取轨迹编号为index的轨迹
    for index_in = randperm((size(extract_trajectory,1)-perception_time-1),1)%round(rand(1)*18)+1:(size(extract_trajectory,1) - perception_time-1)  %对于每个轨迹点
        extract_20 = extract_trajectory(index_in:index_in+perception_time,:);%读取的真实轨迹
        %%%开始在预测点内生成一系列可能的轨迹，保证他们劣于真实轨迹，就可以完成标定任务
        output_gen = [];%存储每个生成轨迹的目标值
        for ID_generation = 1:hitss%生成十条其他轨迹
%             accle = rand(1,perception_time*2);
%             accle(1,1:perception_time) = 2*pi*accle(1,1:perception_time);
%             accle(1,perception_time+1:perception_time*2) = 1.6*accle(1,perception_time+1:perception_time*2);%加速度的上界  单位m/s
%             acc =[accle(1:perception_time)' accle(perception_time+1:perception_time*2)'];%一行换成两列
            %%%从真实轨迹随机出去一些①
             accle = (rand(1,perception_time*2)*2-1)*prop;%随机生成在真实轨迹加速度的5%以内
             acc =[accle(1:perception_time)' accle(perception_time+1:perception_time*2)'];%一行换成两列
             acc = extract_20(1:perception_time,8:9).*(1+acc);
            %随机生成-1.6~1.6m/s^2②
 %           accle = (rand(1,perception_time*2)*2-1)*1.6;%随机生成在真实轨迹加速度的5%以内
  %          acc =[accle(1:perception_time)' accle(perception_time+1:perception_time*2)'];%一行换成两列
            
%             开始计算目标值
            extract = extract_20(1,:);%预测的帧
            extract(:,1:3) = [];
            extract = reshape(extract',11,[])';%换算成11列的
            extract(all(extract==0,2),:)=[];%去掉全0行,剩下的是每个交互对象的，第一行是主体
            base_point = extract(1,1:2);%基准点
            Vio = [extract(1,3) extract(1,4)];%前进方向&横向方向
            prediction_point = base_point;%存放预测点的矩阵；
            diss = [];%记录的距离
            Risk = [];%用来存放风险,第一列是预测点，第二列是真实点
            standard_point = [];
            for i = 1:size(acc,1)%计算每一步的收益
                extract_time_i = reshape(extract_20(i,4:size(extract_20,2))',11,[])';%换算成11列的
                extract_time_i(all(extract_time_i==0,2),:)=[];%去掉全0行,这是真实的交互对象
                %先计算 需要恒速度的那个点，确定约束范围；
                pre_point = [(base_point(1,1)+Vio(1,1)*0.12) (base_point(1,2)+Vio(1,2)*0.12)];%计算恒速度推进的点，也是搜索的原点；
                [acceleration(1,1),acceleration(1,2)] = pol2cart(acc(i,1),acc(i,2));%将加速度的极坐标转化为直角坐标
                %将加速度换算至速度参考系
                truth_point = [pre_point(1,1)+acceleration(1,1)*0.12^2*0.5 pre_point(1,2)+acceleration(1,2)*0.12^2*0.5];%根据当前时刻的加速度求出真实轨迹点；
                Vio = [Vio(1,1)+acceleration(1,1)*0.12 Vio(1,2)+acceleration(1,2)*0.12];%将新的加速度赋予上一个步长的速度  vt=v0+at
                truth_Risk = Risk_calculation(truth_point,extract_time_i(2:size(extract_time_i,1),:),intrusion_cood_E,G,R_b,k1,k3,char_intrusion,char_end,index_end,char_intrusion_right,char_end_right,index_end_right);%计算当前点的风险；
                Risk = [Risk;norm(truth_Risk)];
                dis = Vio(1,1)*0.12;
%                 prediction_point = [prediction_point;truth_point];%将预测轨迹存放到矩阵中
%                 standard_point = [standard_point;pre_point];%每一步搜索的标准点
                diss = [diss;dis];%将当前时刻的前进方向的位移加进去
                prediction_point = [prediction_point;truth_point];%将预测轨迹存放到矩阵中
                base_point = truth_point ; %将预测点赋予基准点
            end
            output_ID = sum(diss(:,1));%求总位移之和
            output_ID = output_ID + k4*(sum(Risk(:,1)));%需标定，两个的权重
            %%%生成轨迹完成
            output_gen = [output_gen;output_ID];%生成轨迹的所有目标值
%             scatter(prediction_point(:,1),prediction_point(:,2),'*','r');%随机轨迹
%             hold on
%             scatter(extract_20(:,4),extract_20(:,5),'*','b');%真实轨迹
        end
%         红色比较显眼，计算完生成轨迹的目标值了
        Risk_real = [];%记录一个最优化的风险
        for i = 1:perception_time%计算每一步的收益
            extract_time_real = reshape(extract_20(i,4:size(extract_20,2)),11,[])';%提取当前时刻的交互对象
            
            extract_time_real(all(extract_time_real==0,2),:)=[];%去掉全0行,剩下的是每个交互对象的，第一行是主体
            truth_Risk_real = Risk_calculation(extract_time_real(1,1:2),extract_time_real(2:size(extract_time_real,1),:),intrusion_cood_E,G,R_b,k1,k3,char_intrusion,char_end,index_end,char_intrusion_right,char_end_right,index_end_right);%计算当前点的风险；
            Risk_real = [Risk_real;norm(truth_Risk_real)];%记录当前点的风险值
        end
        output_one = -(extract_trajectory(index_in,4)-extract_trajectory(index_in+perception_time,4)) + k4*(sum(Risk_real(:,1)));%一个小循环(一个轨迹点)的收益+风险 
%         if isnan(output_one)
%             continue
%         end
        try
            for i = 1:size(output_gen,1)
                output_gen_dif = output_one - output_gen(i,1) ;%用真实轨迹目标值减去生成的，大于零的越少越好
%                 disp(output_gen_dif)
                index_output = index_output + 1;
                if output_gen_dif>0
                    output = output + 1;
                end
            end
        catch
            continue
        end
    end
%     disp(output)
%     disp(['已完成',num2str(index/size(index_cal,2)*100),'%'])
end
all_output = output/index_output;
% toc
disp(['fitting = ',num2str(all_output)])

end


