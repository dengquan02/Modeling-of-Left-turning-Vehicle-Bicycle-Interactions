function [final_gj] = traj_clean_real(gj,T)
% 对任意一条轨迹的速度和加速度重新计算
%采样时间间隔为T，默认为0.04s
%12是速度，13是加速度，6是位置
hs = 3.2808;
ls_re = gj;
for j = 2:size(ls_re,1)-1
    ls_re(j,12) = [ls_re(j+1,6)-ls_re(j-1,6)]/(2*T);
    ls_re(j,13) = [ls_re(j+1,6)+ls_re(j-1,6)-2*ls_re(j,6)]/T^2;
end
ls_orig = ls_re;
% Step 1.removing the outliers
% 清除异常值,加速度阈值大于10*3.2808的轨迹重新规划
for j = 1:size(ls_re,1)
    if abs(ls_re(j,13)) > 10*hs & j > 10 & j < size(ls_re,1)-10
        traj = ls_re(j-10:j+10,:);
        % 三次样条差值
        x = [traj(1,2),traj(end,2)];
        y = [traj(1,6),traj(end,6)];
        xi = traj(1:end,2);
        yi = spline(x,y,xi);
        traj(:,6) = yi;
        % 速度和加速度也重新计算
        for jj = 2:size(traj,1)-1
            traj(jj,12) = (traj(jj+1,6)-traj(jj-1,6))/(2*T);
            traj(jj,13) = (traj(jj+1,6)-2*traj(jj,6)+traj(jj-1,6))/T^2;
        end
        ls_re(j-10:j+10,:) = traj;
    end
end
% Step 2 cutting off the high- and medium-frequency responses in the speed profile
% 用Low Pass Filter / 一阶Butterworth低通滤波器 平滑速度
v_raw = ls_re(:,12);
v_filter = lowpass(v_raw,1,1/T);  % x 一维信号，fpass：截止频率，fs：采样频率。
% wc = 2 * 1 / 10; % 截断频率1Hz，采样频率10Hz
% [b,a] = butter(1,wc); % 一阶
% v_filter = filter(b,a,v_raw);
ls_re(:,12) = v_filter;
% % 扔掉前5个时间步的数据，前5秒换成原始数据
% ls_re = [ls_re(6:end,:)]; % ls_orig(1:5,:);
% 位置加速度重新计算
for j = 2:size(ls_re,1)
    ls_re(j,6) = ls_re(j-1,6) + 0.5*T*(ls_re(j-1,12)+ls_re(j,12));
    ls_re(j-1,13) = (ls_re(j,12) - ls_re(j-1,12))/T;
end
% Step 3 Removing the Residual Unphysical Acceleration Values, Preserving the Consistency Requirements
% 应用5次多项式差值对加速度大于5m/s^2的轨迹重新规划
for j = 1:size(ls_re,1)
    if abs(ls_re(j,13)) > 5*hs & j > 10 & j < size(ls_re,1)-10
        traj = ls_re(j-10:j+10,:);
        % 5次多项式拟合
        x = [traj(1:end,2)];
        y = [traj(1:end,6)];
        p = polyfit(x,y,5);
        xi = traj(1:end,2);
        yi = polyval(p,xi);
        traj(:,6) = yi;
        % 速度和加速度也重新计算
        for jj = 2:size(traj,1)-1
            traj(jj,12) = (traj(jj+1,6)-traj(jj-1,6))/(2*T);
            traj(jj,13) = (traj(jj,12)-traj(jj-1,12))/T;
        end
        ls_re(j-5:j+5,:) = traj(6:16,:);
    end
end
% Step 4 Cutting Off the High- and Medium-Frequency Responses Generated from Step 3
% 用Low Pass Filter 平滑速度
v_raw = ls_re(:,12);
v_filter = lowpass(v_raw,1,10);  % x 一维信号，fpass：截止频率，fs：采样频率。
% wc = 2 * 1 / 10; % 截断频率1Hz，采样频率10Hz
% [b,a] = butter(1,wc); % 一阶
% v_filter = filter(b,a,v_raw);
ls_re(:,12) = v_filter;
% % 扔掉前5个时间步的数据，前5秒换成原始数据
ls_re = [ls_re(15:end-15,:)]; % ls_orig(1:5,:);
% 位置加速度重新计算
for j = 2:size(ls_re,1)
    ls_re(j,6) = ls_re(j-1,6) + 0.5*T*(ls_re(j-1,12)+ls_re(j,12));
    ls_re(j-1,13) = (ls_re(j,12) - ls_re(j-1,12))/T;
end
% % 位置-时间图对比
%     figure(1)
%     hold on
%     plot(ls_orig(:,2),ls_orig(:,6),'-k');
%     plot(ls_re(:,2),ls_re(:,6),'-c');
% %     plot(ls_re(:,2),ls_re(:,6),'-r');
%     % 速度-时间图
%     figure(2)
%     hold on
%     plot(ls_orig(:,2),ls_orig(:,12),'-b');
%     plot(ls_re(:,2),ls_re(:,12),'-c');
%     % 加速度-时间图
%     figure(3)
%     hold on
%     plot(ls_orig(:,2),ls_orig(:,13),'-r');
%     plot(ls_re(:,2),ls_re(:,13),'-c');
%     plot(ls_re(:,2),ones(length(ls_re),1)*5*hs,'-k');
%     plot(ls_re(:,2),-1*ones(length(ls_re),1)*5*hs,'-k');
%     clf(figure(1))
%     clf(figure(2))
%     clf(figure(3))
final_gj = ls_re;
end










