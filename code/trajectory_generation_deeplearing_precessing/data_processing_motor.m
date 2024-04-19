%% 本脚本的目标是对数据进行预处理，并输出训练样本、验证样本以及测试样本
tic;
%% 读取数据
type = 1;
%车辆类型，1是自行车，2是电动车，3是机动车，4是外卖骑手
filename = 'M:\New_try\4-桂林路吴中路东侧-转换后轨迹数据（三分类）（平均数填充缺失值）(已处理).xlsx';
%将每个轨迹点对应的机动车和非机动车坐标放到同一行上,14列
[E1]=xlsread(filename,type);%自行车
%% 输入参数
%轨迹编号 时间 x y
Fs = 25;  %采样率
% filename = ['轨迹',num2str(1),'滤波对比结果.fig'];
[a,b] = size(E1);
x = zeros(a,1);
y = zeros(a,1);
Vx = zeros(a,1);
Vy = zeros(a,1);
V = zeros(a,1);
t = E1(:,1);
Ax = zeros(a,1);
Ay = zeros(a,1);
A = E1(:,9);
Wc=2*3/Fs;  %截止频率 3Hz
% if type == 3
%     Wc = 2*1/Fs;
% end

%% ①轨迹位置平滑（3阶ButterWorth滤波）
for i = 1:E1(end,12)
    ID = find(E1(:,12)==i);
    tempx = [E1(ID,2)];
    tempy = [E1(ID,3)];
    
    % 作三阶巴特沃斯低通滤波
    [b0,a0]=butter(3,Wc);
    x(ID) = filtfilt(b0,a0,tempx);  %分别做xy的滤波
    y(ID) = filtfilt(b0,a0,tempy);
    % ②重新计算运动学参数；
    %计算速度
    tempVx = [E1(ID,4)];
    tempVy = [E1(ID,5)];
    tempVx(1:end-1) = (x(ID(2:end))-x(ID(1:end-1)))./0.04;
    tempVy(1:end-1) = (y(ID(2:end))-y(ID(1:end-1)))./0.04;
    Vx(ID) = tempVx;
    Vy(ID) = tempVy;
    %计算加速度
    tempAx = [E1(ID,6)];
    tempAy = [E1(ID,7)];
    tempAx(1:end-1) = (Vx(ID(2:end))-Vx(ID(1:end-1)))./0.04;
    tempAy(1:end-1) = (Vy(ID(2:end))-Vy(ID(1:end-1)))./0.04;
    Ax(ID) = tempAx;
    Ay(ID) = tempAy;
    V(ID) = (Vx(ID).^2+Vy(ID).^2).^0.5.*3.6;
    A(ID(1:end-1)) = (V(ID(2:end))-V(ID(1:end-1)))./0.04;
end
%储存最后一条轨迹不同阶段的情况，便于对比最终滤波效果
x1 = [tempx];
y1 = [tempy];
x2 = [x(ID)];
y2 = [y(ID)];

%曲率是否有用？怎么处理？

%% ③筛选异常值（条件：速度>25/40/60km/h（普通自行车/普通电动车/外卖骑手）的轨迹点），

for i = 1:E1(end,12)
    ID = find(E1(:,12)==i);
    outliers = [];
    if type == 1 || 2 || 4
        if type == 1
            Vlimit = 25;
        elseif type == 4
            Vlimit = 40;
        else
            Vlimit = 60;
        end
        for a = 1:length(ID)
            if(V(ID(a)) >= Vlimit & a >= 11 & a <= length(ID)-10)
                outliers = [outliers,ID(a)];
            end
        end
    else %（条件：加速度>10m/s^2（机动车）的轨迹点）
        Alimit = 10;
        for a = 1:length(ID)
            if(abs(A(ID(a))) >= Alimit & a >= 11 & a <= length(ID)-10)
                outliers = [outliers,ID(a)];
            end
        end
    end
    %     outliers = ID(find(V(ID) >= Vlimit));%找出超限值
    %     outliers = [outliers(find(outliers >= (ID(1)+10) & outliers <= (ID(end)-10)))];%去除前后不足十个点的值
    if isempty(outliers)%为空则跳过当前轨迹
        continue;
    end
    for k = 1:length(outliers)
        j = outliers(k);
        t0 = linspace(j-10,j+10,21);
        %重新插值轨迹点（方法：三次样条差值法）；
        tempx = [x(j-10),x(j+10)];
        tempy = [y(j-10),y(j+10)];
        x(j-10:j+10) = spline([j-10,j+10],tempx,t0);
        y(j-10:j+10) = spline([j-10,j+10],tempy,t0);
        %         traj(:,6) = yi;
        %         x(outliers) = spline(normal,x(normal),outliers);
        %         y(outliers) = spline(normal,y(normal),outliers);
        %     normal = setxor(ID,outliers);
        %④重新计算速度和加速度
