function [Risk] = Risk_calculation(input,extract,intrusion_cood_E,G,R_b,k1,k3,char_intrusion,char_end,index_end,char_intrusion_right,char_end_right,index_end_right)
%% 双层模型的代码
%包括机非动态交互对象、横向偏移距离、纵向终点距离危险度
%intrusion_cood_E是基准坐标
%extract = extract_time_i(2,:)%是环境交互对象
%input是风险计算主体位置shap = （1,2）
% input=truth_point;
% extract=extract_time_i(2:size(extract_time_i,1),:);
% extract=extract_time_i(2:size(extract_time_i,1),:);
%%输入参数
G=0.12;%原来是0.1 表达大小  0.12   %%%%%%%%%%%%%%这里换过了
% R_b = 1;
% M_b = 2000;
k1 = 1;%Parameter(1)  原来是1  表示与距离的关系
k3 = 0.05;%%Parameter(2) 0.5  表示与速度角度的关系
% char_intrusion = 1;%这三个是机动车方向的参数  %Parameter(3)   1 0.8 1 5 0.2
char_end = 6;  %Parameter(4) 5   6   %%%%%%%%%%%%%%这里换过了
index_end = 0.1;  %Parameter(5)  0.4   0.1    %%%%%%%%%%%%%%这里换过了
% char_intrusion_right = 2;%这三个是行人方向的参数
char_end_right = 5;
index_end_right = 0.4;
index_int = 2.2;  %2.2
char_int = 0.1;%0.1
%% 开始计算风险值
% k4=%Parameter(6)
%入侵风险  机动车方向
int_dis = (intrusion_cood_E(1,2)-input(1,2));%入侵距离
if int_dis<0%若入侵距离小于0，则等于0
    int_dis = 0;
end
% R_int = log(int_dis*char_intrusion+1)*[0 1];%[0 -1]表示其方向  ln函数
R_int = char_int*(int_dis.^(index_int))*[0 1];%[0 -1]表示其方向  指数函数
% R_int = char_int*(int_dis.^(index_int));%[0 -1]表示其方向  指数函数
% scatter(int_dis,R_int)
%% 限定最大值
if norm(R_int)>=100
   R_int = 100;%若风险大于10，则等于10
end
%%
%出口道风险  机动车方向
end_dis = (input(1,1)-intrusion_cood_E(3,1));%距离出口道的风险
R_end = char_end*(end_dis.^(index_end))*[-1 0];%[-1 0]表示其方向    R_end = char_end*(index_end.^(-end_dis))*[-1 0];%[-1 0]表示其方向
R_end = norm(R_end) - norm((char_end*((45+10).^(index_end))*[-1 0]));%减去最低点
% if norm(end_dis)<=1
%    R_end = inf;%若距离小于0.2，则风险无穷大
% end
if input(1,2)>intrusion_cood_E(1,2)%若目标未入侵，则归零
    R_end = [0,0];
end



% intrusion_cood_E_right = [47.43 39; 47.43 35.5; 3 39; 3 32.5];
%入侵行人部分的风险场大小，39表示到人行横道的位置，就是风险最大的地方；墨玉路东进口数据

intrusion_cood_E_right = [10 35; 10 26; -45 35; -45 26];
%入侵行人部分的风险场大小，39表示到人行横道的位置，就是风险最大的地方；仙霞路东进口数据

%入侵风险  行人方向
int_dis_right = (input(1,2) - intrusion_cood_E_right(2,2));%入侵距离
if int_dis_right<0%若入侵距离小于0，则等于0
    int_dis_right = 0;
end
% R_int_right = log(int_dis_right*char_intrusion_right+1)*[0 -1];%[0 -1]表示其方向，与入侵至机动车道的风险是相反的；
R_int_right = char_int*(int_dis_right.^(index_int))*[0 -1];%[0 -1]表示其方向  指数函数
%% 限定最大值
if norm(R_int_right)>=100
   R_int_right = 100;%若风险大于10，则等于10,原来是5
end

%% 出口道风险  行人方向
end_dis_right = (input(1,1)-intrusion_cood_E_right(3,1));%距离出口道的风险
R_end_right = char_end_right*(end_dis_right.^(-index_end_right))*[-1 0];%[-1 0]表示其方向
R_end_right = norm(R_end_right) - norm((char_end_right*((10+45).^(-index_end_right))*[-1 0]));%减去最低点
% if norm(end_dis_right)<=1
%    R_end_right = inf;%若距离小于0.2，则风险无穷大
% end
if input(1,2)<intrusion_cood_E_right(2,2)%若目标未入侵，则归零
    R_end_right = [0,0];
