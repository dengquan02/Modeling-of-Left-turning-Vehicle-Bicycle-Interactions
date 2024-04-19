%% 读取该目录下的所有txt文件
path = 'M:\New_try\trajectory_generation_deeplearingModel\result_test\';%python的预测结果地址
namelist = dir('M:\New_try\trajectory_generation_deeplearingModel\result_test\*.txt');%读取所有txt文件名  %python的预测结果地址
file_list = sort_nat({namelist.name}); %对文件名进行排序， 原来是乱序的
leng = length(file_list);%获取总数量
P = cell(1,leng);%定义一个细胞数组，用于存放所有txt文件
for i = 1:leng
    file_name{i}=file_list(1,i);
    file_name_1 = strcat(file_name{i});
    file_name_curent = strcat(path,file_name_1);
    P{1,i} = load(cell2mat(file_name_curent));
end
   
x_test = csvread('x_test.csv');%读测试数据
%x_test = [x_test zeros(size(x_test,1),(28-16))];

y_test = csvread('y_test.csv');%读测试数据
N_lengh_point = size(x_test,2)/2;%短矩阵的宽度  就是22
truth_data_test = [x_test(:,1:N_lengh_point) y_test x_test(:,N_lengh_point+1:2*N_lengh_point)];%合成真实的测试数据





%%  数据预处理

prediction = P;

% generating_lengh = 17;

