function [order] = myplot(E,N,order)
%%%做图
plot_E = E(find(E(:,2)==order),:);
plot_N = N(find(N(:,2)==order),:);
scatter(plot_E(:,3),plot_E(:,4),'*','b');
hold on
scatter(plot_N(:,3),plot_N(:,4),'*','r');
% %做横向和纵向的坐标分布情况
% figure(1)
% X = plot_E(:,3);%读取误差
% [M,M1] = hist(X );%求频率  [M,M1] = hist(X , (0:0.5:12));%求频率
% bar(M1,M);
% figure(2)
% Y = plot_E(:,4);%读取误差
% [M,M1] = hist(Y );%求频率  [M,M1] = hist(X , (0:0.5:12));%求频率
% bar(M1,M);
end

