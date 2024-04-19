function [output,output_dis] = cross_dis(input1,input2)
%该函数的作用是计算预测轨迹和真实轨迹在相同时间点下的横坐标之差
%希望不要太高，目前标准是左侧不低于1.5，右侧不低于0.5；
%若output = 1,表示突发事件预测准确
% out_dis表示超过的误差距离
% input1 = Truth_no(:,4:5);%真实轨迹
% input2 = output1;%预测轨迹
left = 0;%误差
right = 0;
%% Method①:利用相同时间轨迹点计算差异
% dis_all = [];%存放横向距离差
% output_if_unmutation = [];
% for i = 1:size(input1,1)
%     if input2(i,2)>=(input1(i,2)-left)&&input2(i,2)<=(input1(i,2)+right)%如果预测值在精度范围内
%         cro_dis = 0 ;%误差等于0
%     elseif input2(i,2)<(input1(i,2)-left)&&input2(i,2)<(input1(i,2)+right)%如果预测值在左侧外
%         cro_dis = input2(i,2) - (input1(i,2)- left);%预测值减去真实值-1.5
%     elseif input2(i,2)>(input1(i,2)-left)&&input2(i,2)>(input1(i,2)+right)%如果预测值在右侧
%         cro_dis = input2(i,2) - (input1(i,2)+ right);%预测值减去真实值+0.5
%     end
% %     disp(cro_dis)
%     output_if = sign(cro_dis);%计算出在哪里
%     output_if_unmutation = [output_if_unmutation;output_if];
%     dis_all = [dis_all;cro_dis];
% end
% if sum(output_if_unmutation)~=0
%     ID_dis = find(abs(dis_all)==max(abs(dis_all)));%找到误差最大的点
% %     disp('最大值')
% %     disp(ID_dis)
%     output_dis = dis_all(ID_dis);
% else 
%     output_dis = 0;
% end
% output = 1-sign(sum(abs(output_if_unmutation)));

%% Method②:利用真实和预测轨迹的最远值直接计算
extend_hor_GT = min(input1(:,2));%真实轨迹最外侧轨迹点的横向坐标（即本文里的纵坐标）
extend_hor_pre = min(input2(:,2));%预测轨迹最外侧轨迹点的横向坐标（即本文里的纵坐标）
output_dis = extend_hor_pre - extend_hor_GT;%最外侧的预测值-真实值，正值表示预测的在内侧，负值表示预测的在外侧；
if output_dis<right&&output_dis>-left
    output = 1;
else
    output = 0;
end
end
