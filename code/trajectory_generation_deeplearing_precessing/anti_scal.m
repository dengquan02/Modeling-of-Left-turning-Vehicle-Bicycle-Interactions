function [output] = anti_scal(input,ratio_test,start_point_test,minE,nu)
%%%%进行数据放缩，每个点以起点为零点变化坐标以后，再除以他们之间的距离。保证数据内部的不变性和数据之间的相似性；基准信息不放缩
output=input;
t=size(output,1);
for i=1:t
    for j=1:minE %处理minE个点；
        for o=1:3:(nu)
             output(i,((j-1)*nu+o))=start_point_test(1,i)+ratio_test(i)*(input(i,((j-1)*nu+o))-start_point_test(1,i))/15;%坐标x减去起点坐标x，除以他们之间的距离，以求放缩到同一水平,最后加回来； 
             output(i,((j-1)*nu+o+1))=start_point_test(2,i)+ratio_test(i)*(input(i,((j-1)*nu+o+1))-start_point_test(2,i))/15;%坐标y减去起点坐标y，除以他们之间的距离，以求放缩到同一水平，最后加回来； 
        end
    end
end
end