end


%动态交互对象风险，没有分机非，只是按照速度分类
% R_inter = zeros(1,2);
R_inter = 0;
for i = 1:size(extract,1)
    inter_direction =- input + extract(i,1:2);%两点之间向量  计算位置-动态交互物体
    if norm(inter_direction)==0
        disp(input)
        disp(extract(i,1:2))
        disp('上面是NaN')
    end
    if extract(i,11)==1%质量不一样，自行车20kg
        M_b = 150;
    elseif extract(i,11)==2
        M_b = 200;%电动车50kg
    elseif extract(i,11)==3
        M_b = 1000;%汽车2000kg
    end
%     co =( ((extract(i,3:4)/norm(extract(i,3:4)))-(inter_direction/norm(inter_direction))));%交互对象速度与二者方位之间角度向量
    co = dot(extract(i,3:4),inter_direction)/((norm(extract(i,3:4))*norm(inter_direction)));
    if isnan(co)%若余弦值不存在，说明此时速度为0，是错误数据，直接给定co为1（即余弦值为1，角度为0）
        co = 1;
    end
%     disp(co)
    R_inter_i = ((G*R_b*M_b)/(norm(inter_direction)^k1))*((inter_direction)/(norm(inter_direction)))*(exp(k3*extract(i,7)/3.6*(co(1,1))));%速度带进去用的是m/s   
% disp('kaile')
% disp(((G*R_b*M_b)/(norm(inter_direction)^k1)))
%         disp(((inter_direction)/(norm(inter_direction))))
% disp((exp(k3*extract(i,7)/3.6*(co(1,1)/norm(co)))))
    R_inter = R_inter+norm(R_inter_i);
%     disp(R_inter_i)
%     if norm(inter_direction)<=0.5
%     disp(R_inter_i)
%     R_inter = R_inter+norm(R_inter_i);
end
%% 限定最大值
if norm(R_inter)>=100  %原来是20
   R_inter = 100;%((inter_direction)/(norm(inter_direction)))*10;%原来是inf  为了做图变成10，之前是100
end
% norm(R_inter)
% norm(inter_direction)

% Risk = norm(R_end)+norm(R_inter)+norm(R_int)+norm(R_int_right) +norm(R_end_right);%风险是标量和，要叠加的；%Risk = norm(R_end)+norm(R_inter)+norm(R_int)

Risk = norm(R_inter);
% disp(Risk)
% if isnan(Risk)
%    disp(input)
% end
% disp(R_inter)

