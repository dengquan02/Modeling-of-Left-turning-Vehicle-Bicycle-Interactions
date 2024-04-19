function [x] = cycle_draw(input1,input2)

aplha=0:pi/40:2*pi;
r=input2;
x=input1(1,1)+r*cos(aplha);
y=input1(1,2)+r*sin(aplha);
z=ones(size(x,1),size(x,2))*8;
plot3(x,y,z,'-','Color','k');

end

