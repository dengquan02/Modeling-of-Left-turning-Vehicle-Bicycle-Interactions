%% 本脚本的目的是将按照车型分类并且已经平滑好的数据按照行为分类

[data1,txt1]=xlsread('C:\Users\honly\Desktop\按车型分类数据（三分类）(已处理).xlsx',1);
[data2,txt2]=xlsread('C:\Users\honly\Desktop\按车型分类数据（三分类）(已处理).xlsx',2);
[data3,txt3]=xlsread('C:\Users\honly\Desktop\按车型分类数据（三分类）(已处理).xlsx',3);
filename = 'C:\Users\honly\Desktop\分类完成数据.xlsx';
title = txt1(1,1:15);
txt1 = txt1(2:end,16:19);
txt2 = txt2(2:end,16:19);
txt3 = txt3(2:end,16:19);
%% 提取非机动车左转数据到表1
%提取的是data1和data2的东南左转
sheet1name = 'E1S';
sheet1data = [];
sheet1data = [sheet1data;data1(find(strcmp(txt1(:,1),'左转') & strcmp(txt1(:,2),'东-南')),:)];
sheet1data = [sheet1data;data2(find(strcmp(txt2(:,1),'左转') & strcmp(txt2(:,2),'东-南')),:)];
%重新对轨迹编号
if ~isempty(sheet1data)
    sheet1data(1,12) = 1;
    for i = 2:length(sheet1data)
        if sheet1data(i,13) > sheet1data(i-1,13)
            sheet1data(i,12) = sheet1data(i-1,12);
        else
            sheet1data(i,12) = sheet1data(i-1,12)+1;
        end
    end
end
%% 提取机动车左转数据到表2
%提取的是data3的东南左转
sheet2name = 'E1SV';
sheet2data = [];
sheet2data = [sheet2data;data3(find(strcmp(txt3(:,1),'左转') & strcmp(txt3(:,2),'东-南')),:)];
%重新对轨迹编号
if ~isempty(sheet2data)
    sheet2data(1,12) = 1;
    for i = 2:length(sheet2data)
        if sheet2data(i,13) > sheet2data(i-1,13)
            sheet2data(i,12) = sheet2data(i-1,12);
        else
            sheet2data(i,12) = sheet2data(i-1,12)+1;
        end
    end
end

%% 提取其他数据到表4
%提取的是data1，data2,data3的其他数据
sheet3name = 'OTHER';
sheet3data = [];
sheet3data = [sheet3data;data1(find(~(strcmp(txt1(:,1),'左转') & strcmp(txt1(:,2),'东-南'))),:)];
sheet3data = [sheet3data;data2(find(~(strcmp(txt2(:,1),'左转') & strcmp(txt2(:,2),'东-南'))),:)];
sheet3data = [sheet3data;data3(find(~(strcmp(txt3(:,1),'左转') & strcmp(txt3(:,2),'东-南'))),:)];
%重新对轨迹编号
if ~isempty(sheet3data)
    sheet3data(1,12) = 1;
    for i = 2:length(sheet3data)
        if sheet3data(i,13) > sheet3data(i-1,13)
            sheet3data(i,12) = sheet3data(i-1,12);
        else
            sheet3data(i,12) = sheet3data(i-1,12)+1;
        end
    end
end

xlswrite(filename,[title;num2cell(sheet1data)],sheet1name);
xlswrite(filename,[title;num2cell(sheet2data)],sheet2name);
xlswrite(filename,[title;num2cell(sheet3data)],sheet3name);
disp("finish!")