%% 之前的TRB代码
% %包括机非动态交互对象、横向偏移距离、纵向终点距离危险度
% %intrusion_cood_E是基准坐标
% %extract = extract_time_i(2,:)是环境交互对象
% %input是风险计算主体位置shap = （1,2）
% % input=extract_trajectory(index_in,4:5);
% % extract=extract_time_i(2:size(extract_time_i,1),:);
% %%输入参数
% G=0.1;%原来是0.001 表达大小
% % R_b = 1;
% % M_b = 2000;
% k1 = 1;%Parameter(1)  1.5  表示与距离的关系
% k3 = 0.05;%%Parameter(2) 0.5  表示与速度角度的关系
% % char_intrusion = 1;%这三个是机动车方向的参数  %Parameter(3)   1 0.8 1 5 0.2
% char_end = 5;  %Parameter(4) 15
% index_end = 0.4;  %Parameter(5)  0.15
% % char_intrusion_right = 2;%这三个是行人方向的参数
% % char_end_right = 0.2;
% % index_end_right = 2;
% index_int = 2.2;  %2
% char_int = 0.1;%0.1
% %%开始计算风险值
% % k4=%Parameter(6)
% %入侵风险  机动车方向
% int_dis = (intrusion_cood_E(1,2)-input(1,2));%入侵距离
% if int_dis<0%若入侵距离小于0，则等于0
%     int_dis = 0;
% end
% % R_int = log(int_dis*char_intrusion+1)*[0 1];%[0 -1]表示其方向  ln函数
% R_int = char_int*(int_dis.^(index_int))*[0 1];%[0 -1]表示其方向  指数函数
% 
% if norm(R_int)>=10
%    R_int = 10;%若风险大于10，则等于10
% end
% 
% %出口道风险  机动车方向
% end_dis = (input(1,1)-intrusion_cood_E(3,1));%距离出口道的风险
% R_end = char_end*(end_dis.^(index_end))*[-1 0];%[-1 0]表示其方向    R_end = char_end*(index_end.^(-end_dis))*[-1 0];%[-1 0]表示其方向
% R_end = norm(R_end) - norm((char_end*((45+10).^(index_end))*[-1 0]));%减去最低点
% % if norm(end_dis)<=1
% %    R_end = inf;%若距离小于0.2，则风险无穷大
% % end
% if input(1,2)>intrusion_cood_E(1,2)%若目标未入侵，则归零
%     R_end = [0,0];
% end
% 
% 
% 
% % intrusion_cood_E_right = [47.43 39; 47.43 35.5; 3 39; 3 32.5];
% %入侵行人部分的风险场大小，39表示到人行横道的位置，就是风险最大的地方；墨玉路东进口数据
% 
% intrusion_cood_E_right = [10 35; 10 26; -45 35; -45 26];
% %入侵行人部分的风险场大小，39表示到人行横道的位置，就是风险最大的地方；仙霞路东进口数据
% 
% %入侵风险  行人方向
% int_dis_right = (input(1,2) - intrusion_cood_E_right(2,2));%入侵距离
% if int_dis_right<0%若入侵距离小于0，则等于0
%     int_dis_right = 0;
% end
% % R_int_right = log(int_dis_right*char_intrusion_right+1)*[0 -1];%[0 -1]表示其方向，与入侵至机动车道的风险是相反的；
% R_int_right = char_int*(int_dis_right.^(index_int))*[0 -1];%[0 -1]表示其方向  指数函数
% if norm(R_int_right)>=10
%    R_int_right = 10;%若风险大于10，则等于10,原来是5
% end
% 
% %出口道风险  行人方向
% end_dis_right = (input(1,1)-intrusion_cood_E_right(3,1));%距离出口道的风险
% R_end_right = char_end_right*(end_dis_right.^(-index_end_right))*[-1 0];%[-1 0]表示其方向
% R_end_right = norm(R_end_right) - norm((char_end_right*((10+45).^(-index_end_right))*[-1 0]));%减去最低点
% % if norm(end_dis_right)<=1
% %    R_end_right = inf;%若距离小于0.2，则风险无穷大
% % end
% if input(1,2)<intrusion_cood_E_right(2,2)%若目标未入侵，则归零
%     R_end_right = [0,0];
% end
% 
% 
% %动态交互对象风险，没有分机非，只是按照速度分类
% % R_inter = zeros(1,2);
% R_inter = 0;
% for i = 1:size(extract,1)
%     inter_direction =- input + extract(i,1:2);%两点之间向量  计算位置-动态交互物体
%     if norm(inter_direction)==0
%         disp(input)
%         disp(extract(i,1:2))
%         disp('上面是NaN')
%     end
%     if extract(i,11)==1%质量不一样，自行车20kg
%         M_b = 150;
%     elseif extract(i,11)==2
%         M_b = 200;%电动车50kg
%     elseif extract(i,11)==3
%         M_b = 1000;%汽车2000kg
%     end
% %     co =( ((extract(i,3:4)/norm(extract(i,3:4)))-(inter_direction/norm(inter_direction))));%交互对象速度与二者方位之间角度向量
%     co = dot(extract(i,3:4),inter_direction)/((norm(extract(i,3:4))*norm(inter_direction)));
% %     disp(co)
%     R_inter_i = ((G*R_b*M_b)/(norm(inter_direction)^k1))*((inter_direction)/(norm(inter_direction)))*(exp(k3*extract(i,7)/3.6*(co(1,1))));%速度带进去用的是m/s   
% % disp('kaile')
% % disp(((G*R_b*M_b)/(norm(inter_direction)^k1)))
% %         disp(((inter_direction)/(norm(inter_direction))))
% % disp((exp(k3*extract(i,7)/3.6*(co(1,1)/norm(co)))))
%     R_inter = R_inter+norm(R_inter_i);
% %     disp(R_inter_i)
% %     if norm(inter_direction)<=0.5
% %     disp(R_inter_i)
% %     R_inter = R_inter+norm(R_inter_i);
% end
% if norm(R_inter)>=20
%    R_inter = 20;%((inter_direction)/(norm(inter_direction)))*10;%原来是inf  为了做图变成10，之前是100
% end
% % norm(R_inter)
% % norm(inter_direction)
% 
% Risk = norm(R_end)+norm(R_inter)+norm(R_int);%+norm(R_int_right) +norm(R_end_right);%风险是标量和，要叠加的；%Risk = norm(R_end)+norm(R_inter)+norm(R_int)
% 
% % Risk = norm(R_inter);
% % disp(Risk)
% % if isnan(Risk)
% %    disp(input)
% % end
% % disp(R_inter)
end
