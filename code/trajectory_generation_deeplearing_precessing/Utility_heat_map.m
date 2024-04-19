function [output] = Utility_heat_map(optimal_solution_order)
%利用optimal_solution_order做效用函数的热力图
%% 先进行变换，将约束转化至效用值中
input_order = optimal_solution_order;

input_order(:,3) = -input_order(:,3);%原来是求最小值，因此这里取负号
input_order(:,3) = input_order(:,3) + (-input_order(:,4));
input_order = sortrows(input_order,-3);
input_order(:,3) = sortrows([1:size(input_order,1)]',-1) ;
input_order(:,3) = (input_order(:,3)-min(input_order(:,3)))/(max(input_order(:,3))-min(input_order(:,3)));

%% 旧方法 做热力图
% %定义初始点
% X=input_order(:,1);
% Y=input_order(:,2);
% Xmin=min(X);Xmax=max(X);
% Ymin=min(Y);Ymax=max(Y);
% %分割区域大小
% Nx=size(unique(input_order(:,1)),1);
% Ny=size(unique(input_order(:,2)),1);
% 
% %分割的边 ,也是整个道路的坐标
% Xedge=linspace(Xmin,Xmax,100);  %Xedge=linspace(Xmin,Xmax,Nx);
% Yedge=linspace(Ymin,Ymax,100);
% 
% % N = input_order(:,3)';
% %统计每个区域的点个数（N的xy定义是转置的）
% [N,~,~,binX,binY] = histcounts2(X,Y,[-inf,Xedge(2:end-1),inf],[-inf,Yedge(2:end-1),inf]);
% 
% XedgeM=movsum(Xedge,2)/2;
% YedgeM=movsum(Yedge,2)/2;
% %构建绘图网格
% [Xedgemesh,Yedgemesh]=meshgrid(XedgeM(2:end),YedgeM(2:end)); %生成网络
% 
% %绘制pcolor图
% figure(2)
% pcolor(Xedgemesh,Yedgemesh,N');shading interp
% %根据pcolor图的颜色绘制散点图颜色
% ind = sub2ind(size(N),binX,binY);
% col = N(ind);
% 
% % figure(2)
% % plot(X,Y,'x')
% %绘制散点图
% % figure(3)
% % scatter(X,Y,20,col,'filled');
% 
% % 赋予N
% N=input_order(:,3);
% 
% %绘制密度高程图
% figure(4)
% [XX,YY,ZZ]=griddata(Xedgemesh,Yedgemesh,N',Xedge',Yedge,'V4');%插入z值
% surf(XX,YY,ZZ);%这里有区别
% shading interp
% % 
% % 
output=input_order;

%% 新方法
As = input_order(:,3);%效用值
X = input_order(:,1);
Y= input_order(:,2);
% Xedge=linspace(min(X),max(X),100);
% Yedge=linspace(min(Y),max(Y),100);
[x,y] = meshgrid(min(X):0.2:max(X),min(Y):0.2:max(Y));%2e4=20000
z = griddata(X,Y,As,x,y,'v4');%差值
% c = contour(x.y,z);
surf(x,y,z);%这里有区别
% view([0,0,1])

%% 做两个立面的投影 x立面上
x_0 = max(max(x))+2;%做个x，全都约定最大值
x_0 = ones(size(x,1),size(x,2))*x_0;%做个x，全都是0
for i = 1:size(z,1)
    z_x(i,:)=max(z(i,:));
    if i==1||i==size(z,1)%仅仅是为了图好看，让线接到地上
       z_x(i,:)=0; 
    end
end

hold on
plot3(x_0,y,z_x,'black');%这里有区别

%% 做两个立面的投影 y立面上
y_0 = max(max(y))+2;%做个x，全都约定最大值
y_0 = ones(size(y,1),size(y,2))*y_0;%做个x，全都是0
for i = 1:size(z,2)
    z_y(:,i)=max(z(:,i));
        if i==1||i==size(z,2)%仅仅是为了图好看，让线接到地上
             z_y(:,i)=0; 
        end
end

hold on
plot3(x,y_0,z_y,'black');%这里有区别


end