%         for jj = j-9:j+9
%             Vx(jj) = (x(jj+1)-x(jj-1))/(t(jj+1)-t(jj-1));
%             Vy(jj) = (y(jj+1)-y(jj-1))/(t(jj+1)-t(jj-1));
%             V(jj) = (Vx(jj).^2+Vy(jj).^2).^0.5.*3.6;
%             Ax(jj) = (x(jj+1)-2*x(jj)+x(jj-1))/(t(jj+1)-t(jj)).^2;
%             Ay(jj) = (y(jj+1)-2*y(jj)+y(jj-1))/(t(jj+1)-t(jj)).^2;
%             A(jj) = (V(jj)-V(jj-1))./0.04;
%         end
    end
    %④重新计算速度和加速度
    Vx(ID(1:end-1)) = (x(ID(2:end))-x(ID(1:end-1)))./0.04;
    Vy(ID(1:end-1)) = (y(ID(2:end))-y(ID(1:end-1)))./0.04;      
    %计算加速度
    Ax(ID(1:end-1)) = (Vx(ID(2:end))-Vx(ID(1:end-1)))./0.04;
    Ay(ID(1:end-1)) = (Vy(ID(2:end))-Vy(ID(1:end-1)))./0.04;
    V(ID) = (Vx(ID).^2+Vy(ID).^2).^0.5.*3.6;
    A(ID(1:end-1)) = (V(ID(2:end))-V(ID(1:end-1)))./0.04;
end

x3 = [x(ID)];
y3 = [y(ID)];
x4 = [x(outliers)];
y4 = [y(outliers)];
Vx1 = [Vx(ID)];
Vy1 = [Vy(ID)];

%% ⑤平滑速度（1阶ButterWorth滤波）；
for i = 1:E1(end,12)
    ID = find(E1(:,12)==i);
    % 作三阶巴特沃斯低通滤波
    [b1,a1]=butter(1,Wc);
    Vx(ID)=filtfilt(b1,a1,Vx(ID));  %分别做VxVy的滤波
    Vy(ID)=filtfilt(b1,a1,Vy(ID));
    %⑥重新计算位置和加速度
    for j = 2:length(ID)
        x(ID(j)) = x(ID(j-1)) + Vx(ID(j-1))*0.04 + 0.5*Ax(ID(j-1))*0.04^2;
        y(ID(j)) = y(ID(j-1)) + Vy(ID(j-1))*0.04 + 0.5*Ay(ID(j-1))*0.04^2;
        Ax(ID(j-1)) = (Vx(ID(j)) - Vx(ID(j-1)))/0.04;
        Ay(ID(j-1)) = (Vy(ID(j)) - Vy(ID(j-1)))/0.04;
    end
    V(ID) = (Vx(ID).^2+Vy(ID).^2).^0.5.*3.6;
    A(ID(1:end-1)) = (V(ID(2:end))-V(ID(1:end-1)))./0.04;
end
x5 = [x(ID)];
y5 = [y(ID)];
Vx2 = [Vx(ID)];
Vy2 = [Vy(ID)];
%输出不同阶段的轨迹处理情况
plot(x1,y1,x2,y2,x3,y3,x5,y5,x4,y4);
legend('原始轨迹','1平滑后轨迹','3三次样条差值轨迹','5速度平滑后最终结果','异常点');
% plot(linspace(1,length(ID),length(ID)),Vx1,linspace(1,length(ID),length(ID)),Vx2);
% legend('平滑前','平滑后');
%% 保存数据
title = {'GlobalTime','X[m]','Y[m]','Vx[m/s]','Vy[m/s]','Ax[m/s2]','Ay[m/s2]','Speed[km/h]','Acceleration[m/s2]','Space[m]','Curvature[1/m]','ID','ID_in','ID_straight','type'};
data = [E1(:,1),x,y,Vx,Vy,Ax,Ay,V,A,E1(:,10:15)];
%将间隔时间改为0.12s
fdata = [];
%由于最后一个点参数无法用运动学公式得出，删除最后一个点
for i = 1:data(end,12)
    ID = find(data(:,12)==i);
    data(ID(end),:) = [];
    %将间隔时间改为0.12s
    ID = [ID(1:end-1)];
    j = 1;
    while j <= (length(ID)-2)
        fdata = [fdata;data(ID(j),:)];
        j = j + 3;
    end
    %重新编号
    ID = find(fdata(:,12)==i);
    fdata(ID,13) = linspace(1,length(ID),length(ID));
end
if type == 1
    sheetname = '自行车';
elseif type == 2
    sheetname = '电动车';
elseif type == 3
    sheetname = '机动车';
else
    sheetname = '外卖骑手';
end
xlswrite(filename,[title;num2cell(fdata)],sheetname);



