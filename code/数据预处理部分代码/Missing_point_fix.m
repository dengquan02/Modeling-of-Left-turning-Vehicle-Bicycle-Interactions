%% 本脚本的目标是补充不等时间间距的轨迹点（间距为0.08,0.12,0.16，需要先视情况手动处理间隔过大的轨迹点）
tic;
%% 读取数据
filename1 = 'C:\Users\honly\Desktop\4-桂林路吴中路东侧-转换后轨迹数据(改正异常时间间隔).xlsx';
%将每个轨迹点对应的机动车和非机动车坐标放到同一行上,14列
[data,txt,allfile]=xlsread('C:\Users\honly\Desktop\4-桂林路吴中路东侧-转换后轨迹数据(改正部分异常时间间隔).xlsx',1);
%2轨迹编号，7轨迹点编号，8时间戳，9X,10Y
txt = [txt(2:end,2),txt(2:end,10:13)];
data = [data(:,2),data(:,7:12), data(:,14:19)];
[a,b] = size(txt);
data = [data,ones(a,1)];
for i = 1 : a
    if strcmp(txt(i,1),'自行车')
        data(i,14) = 1;
    elseif strcmp(txt(i,1),'机动车')
        data(i,14) = 3;
    else
        data(i,14) = 2;
    end
end
disp("read finish!");
for i = 1:data(end,1)
    ID = find(data(:,1)==i);
    addnum = 0;
    for j = 2:length(ID)
        if (0.078<data(ID(j)+addnum,13)) && (data(ID(j)+addnum,13) < 0.082)
            data(ID(j)+addnum,13) = 0.04;
            data(ID(j)+addnum:ID(end)+addnum,2) = [data(ID(j)+addnum:ID(end)+addnum,2)+1];
            data = [data(1:ID(j)+addnum-1,:);
                data(ID(j)+addnum-1,1),data(ID(j)+addnum-1,2)+1,(data(ID(j)+addnum-1,3:12)+data(ID(j)+addnum,3:12))./2,0.04,data(ID(j)+addnum-1,14);
                data(ID(j)+addnum:end,:)];
            txt = [txt(1:ID(j)+addnum-1,:);txt(ID(j)+addnum,:);txt(ID(j)+addnum:end,:)];
            addnum = addnum+1;
        elseif (0.11<data(ID(j)+addnum,13)) && (data(ID(j)+addnum,13) < 0.13)
            data(ID(j)+addnum,13) = 0.04;
            data(ID(j)+addnum:ID(end)+addnum,2) = [data(ID(j)+addnum:ID(end)+addnum,2)+2];
            data = [data(1:ID(j)+addnum-1,:);
                data(ID(j)+addnum-1,1),data(ID(j)+addnum-1,2)+1,data(ID(j)+addnum-1,3:12)+(data(ID(j)+addnum,3:12)-data(ID(j)+addnum-1,3:12))./3,0.04,data(ID(j)+addnum-1,14);
                data(ID(j)+addnum-1,1),data(ID(j)+addnum-1,2)+2,data(ID(j)+addnum-1,3:12)+(data(ID(j)+addnum,3:12)-data(ID(j)+addnum-1,3:12)).*(2/3),0.04,data(ID(j)+addnum-1,14);
                data(ID(j)+addnum:end,:)];
            txt = [txt(1:ID(j)+addnum-1,:);txt(ID(j)+addnum,:);txt(ID(j)+addnum,:);txt(ID(j)+addnum:end,:)];
            addnum = addnum+2;
        elseif(0.15<data(ID(j)+addnum,13)) && (data(ID(j)+addnum,13) < 0.17)
            data(ID(j)+addnum:ID(end)+addnum,2) = [data(ID(j)+addnum:ID(end)+addnum,2)+3];
            data = [data(1:ID(j)+addnum-1,:);
                data(ID(j)+addnum-1,1),data(ID(j)+addnum-1,2)+1,data(ID(j)+addnum-1,3:12)+(data(ID(j)+addnum,3:12)-data(ID(j)+addnum-1,3:12))./4,0.04,data(ID(j)+addnum-1,14);
                data(ID(j)+addnum-1,1),data(ID(j)+addnum-1,2)+2,data(ID(j)+addnum-1,3:12)+(data(ID(j)+addnum,3:12)-data(ID(j)+addnum-1,3:12))./2,0.04,data(ID(j)+addnum-1,14);
                data(ID(j)+addnum-1,1),data(ID(j)+addnum-1,2)+3,data(ID(j)+addnum-1,3:12)+(data(ID(j)+addnum,3:12)-data(ID(j)+addnum-1,3:12)).*(3/4),0.04,data(ID(j)+addnum-1,14);
                data(ID(j)+addnum:end,:)];
            txt = [txt(1:ID(j)+addnum-1,:);txt(ID(j)+addnum,:);txt(ID(j)+addnum,:);txt(ID(j)+addnum,:);txt(ID(j)+addnum:end,:)];
            addnum = addnum+3;
        end
    end
    %重新编号
    ID = find(data(:,1)==i);
    data(ID,2) = linspace(1,length(ID),length(ID));
end
[a,b] = size(data);
data = [data(:,3) data(:,4:7) data(:,9:10) data(:,8) data(:,11) zeros(a,1) data(:,12) data(:,1:2) zeros(a,1) data(:,14)];
title = {'GlobalTime','X[m]','Y[m]','Vx[m/s]','Vy[m/s]','Ax[m/s2]','Ay[m/s2]','Speed[km/h]','Acceleration[m/s2]','Space[m]','Curvature[1/m]','ID','ID_in','ID_straight','type','骑行方向','骑行具体方向','违章与否','具体违章类型'};
xlswrite(filename1,[title;[num2cell(data),txt(:,2:end)]]);
disp("fix finish!")

% if type == 1
%     sheetname = 'ES1';
% elseif type == 2
%     sheetname = 'ES1V';
% else
%     sheetname = 'EN1V';
% end




