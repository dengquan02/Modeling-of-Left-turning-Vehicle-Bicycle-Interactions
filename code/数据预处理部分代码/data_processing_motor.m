%% 本脚本的目标是对数据进行平滑
tic;
for type = 1:3%分别是自行车、电动车、机动车
    %% 读取数据
    checkid = 6;
    if type == 1
        AxMax = 1.8;
        AxMin = -3.1;
        AyMax = 4.3;
        AyMin = -8.3;
        AMax = 15;
        AMin = -24;
        CMax = 0.8;
        CMin = -0.9;
    elseif type == 2
        AxMax = 2.7;
        AxMin = -3.67;
        AyMax = 4.7;
        AyMin = -9.7;
        AMax = 16.1;
        AMin = -29.3;
        CMax = 1.2;
        CMin = -1.1;
    else
        AxMax = 5.8;
        AxMin = -1.9;
        AyMax = 4;
        AyMin = -7.6;
        AMax = 18;
        AMin = -21;
        CMax = 1;
        CMin = -0.8;
    end
    %车辆类型，1是自行车，2是电动车，3是机动车，4是外卖骑手
    filename = 'C:\Users\honly\Desktop\按车型分类数据（三分类）(已处理).xlsx';
    %将每个轨迹点对应的机动车和非机动车坐标放到同一行上,14列
    [E1,txt]=xlsread('C:\Users\honly\Desktop\按车型分类数据（三分类）.xlsx',type);%自行车
    title = [txt(1,1:19)];
    txt = [txt(2:end,16:19)];
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
    C = E1(:,11);
    Wc=2*3/Fs;  %截止频率 3Hz
    % if type == 3
    %     Wc = 2*1/Fs;
    % end
    
    %% ①轨迹位置平滑（3阶ButterWorth滤波）
    for i = 1:E1(end,12)
        ID = find(E1(:,12)==i);
        if length(ID) <= 9
            continue;
        end
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
        tempVx(end) = tempVx(end-1);
        tempVy(end) = tempVy(end-1);
        Vx(ID) = tempVx;
        Vy(ID) = tempVy;
        %计算加速度
        tempAx = [E1(ID,6)];
        tempAy = [E1(ID,7)];
        tempAx(1:end-1) = (Vx(ID(2:end))-Vx(ID(1:end-1)))./0.04;
        tempAy(1:end-1) = (Vy(ID(2:end))-Vy(ID(1:end-1)))./0.04;
        tempAx(end) = tempAx(end-1);
        tempAy(end) = tempAy(end-1);
        Ax(ID) = tempAx;
        Ay(ID) = tempAy;
        V(ID) = ((Vx(ID).^2+Vy(ID).^2).^0.5).*3.6;
        A(ID(1:end-1)) = (V(ID(2:end))-V(ID(1:end-1)))./0.04;
        A(ID(end)) = A(ID(end-1));
        %检查滤波效果
        if i == checkid
            x1 = [tempx];
            y1 = [tempy];
            x2 = [x(ID)];
            y2 = [y(ID)];
        end
    end
    %储存最后一条轨迹不同阶段的情况，便于对比最终滤波效果
    
    
    %% ③筛选异常值（条件：速度>25/40/60km/h（普通自行车/普通电动车/外卖骑手）的轨迹点,加速度大于10m/s2），
    
    for i = 1:E1(end,12)
        ID = find(E1(:,12)==i);
        outliers = [];
        if type == 1
            Vlimit = 25;
            Alimit = 10;
        elseif type == 2
            Vlimit = 40;
            Alimit = 10;
        else
            Vlimit = 60;
            Alimit = 10;
        end
        for a = 1:length(ID)
            if((V(ID(a)) >= Vlimit || abs(A(ID(a))) >= Alimit ) && a >= 11 && a <= length(ID)-10)
                outliers = [outliers,ID(a)];
            end
        end
        %     else %（条件：加速度>10m/s^2（机动车）的轨迹点）
        %         Alimit = 10;
        %         for a = 1:length(ID)
        %             if(abs(A(ID(a))) >= Alimit & a >= 11 & a <= length(ID)-10)
        %                 outliers = [outliers,ID(a)];
        %             end
        %         end
        %     end
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
        Vx(ID(abs(Vx(ID))<0.001)) = 0;
        Vy(ID(abs(Vy(ID))<0.001)) = 0;
        Vx(ID(end)) = Vx(ID(end-1));
        Vy(ID(end)) = Vy(ID(end-1));
        %计算加速度
        Ax(ID(1:end-1)) = (Vx(ID(2:end))-Vx(ID(1:end-1)))./0.04;
        Ay(ID(1:end-1)) = (Vy(ID(2:end))-Vy(ID(1:end-1)))./0.04;
        Ax(ID(end)) = Ax(ID(end-1));
        Ay(ID(end)) = Ay(ID(end-1));
        V(ID) = (Vx(ID).^2+Vy(ID).^2).^0.5.*3.6;
        A(ID(1:end-1)) = (V(ID(2:end))-V(ID(1:end-1)))./0.04;
        A(ID(end)) = A(ID(end-1));
        if i == checkid
            x3 = [x(ID)];
            y3 = [y(ID)];
            x4 = [x(outliers)];
            y4 = [y(outliers)];
            V1 = [V(ID)];
        end
    end
    
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
        Ax(ID(end)) = Ax(ID(end-1));
        Ay(ID(end)) = Ay(ID(end-1));
        %重新计算曲率
        for k = 2:length(ID)-1
            [C(ID(k))] = PJcurvature(x(ID(k-1:k+1)),y(ID(k-1:k+1)));
        end
        V(ID) = ((Vx(ID).^2+Vy(ID).^2).^0.5).*3.6;
        A(ID(1:end-1)) = (V(ID(2:end))-V(ID(1:end-1)))./0.04;
        A(ID(end)) = A(ID(end-1));
        if i == checkid
            x5 = [x(ID)];
            y5 = [y(ID)];
            V2 = [V(ID)];
        end
    end
    %% 对极端加速度的点的速度再次样条差值
    for i = 1:E1(end,12)
        ID = find(E1(:,12)==i);
        if length(ID) <= 9
            continue;
        end
        outliers = [];
        if type == 1
            Vlimit = 25;
            Alimit = 10;
        elseif type == 2
            Vlimit = 40;
            Alimit = 10;
        else
            Vlimit = 60;
            Alimit = 10;
        end
        [b,tempoutliers]=sort(A(ID));
        outliers = ID(tempoutliers(end-9:end));
        %     else %（条件：加速度>10m/s^2（机动车）的轨迹点）
        %         Alimit = 10;
        %         for a = 1:length(ID)
        %             if(abs(A(ID(a))) >= Alimit & a >= 11 & a <= length(ID)-10)
        %                 outliers = [outliers,ID(a)];
        %             end
        %         end
        %     end
        %     outliers = ID(find(V(ID) >= Vlimit));%找出超限值
        %     outliers = [outliers(find(outliers >= (ID(1)+10) & outliers <= (ID(end)-10)))];%去除前后不足十个点的值
        denum = 0;
        splinelen = 3;%异常点样条差值长度
        for s = 1:10 %正常则跳过当前轨迹点
            if A(outliers(s-denum)) <= 10 || outliers(s-denum) > ID(end - splinelen-3) || outliers(s-denum) < ID(1+splinelen)%末位点会上卷，为避免速度插值时受影响，避开最后3个点
                outliers(s-denum) = [];
                denum = denum+1;
            end
        end
        if isempty(outliers)%为空则跳过当前轨迹
            if i == checkid
                x6 = [x(ID)];
                y6 = [y(ID)];
                x7 = [x(outliers)];
                y7 = [y(outliers)];
            end
            continue;
        end
        outliers = sort(outliers);%确保插值是从前往后
        for k = 1:length(outliers)
            j = outliers(k);
            t0 = linspace(j-splinelen,j+splinelen,2*splinelen+1);
            %重新插值轨迹点（方法：三次样条差值法）；
            tempVx = [Vx(j-splinelen),Vx(j+splinelen)];
            tempVy = [Vy(j-splinelen),Vy(j+splinelen)];
            Vx(j-splinelen:j+splinelen) = spline([j-splinelen,j+splinelen],tempVx,t0);
            Vy(j-splinelen:j+splinelen) = spline([j-splinelen,j+splinelen],tempVy,t0);
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
        %⑥重新计算位置和加速度
        for j = 2:length(ID)
            x(ID(j)) = x(ID(j-1)) + Vx(ID(j-1))*0.04 + 0.5*Ax(ID(j-1))*0.04^2;
            y(ID(j)) = y(ID(j-1)) + Vy(ID(j-1))*0.04 + 0.5*Ay(ID(j-1))*0.04^2;
            Ax(ID(j-1)) = (Vx(ID(j)) - Vx(ID(j-1)))/0.04;
            Ay(ID(j-1)) = (Vy(ID(j)) - Vy(ID(j-1)))/0.04;
        end
        %重新计算曲率
        for k = 2:length(ID)-1
            [C(ID(k))] = PJcurvature(x(ID(k-1:k+1)),y(ID(k-1:k+1)));
        end
        V(ID) = ((Vx(ID).^2+Vy(ID).^2).^0.5).*3.6;
        A(ID(1:end-1)) = (V(ID(2:end))-V(ID(1:end-1)))./0.04;
        A(ID(end)) = A(ID(end-1));
        if i == checkid
            x6 = [x(ID)];
            y6 = [y(ID)];
            x7 = [x(outliers)];
            y7 = [y(outliers)];
        end
    end
    
    %% 对极端曲率的点的坐标再次样条差值
    for i = 1:E1(end,12)
        ID = find(E1(:,12)==i);
        if length(ID) <= 9
            continue;
        end
        outliers = ID(find(abs(C(ID)) > 1));
        splinelen = 10;%异常点样条差值长度
        if isempty(outliers)%为空则跳过当前轨迹
            if i == checkid
                x6 = [x(ID)];
                y6 = [y(ID)];
                x7 = [x(outliers)];
                y7 = [y(outliers)];
            end
            continue;
        end
        outliers = sort(outliers);%确保插值是从前往后
        for k = 1:length(outliers)
            j = outliers(k);
            if ( j-splinelen < ID(1))
                j = ID(1) + splinelen;
            end
            if ( j+splinelen > ID(end) )
                j = ID(end) - splinelen;
            end
            t0 = linspace(j-splinelen,j+splinelen,2*splinelen+1);
            %重新插值轨迹点（方法：三次样条差值法）；
            tempx = [x(j-splinelen),x(j+splinelen)];
            tempy = [y(j-splinelen),y(j+splinelen)];
            x(j-splinelen:j+splinelen) = spline([j-splinelen,j+splinelen],tempx,t0);
            y(j-splinelen:j+splinelen) = spline([j-splinelen,j+splinelen],tempy,t0);
            %重新插值轨迹点（方法：bw滤波）；
            %         [b1,a1]=butter(5,Wc);
            %         tempx = [x(j-splinelen:j+splinelen)];
            %         tempy = [y(j-splinelen:j+splinelen)];
            %         x(j-splinelen:j+splinelen)=filtfilt(b1,a1,tempx);  %分别做VxVy的滤波
            %         y(j-splinelen:j+splinelen)=filtfilt(b1,a1,tempy);
        end
        %⑥重新计算位置和加速度
        Vx(ID(1:end-1)) = (x(ID(2:end))-x(ID(1:end-1)))./0.04;
        Vy(ID(1:end-1)) = (y(ID(2:end))-y(ID(1:end-1)))./0.04;
        Vx(ID(end)) = Vx(ID(end-1));
        Vy(ID(end)) = Vy(ID(end-1));
        %计算加速度
        Ax(ID(1:end-1)) = (Vx(ID(2:end))-Vx(ID(1:end-1)))./0.04;
        Ay(ID(1:end-1)) = (Vy(ID(2:end))-Vy(ID(1:end-1)))./0.04;
        Ax(ID(end)) = Ax(ID(end-1));
        Ay(ID(end)) = Ay(ID(end-1));
        V(ID) = (Vx(ID).^2+Vy(ID).^2).^0.5.*3.6;
        A(ID(1:end-1)) = (V(ID(2:end))-V(ID(1:end-1)))./0.04;
        A(ID(end)) = A(ID(end-1));
        %重新计算曲率
        for k = 2:length(ID)-1
            [C(ID(k))] = PJcurvature(x(ID(k-1:k+1)),y(ID(k-1:k+1)));
        end
        if i == checkid
            x6 = [x(ID)];
            y6 = [y(ID)];
            x7 = [x(outliers)];
            y7 = [y(outliers)];
            V1 = [V(ID)];
        end
    end
    
    %% ⑤平滑速度（1阶ButterWorth滤波）；
    for i = 1:E1(end,12)
        ID = find(E1(:,12)==i);
        % 作三阶巴特沃斯低通滤波
        if length(ID)< 9
            continue;
        end
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
        Ax(ID(end)) = Ax(ID(end-1));
        Ay(ID(end)) = Ay(ID(end-1));
        %重新计算曲率
        for k = 2:length(ID)-1
            [C(ID(k))] = PJcurvature(x(ID(k-1:k+1)),y(ID(k-1:k+1)));
            if C(ID(k)) <0.000001
                C(ID(k)) = 0;
            end
            
        end
        V(ID) = ((Vx(ID).^2+Vy(ID).^2).^0.5).*3.6;
        A(ID(1:end-1)) = (V(ID(2:end))-V(ID(1:end-1)))./0.04;
        A(ID(end)) = A(ID(end-1));
        for j = 2:length(ID)
            if abs(Vx(ID(j-1))) <0.00001
                Vx(ID(j-1)) = 0;
            end
            if abs(Ax(ID(j-1))) <0.00001
                Ax(ID(j-1)) = 0;
            end
            if abs(Vy(ID(j-1))) <0.00001
                Vy(ID(j-1)) = 0;
            end
            if abs(Ay(ID(j-1))) <0.00001
                Ay(ID(j-1)) = 0;
            end
            if Ax(ID(j-1)) > AxMax
                Ax(ID(j-1)) = AxMax;
            end
            if Ax(ID(j-1)) < AxMin
                Ax(ID(j-1)) = AxMin;
            end
            if Ay(ID(j-1)) > AyMax
                Ay(ID(j-1)) = AyMax;
            end
            if Ay(ID(j-1)) < AyMin
                Ay(ID(j-1)) = AyMin;
            end
            if A(ID(j-1)) > AMax
                A(ID(j-1)) = AMax;
            end
            if A(ID(j-1)) < AMin
                A(ID(j-1)) = AMin;
            end
            if C(ID(j-1)) > CMax
                C(ID(j-1)) = CMax;
            end
            if C(ID(j-1)) < CMin
                C(ID(j-1)) = CMin;
            end
        end
        if i == checkid
            x8 = [x(ID)];
            y8 = [y(ID)];
            V2 = [V(ID)];
        end
    end
    
    %% 输出不同阶段的轨迹处理情况
