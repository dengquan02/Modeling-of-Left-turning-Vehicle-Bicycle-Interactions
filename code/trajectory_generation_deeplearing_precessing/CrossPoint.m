function  [output] = CrossPoint(input_trajectory_1,input_trajectory_2)
%% 求线段的交点坐标
p1 = reshape(input_trajectory_1',1,[]);%其中一个线段，两个端点  真实轨迹
p2 = reshape(input_trajectory_2',1,[]);%另一个线段，两个端点  预测轨迹


k1=(p1(2)-p1(4))/(p1(1)-p1(3));
b1=p1(2)-k1*p1(1);

k2=(p2(2)-p2(4))/(p2(1)-p2(3));
b2=p2(2)-k2*p2(1);

% %做个图瞧一瞧嘛
% line([p1(1); p1(3)], [p1(2); p1(4)]);
% hold on
% line([p2(1); p2(3)], [p2(2); p2(4)]);

x=-(b1-b2)/(k1-k2);             %求两直线交点
y=-(-b2*k1+b1*k2)/(k1-k2);

%判断交点是否在两线段上,这里用了误差小于0.01则表示相等，因为数据可能有极其微小的差别，但实际上他们是相等的
if min(p1(1),p1(3))-x<=0.001 && x-max(p1(1),p1(3))<=0.001 && ...
    min(p1(2),p1(4))-y<=0.001 && y-max(p1(2),p1(4))<=0.001 && ...
    min(p2(1),p2(3))-x<=0.001 && x-max(p2(1),p2(3))<=0.001 && ...
    min(p2(2),p2(4))-y<=0.001 && y-max(p2(2),p2(4))<=0.001
%     plot(x,y,'r.');%x y即为当前的交点
    output = [x,y];%输出交点坐标
%     disp("合适")
else
    output = [];
end

end