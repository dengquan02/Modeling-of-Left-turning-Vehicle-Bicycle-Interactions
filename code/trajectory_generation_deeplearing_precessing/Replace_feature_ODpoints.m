function [precessing_train_ver_output,precessing_test_output] = Replace_feature_ODpoints(precessing_train_ver,precessing_test,generating_lengh)
% 本函数的目标是将训练和测试样本里终点的数据替换成基于运动学公式计算的，因为在实际操作中这些特征值是未知量；
%测试用，读取数据
precessing_train_ver1 = precessing_train_ver;
precessing_test1 = precessing_test;
n = 11;

%% 先变换一下形状，把一个样本放到一行
ID_Data_train_ver = precessing_train_ver1(:,1:4);  %先把前4列的ID数据拿掉，最后再补回去
ID_Data_test = precessing_test1(:,1:4);  %先把前4列的ID数据拿掉，最后再补回去
precessing_train_ver1(:,1:4) = [];
precessing_test1(:,1:4) = [];
precessing_train_ver1 = reshape(precessing_train_ver1',3*n*2,[])';  %以（2*n）为一个点，因为还包括一个交互的对象点；
precessing_test1 = reshape(precessing_test1',generating_lengh*n*2,[])';

%% 对训练数据处理  只动终点就行 
%研究主体
timestep = 0.12;    %由E_trajectory(2,3)-E_trajectory(1,3)计算而得
T_start = precessing_train_ver((1:3:size(precessing_train_ver,1)-2),4);%获得所有起点
T_end = precessing_train_ver((1:3:size(precessing_train_ver,1)-2)+1,4);%获得所有终点
T = 0.12*((T_end-T_start)/timestep);

Host_S_start =  precessing_train_ver1(:,1:2);  %起点位置
Host_V_start =  precessing_train_ver1(:,3:4);%起点速度
Host_A_start =  precessing_train_ver1(:,5:6);%单位为m/s^2
Host_C_start =  precessing_train_ver1(:,10);%曲率!!

Host_S_end =  precessing_train_ver1(:,45:46);  %终点位置
Host_V_end = (2 .*(Host_S_end - Host_S_start)./T) - Host_V_start; %得到的是速度矩阵
A_mean = (Host_V_end - Host_V_start)./T;%计算加速度，这一段上的平均加速度
Host_A_end = A_mean*2 - Host_A_start;%计算得到最终的加速度
Host_C_end =  Host_C_start;%赋值终点曲率!!


%交互对象  相较于研究主体  列数为+n  恒加速度模型
Inter_S_start =  precessing_train_ver1(:,(n+1):(n+2));  %起点位置
Inter_V_start =  precessing_train_ver1(:,(n+3):(n+4));%换算成m/s
Inter_A_start =  precessing_train_ver1(:,(n+5):(n+6));

Inter_C_start =  precessing_train_ver1(:,n+10);%!!

Inter_A_end = Inter_A_start;%加速度不变
Inter_V_end = Inter_V_start + T.*Inter_A_start;%恒加速度计算最后的速度
Inter_S_end = Inter_S_start + Inter_V_start.*T + 0.5.*Inter_A_start.*T.^2;%恒加速度模型计算位置

Inter_C_end = Inter_C_start;%!!
%赋值
precessing_train_ver1_output = precessing_train_ver1;
precessing_train_ver1_output(:,47:48) = Host_V_start;%赋予研究主体终点的速度
precessing_train_ver1_output(:,49:50) = Host_A_start;%赋予研究主体终点的加速度   原来是Host_A_end

precessing_train_ver1_output(:,54) = Host_C_start;%赋予研究主体终点的曲率!!

precessing_train_ver1_output(:,n+45:n+46) = Inter_S_end;%赋予交互对象的位置
precessing_train_ver1_output(:,n+47:n+48) = Inter_V_end;%赋予交互对象的速度
precessing_train_ver1_output(:,n+49:n+50) = Inter_A_end;%赋予交互对象的加速度

precessing_train_ver1_output(:,n+54) = Inter_C_end;%赋予交互对象的曲率!!


%% 对测试数据处理  只动终点就行
%研究主体
t = (generating_lengh - 1)*0.12;%计算运行时间
Host_S_start_test =  precessing_test1(:,1:2);  %起点位置
Host_V_start_test =  precessing_test1(:,3:4);  %起点速度
Host_A_start_test =  precessing_test1(:,5:6);%换算成m/s   起点加速度
Host_C_start_test =  precessing_test1(:,10);%曲率!! 

Host_S_end_test =  precessing_test1(:,(2*n*16+1):(2*n*16+2));  %终点位置
Host_V_end_test = (2 .*(Host_S_end_test - Host_S_start_test)./t) - Host_V_start_test; %得到的是速度矩阵
A_mean_test = (Host_V_end_test - Host_V_start_test)./t;%计算加速度，这一段上的平均加速度
Host_A_end_test = A_mean_test*2 - Host_A_start_test;%计算得到最终的加速度
Host_C_end_test = Host_C_start_test;%!!

%交互对象  相较于研究主体  列数为+n
Inter_S_start_test =  precessing_test1(:,(n+1):(n+2));  %起点位置
Inter_V_start_test =  precessing_test1(:,(n+3):(n+4));%换算成m/s
Inter_A_start_test =  precessing_test1(:,(n+5):(n+6));
Inter_C_start_test =  precessing_test1(:,n+10);%!!

Inter_A_end_test = Inter_A_start_test;%加速度不变
Inter_V_end_test = t.*Inter_V_start_test;%速度按照恒加速度计算
Inter_S_end_test = Inter_S_start_test + Inter_V_start_test * t+ 0.5.*Inter_A_end_test.*t.^2;%恒速度模型计算
Inter_C_end_test = Inter_C_start_test;%!!
%赋值
precessing_test_output1 = precessing_test1;
precessing_test_output1(:,(2*n*16+3):(2*n*16+4)) = Host_V_start_test;%赋予研究主体的速度,就是初速度  3:4表示速度    
precessing_test_output1(:,(2*n*16+5):(2*n*16+6)) = Host_A_start_test;%赋予研究主体的加速度，就是初加速度
precessing_test_output1(:,(2*n*16+11+1):(2*n*16+11+2)) = Inter_S_end_test;%赋予交互对象的位置
precessing_test_output1(:,(2*n*16+11+3):(2*n*16+11+4)) = Inter_V_end_test;%赋予交互对象的速度
precessing_test_output1(:,(2*n*16+11+5):(2*n*16+11+6)) = Inter_A_end_test;%赋予交互对象的加速度
precessing_test_output1(:,2*n*16+11+10) = Inter_C_end_test;%富裕交互对象曲率！！


%% 恢复形状，添加之前的ID
precessing_train_ver_output = reshape(precessing_train_ver1_output',n*2,[])';  %以（2*n）为一个点，因为还包括一个交互的对象点；
precessing_test_output = reshape(precessing_test_output1',n*2,[])';

precessing_train_ver_output = [ID_Data_train_ver precessing_train_ver_output];%添加之前的ID
precessing_test_output = [ID_Data_test precessing_test_output];
end