%%%以上把预测和真值的数据格式弄成一样的，最后得到yy和tt
pre_data_test=zeros(size(truth_data_test,1),size(truth_data_test,2));%yy是预测值
for i = 1:size(x_test,1) %把预测值放到真值形状
    pre_data_test(i,:)=(reshape(prediction{1,i}',[1,size(truth_data_test,2)]));%变形
end


pre_data_test=reshape(pre_data_test',N_lengh_point,[])';%预测值；N_lengh_point是特征数；
truth_data_test=reshape(truth_data_test',N_lengh_point,[])';%真实值；N_lengh_point是特征数；

% 这里了
[tt_t,yy_y] = Anti_normalizating(truth_data_test,pre_data_test,mmax,mmin); %反归一化，tt_t表示真值，yy_y表示预测，输进去的是窄矩阵
tt_t=reshape(tt_t',(N_lengh_point*generating_lengh),[])';%变换形状,变成宽矩阵；
yy_y=reshape(yy_y',(N_lengh_point*generating_lengh),[])';%变换形状,变成宽矩阵；

prediction=yy_y;
T_V=tt_t;
    
%% %%计算误差  并做图
%计算预测数据的MSE
ADE_all = [];
for i = 1:leng
    pre_one = reshape(prediction(i,:)',(N_lengh_point),[])';
    truth_one = reshape(T_V(i,:)',(N_lengh_point),[])';
%     figure(2)
%     clf
%     scatter(truth_one(:,1),truth_one(:,2),'*','b');
%     hold on
%     scatter(pre_one(:,1),pre_one(:,2),'*','r');
%     pause(0.5)
%     i = i+1;
    ADE_one = mean(((pre_one(:,1)-truth_one(:,1)).^2+(pre_one(:,2)-truth_one(:,2)).^2).^0.5);
    disp(ADE_one)
    
    ADE_all = [ADE_all;ADE_one];%存放ADE
end
mean(ADE_all)%输出测试集合的平均距离误差
hist(ADE_all)%做分布图
save data_new2
% %% 
% %计算误差到此结束，后面是一些测试用的代码
% ADE_all(find(ADE_all(:,1)>5),:) =[];%检查错误项，去掉误差过高的错误项
% 
% 
% %% 可视化训练集，查看输入的训练集是否完美
% for i = 1:1000
%     figure(1)
% %     clf
%     scatter(x_train(i,1),x_train(i,2),'b','*');%训练集起点
%     hold on
%     scatter(x_train(i,14+1),x_train(i,14+2),'b','*');%训练集起点
%     hold on
%     scatter(y_train(i,1),y_train(i,2),'r','*');%训练集输出
% %     pause(1)
% %     i=i+1;
% end

% 到这里了
% MSE=zeros(generating_lengh,2);%均方根误差，表示每条轨迹的第i个点的平均误差；
% jj=1;
% MSE_di=zeros(size(x_test,1),n_input+2);
% for j =(size(x_test,2)+1):fe:size(prediction,2)
%     MSE(jj,2)=jj;%编号
%     se=0;
%     for i=1:size(x_test,1)
%         se_di=((((prediction(i,j)-T_V(i,j))^2)+((prediction(i,j+1)-T_V(i,j+1))^2))^0.5);%每点的误差
%         se=se+se_di;%计算每个预测点的平均误差MSE
%         MSE_di(i,jj+1)=se_di;
%         MSE_di(i,1)=i;%编号
%     end
%     MSE(jj,1)=se/size(x_test,1);
%     jj=jj+1;
% end
% MSE_1=MSE_di(:,1:2);%第一个点的误差；第一列是编号，第二列开始是第一个点
% MSE_1=sortrows(MSE_1,2);%排序
% 
% 
% AEE=zeros(size(x_test,1),2);%表示每条轨迹的21个预测点的平均误差
% for i=1:size(x_test,1)
%     AEE(i,2)=i;%编号
%     binahao=0;
%     for j = (size(x_test,2)+1):fe:size(prediction,2)
%         AEE(i,1)= AEE(i,1)+((((prediction(i,j)-T_V(i,j))^2)+((prediction(i,j+1)-T_V(i,j+1))^2))^0.5);
%         binahao=binahao+1;
%     end
%     AEE(i,1)= AEE(i,1)/binahao;%求平均值，之前给忘记了
% end
% AEE_SORT=sortrows(AEE,1);
% mean_AEE=mean(AEE_SORT(:,1));
% disp(['mean_AEE is ',num2str(mean_AEE) ]);
% 
% %%%把数据分开，分成膨胀和非膨胀轨迹；
% [RMSE_swell,RMSE_non,GT_swell,GT_non,prediction_swell,prediction_non] = result_divide(AEE,prediction,T_V,fe);
% disp(['mean_RMSE_swell is ',num2str(mean(RMSE_swell(:,1))) ]);
% disp(['mean_RMSE_non is ',num2str(mean(RMSE_non(:,1))) ]);
% disp(['var_non is ',num2str(var(RMSE_non(:,1))) ]);
% disp(['var_swell is ',num2str(var(RMSE_swell(:,1))) ]);
% 
% 
% figure(7)
% RMSE_data = RMSE_non(:,1);%读取误差
% [M,M1] = hist(RMSE_data , (0:0.5:12));%求频率
% bar(M1,M);
% 
% %%%做膨胀轨迹的图%%%%%
% figure(5);
% for j = 1:fe:(size(x_test,2))
%     scatter(prediction_swell(:,j),prediction_swell(:,j+1),'x','b');%原始数据
%     hold on
% end
% 
% for j = (size(x_test,2)+1):fe:size(GT_swell,2)
%     scatter(GT_swell(:,j),GT_swell(:,j+1),'+','g');%真实值的后半截
%     hold on
% end
% for j = (size(x_test,2)+1):fe:size(prediction_swell,2)
%     scatter(prediction_swell(:,j),prediction_swell(:,j+1),'x','r');%预测数据
%     hold on
% end
% 
% %%%做所有轨迹的图%%%%%
% figure(1);
% for j = 1:fe:(size(x_test,2))
%     scatter(prediction(:,j),prediction(:,j+1),'x','b');%原始数据
%     hold on
% end
% 
% for j = (size(x_test,2)+1):fe:size(T_V,2)
%     scatter(T_V(:,j),T_V(:,j+1),'+','g');%真实值的后半截
%     hold on
% end
% for j = (size(x_test,2)+1):fe:size(prediction,2)
%     scatter(prediction(:,j),prediction(:,j+1),'x','r');%预测数据
%     hold on
% end
% 
% 
% %%%%做单独一条轨迹的图%%%%%
% shunxu = 68;
% % while shunxu<=216
% i=AEE_SORT(shunxu,2);
% figure(2);
% clf %清除前面的图用的
% for j = (size(x_test,2)+1):fe:size(prediction,2)
%     scatter(prediction(i,j),prediction(i,j+1),'*','r');%预测数据
%     hold on
% end
% for j = 1:fe:(size(x_test,2))
%     scatter(prediction(i,j),prediction(i,j+1),'*','b');%原始数据
%     hold on
% end
% for j = (size(x_test,2)+1):fe:size(T_V,2)
%     scatter(T_V(i,j),T_V(i,j+1),'*','g');%真实值的后半截
%     hold on
% end
% shunxu = shunxu+1;
% pause(0.5);
% % end
% 
% 
% 
% %%%做训练数据的图%%%%%
% figure(3);
% for j = 1:fe:(size(x_train,2))
%     scatter(x_train(1:100,j),x_train(1:100,j+1),'x','b');%原始数据
%     hold on
% end
% for j = 1:fe:9
%     scatter(y_train(1:100,j),y_train(1:100,j+1),'x','r');%原始数据
%     hold on
% end
% %%%做单条训练数据的图%%%%%
% i=1;
% % while i<1900
% figure(4);
% clf %清除前面的图用的
% for j = 1:fe:(size(x_train,2))
%     scatter(x_train(i,j),x_train(i,j+1),'x','b');%原始数据
%     hold on
% end
% for j = 1:fe:(size(y_train,2))
%     scatter(y_train(i,j),y_train(i,j+1),'x','r');%原始数据
%     hold on
% end
% i=i+1;
% pause(0.5);
% % end
% 
% 
% % i=1;
% % while i<=13
% %     figure(9)
% % [M,M1] = hist(x_train(:,i));%求频率
% % bar(M1,M);
% % figure(10)
% % [M,M1] = hist(x_ver(:,i));%求频率
% % bar(M1,M);
% % figure(11)
% % [M,M1] = hist(x_test(:,i));%求频率
% % bar(M1,M);
% % i=i+1;
% % pause(2)
% % end