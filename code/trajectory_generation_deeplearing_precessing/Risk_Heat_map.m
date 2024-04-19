function [Risk] = Risk_Heat_map(Risk)
%定义初始点
X=Risk(:,1);
Y=Risk(:,2);
Xmin=min(X);Xmax=max(X);
Ymin=min(Y);Ymax=max(Y);
%分割区域大小
Nx=100;
Ny=100;

%分割的边 ,也是整个道路的坐标
Xedge=linspace(Xmin,Xmax,Nx);
Yedge=linspace(Ymin,Ymax,Ny);

%统计每个区域的点个数（N的xy定义是转置的）
[N,~,~,binX,binY] = histcounts2(X,Y,[-inf,Xedge(2:end-1),inf],[-inf,Yedge(2:end-1),inf]);

XedgeM=movsum(Xedge,2)/2;
YedgeM=movsum(Yedge,2)/2;
%构建绘图网格
[Xedgemesh,Yedgemesh]=meshgrid(XedgeM(2:end),YedgeM(2:end));

%绘制pcolor图
figure(1)
pcolor(Xedgemesh,Yedgemesh,N');shading interp
%根据pcolor图的颜色绘制散点图颜色
ind = sub2ind(size(N),binX,binY);
col = N(ind);

% figure(2)
% plot(X,Y,'x')
%绘制散点图
% figure(3)
% scatter(X,Y,20,col,'filled');

%绘制密度高程图
figure(4)
[XX,YY,ZZ]=griddata(Xedgemesh,Yedgemesh,N',Xedge',Yedge,'V4');
surf(XX,YY,ZZ);%这里有区别
shading interp
end

