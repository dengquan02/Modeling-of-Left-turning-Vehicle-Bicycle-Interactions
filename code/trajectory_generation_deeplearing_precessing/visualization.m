function [path] = visualization(extract_trajectory,path,index_in,perception_Radius)
%可视化
% extract_one是真实轨迹
% path是预测轨迹
truth = extract_trajectory(index_in:min((index_in+20),size(extract_trajectory,1)),4:5);
scatter(truth(:,1),truth(:,2),'*','b')
hold on 
%%
%draw a cycle at the points
for i = 1:size(path,1)
r=perception_Radius;                                                    %设置半径为20
theta=0:pi/100:2*pi;                             %以pi/100为圆心角画圆
x=path(i,1)+r*cos(theta);                              %圆心横坐标为40
y=path(i,2)+r*sin(theta);  
hold on%圆心纵坐标为40
plot(x,y,'r');  
pause(0.1);
end



end

