%% 本脚本的目标是将数据按照车型分类，便于下一步的平滑处理
tic;
[data,txt,allfile]=xlsread('C:\Users\honly\Desktop\4-桂林路吴中路东侧-转换后轨迹数据(改正异常时间间隔).xlsx',1);
filename = 'C:\Users\honly\Desktop\按车型分类数据（三分类）.xlsx';
title = txt(1,1:19);
txt = txt(2:end,16:19);

sheet1name = '自行车';
sheet1data = find(data(:,15) == 1);
data(sheet1data(1),12) = 1;
for i = 2:length(sheet1data)
   if data(sheet1data(i),13) >  data(sheet1data(i-1),13)
       data(sheet1data(i),12) = data(sheet1data(i-1),12);
   else
       data(sheet1data(i),12) = data(sheet1data(i-1),12)+1;
   end
end

sheet2name = '电动车';
sheet2data = find(data(:,15) == 2);
data(sheet2data(1),12) = 1;
for i = 2:length(sheet2data)
   if data(sheet2data(i),13) >  data(sheet2data(i-1),13)
       data(sheet2data(i),12) = data(sheet2data(i-1),12);
   else
       data(sheet2data(i),12) = data(sheet2data(i-1),12)+1;
   end
end

sheet3name = '机动车';
sheet3data = find(data(:,15) == 3);
data(sheet3data(1),12) = 1;
for i = 2:length(sheet3data)
   if data(sheet3data(i),13) >  data(sheet3data(i-1),13)
       data(sheet3data(i),12) = data(sheet3data(i-1),12);
   else
       data(sheet3data(i),12) = data(sheet3data(i-1),12)+1;
   end
end

xlswrite(filename,[title;[num2cell(data(sheet1data,:)),txt(sheet1data,:)]],sheet1name);
xlswrite(filename,[title;[num2cell(data(sheet2data,:)),txt(sheet2data,:)]],sheet2name);
xlswrite(filename,[title;[num2cell(data(sheet3data,:)),txt(sheet3data,:)]],sheet3name);
disp("finish!")