%     plot(x1,y1,x2,y2,x3,y3,x5,y5,x6,y6,x8,y8,x4,y4,x7,y7);
%     legend('原始轨迹','1平滑后轨迹','3三次样条差值轨迹','5速度平滑后最终结果','6异常点再平滑结果','8速度再平滑结果','异常点','二次异常点');
    plot(x2,y2,x3,y3,x5,y5,x6,y6,x8,y8);
    legend('1平滑后轨迹','3三次样条差值轨迹','5速度平滑后最终结果','6异常点再平滑结果','8速度再平滑结果','异常点','二次异常点');
    xlabel("X轴坐标（m）");
    ylabel("Y轴坐标（m）");
    % scatter(x1,y1,'.','r');
    % hold on
    % scatter(x2,y2,'*','b');
    % plot(linspace(1,length(V1),length(V1)),V1,linspace(1,length(V2),length(V2)),V2);
    % legend('平滑前','平滑后');
    %% 保存数据
    % title = {'GlobalTime','X[m]','Y[m]','Vx[m/s]','Vy[m/s]','Ax[m/s2]','Ay[m/s2]','Speed[km/h]','Acceleration[m/s2]','Space[m]','Curvature[1/m]','ID','ID_in','ID_straight','type'};
    data = [E1(:,1),x,y,Vx,Vy,Ax,Ay,V,A,E1(:,10),C,E1(:,12:15)];
    % %将间隔时间改为0.12s
    % fdata = [];
    % %由于最后一个点参数无法用运动学公式得出，删除最后一个点
    % for i = 1:data(end,12)
    %     ID = find(data(:,12)==i);
    %     data(ID(end),:) = [];
    %     %将间隔时间改为0.12s
    %     ID = [ID(1:end-1)];
    %     j = 1;
    %     while j <= (length(ID)-2)
    %         fdata = [fdata;data(ID(j),:)];
    %         j = j + 3;
    %     end
    %     %重新编号
    %     ID = find(fdata(:,12)==i);
    %     fdata(ID,13) = linspace(1,length(ID),length(ID));
    % end
    if type == 1
        sheetname = '自行车';
    elseif type == 2
        sheetname = '电动车';
    elseif type == 3
        sheetname = '机动车';
    else
        sheetname = '外卖骑手';
    end
    xlswrite(filename,[title;num2cell(data),txt],sheetname);
    disp("finish!")
    type
end



