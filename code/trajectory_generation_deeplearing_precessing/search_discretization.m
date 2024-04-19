function [perception_point] = search_discretization(perception_Radius,start_point,border_all,Horizontal_rangeAll)
%function include search region and discretization
%first, find some discreazated points (enough number);
%secound,find the point which is in the region

%% %确定范围
end_point_1 = [border_all(1) Horizontal_rangeAll(1)]*perception_Radius;%左下坐标
end_point_2 = [border_all(1) Horizontal_rangeAll(size(Horizontal_rangeAll,2))]*perception_Radius;%左上坐标
end_point_3 = [border_all(size(border_all,2)) Horizontal_rangeAll(1)]*perception_Radius;%右下坐标
end_point_4 = [border_all(size(border_all,2)) Horizontal_rangeAll(size(Horizontal_rangeAll,2))]*perception_Radius;%右上坐标

%%
%firstly find the rearch region
% perception_Radius = 0.2;
% perception_region = 2;
% perception_region = end_point_1(1,1);  %最远距离

long = (end_point_1(1,1):(perception_Radius*(3^0.5)):end_point_3(1,1));%纵向   long = (-perception_region:(perception_Radius*(3^0.5)):(perception_region));%纵向
[~,m] = find(abs(long) == min(abs(long)));%find the midpoint
% if long(1,m)<0%normalizing
%     long = long+min(abs(long));
% else
%     long = long-min(abs(long));
% end
crosswise = (end_point_1(1,2):(perception_Radius/2):end_point_2(1,2));%横向
all_points = [];
index_point = 1;
for i = 1:size(long,2)
    for j = 1:size(crosswise,2) 
        point = [index_point border_all(i) j long(i) crosswise(j)];     %        point = [index_point border_all(i) Horizontal_rangeAll(j) long(i) crosswise(j)];  
        all_points = [all_points;point];
        index_point = index_point+1;
    end
end
% for i = 1:size(crosswise,2)
%     for j = 1:size(long,2) 
%         point = [index_point border_all(j) Horizontal_rangeAll(i) long(1,j) crosswise(1,i)];  
%         all_points = [all_points;point];
%         index_point = index_point+1;
%     end
% end
index_point = 1;
for i = 1:size(all_points,1)
    if ((mod(all_points(i,2),2)==0)&&((mod(all_points(i,3),2)==0)))||(((mod(all_points(i,2),2)~=0)&&((mod(all_points(i,3),2)~=0)))) % if all sodd number or all odd number
        all_points(i,:) = nan;
    else
        all_points(i,1) = index_point;
        index_point = index_point +1;
    end
end
all_points((isnan(all_points(:,1))),:) = [];
%%
% %draw a cycle at the points
% for i = 1:size(all_points,1)
% r=perception_Radius;                                                    %设置半径为20
% theta=0:pi/100:2*pi;                             %以pi/100为圆心角画圆
% x=all_points(i,4)+r*cos(theta);                              %圆心横坐标为40
% y=all_points(i,5)+r*sin(theta);  
% hold on%圆心纵坐标为40
% plot(x,y,'r');  
% pause(0.1);
% end
%%
%next, we find the points which is in the sector region
% all_points_pol = all_points;%id is not change
% all_points_cart = all_points;%id is not change
% [all_points_pol(:,4),all_points_pol(:,5)] = cart2pol(all_points(:,4),all_points(:,5));%Rectangular coordinates into Polar coordinates
% % index = 1;
% % for i = 1:size(all_points_pol,1)%for every points
% %     if (all_points_pol(i,4)<deg2rad(-65))||(all_points_pol(i,4)>deg2rad(65))||((all_points_pol(i,5)>perception_region))
% %         all_points_pol(i,:)=nan;
% %     else
% %         all_points_pol(i,1)=index;
% %         index = index + 1;
% %     end
% % end
% [all_points_cart(:,4),all_points_cart(:,5)] = pol2cart(all_points_pol(:,4),all_points_pol(:,5));%Rectangular coordinates into Polar coordinates
% all_points_cart(:,1) = all_points_pol(:,1);
% all_points_cart((isnan(all_points_cart(:,4))),:) = [];

% 去除点的代码不运行时运行下面这行代码
all_points_cart = all_points;
% scatter(all_points_cart(:,4),all_points_cart(:,5),'*','r')%drow and see the points
%%
% transform the postion into the predicted point
all_points_cart(:,4) = all_points_cart(:,4) + start_point(1,1);
all_points_cart(:,5) = all_points_cart(:,5) + start_point(1,2);
perception_point = all_points_cart;
% scatter(perception_point(:,4),perception_point(:,5),'*','r')%drow and see the points
end

