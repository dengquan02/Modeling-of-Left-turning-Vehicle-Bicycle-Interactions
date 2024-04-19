function [output] = change_rad(E1,VAL)
%旋转一定的角度，逆时针
%VAL是度数
for i = 1:size(E1,1)%将所有带有坐标式的值都偏移3.76度
    for j = 2:2:7
        [theta,r] = cart2pol(E1(i,j),E1(i,j+1));
        [E1(i,j),E1(i,j+1)] = pol2cart(deg2rad(rad2deg(theta)+VAL),r);
    end
end
output = E1;
end

