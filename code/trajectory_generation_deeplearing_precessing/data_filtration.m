%% 本脚本的目标是对数据进行预处理，并输出训练样本、验证样本以及测试样本
tic;
%% 读取数据，输入参数
%将每个轨迹点对应的机动车和非机动车坐标放到同一行上,14列
[E1]=xlsread('M:\New_try\4-桂林路吴中路东侧-转换后轨迹数据（三分类）（已填充缺失值）(1).xlsx',1);%东进口直行非机动车
%轨迹编号 时间 x y
E1= [E1(:,2) E1(:,8:10)];
Fs = 25;  %采样率

for i = 1:20 
%选出编号为i的轨迹
    ID = find(E1(:,1)==i);
    x = [E1(ID,3)];
    y = [E1(ID,4)];

    %% 作巴特沃斯低通滤波

    h = figure(1);
    filename = ['轨迹',num2str(i),'滤波对比结果.fig']
    Wc=2*3/Fs;  %截止频率 3Hz
    %阶数为 3 时的滤波情况
    [b0,a0]=butter(3,Wc);  
    Signal_Filter_x0=filtfilt(b0,a0,x);  %分别做xy的滤波
    Signal_Filter_y0=filtfilt(b0,a0,y);
    %阶数为 4 时的滤波情况
    [b1,a1]=butter(4,Wc);  
    Signal_Filter_x1=filtfilt(b1,a1,x);  %分别做xy的滤波
    Signal_Filter_y1=filtfilt(b1,a1,y);
    %阶数为 5 时的滤波情况
    [b2,a2]=butter(5,Wc);  
    Signal_Filter_x2=filtfilt(b2,a2,x);  %分别做xy的滤波
    Signal_Filter_y2=filtfilt(b2,a2,y);

    plot(x,y,Signal_Filter_x0,Signal_Filter_y0,Signal_Filter_x1,Signal_Filter_y1,Signal_Filter_x2,Signal_Filter_y2);  %原始轨迹 滤波阶数为3,4,5时的轨迹
    legend('原始轨迹','n=3时轨迹','n=4时轨迹','n=5时轨迹');
    title('Butterworth低通滤波前后轨迹对比');
    saveas(h,filename);
end