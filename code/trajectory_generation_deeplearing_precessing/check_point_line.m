function [outputArg] = check_point_line(cro_point_1,input_1,input_2)
%检查点 是否在线上
%输入检查数据，运行时X掉
% cro_point_1 = cro_point(1,:);
% input_1 = input_trajectory_1(j,:);
% input_2 = input_trajectory_1(j+1,:);

OA = cro_point_1 - input_1;
OB = cro_point_1 - input_2;
if norm(OA)==0||norm(OB)==0
    outputArg = 1;%在线上
else
    cosOAOB = OA*OB'/(norm(OA)*norm(OB));
    if cosOAOB - (-1)<0.01 %若余弦值为-1，则说明点在线上  ,这里有个误差0.0001，因为直接相等可能做不到；
        outputArg = 1;
    else
        outputArg = 0;%若不等于-1，则不在线上
    end
end
end
