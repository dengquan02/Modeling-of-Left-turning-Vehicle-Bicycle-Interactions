function [EL_co] = elliptical_index(E_trajectory,e,angle)
%计算各个交互对象之间的椭圆换算距离，看是否是指数分布
e=0.8;
ang = 5;
angle = 1;%归一的角度
input = E_trajectory;
%去掉刚启动的数据
% for i = 1:30
%     input((input(:,2)==i),:)=[];
% end

input(:,1:3) = [];%去掉不需要的东西
index = 1;%一行一行的计算
NU = 100;%区间个数
d = [];
A = [];
R = [];
EU_co = [];
% figure(1)
while index <=size(input,1)
    extract = reshape(input(index,:)',11,[])';%换算成11列的
    extract(all(extract==0,2),:)=[];
    if size(extract,1)>1%如果大于1，说明该主题有交互对象
       extract_except = extract;%另外拿出来一个当做交互客体集
       extract_except(:,1) = extract_except(:,1)-extract(1,1);%x都按照主体(第一行)进行归一
       extract_except(:,2) = extract_except(:,2)-extract(1,2);%y都按照主体进行归一
       extract_except((extract_except(:,1)==0&extract_except(:,2)==0),:) = [];%把之前的主体删掉，因为他是原点
       EU_co = [EU_co;extract_except(:,1:2)];%这是欧式坐标归一后的
       for j = 1:size(extract_except,1)%对于主体d的交互客体来说
           [a,r] = cart2pol(extract_except(j,1),extract_except(j,2));%a和r分别表示极坐标的角度和极径 
           R = [R;r];%存放极径
           A = [A;a];%存放角度
%                polarscatter(a,r,'.','r');
%                hold on 
           d = [d;((r*(1-e*cos(a)))/(1-e*cos(angle)))];%求换算后的距离（角度为angle），并放至矩阵内；
%                d = [d;(r*(1-(e*cos(a))))/(1-e^2)];%求换算后的距离（角度为0），并放至矩阵内；
        end
    end
index = index +1;
disp(['已完成',num2str(index/size(input,1)*100),'%'])
end

%做一条线上的频数分布图
% figure(2)
EL_co = [A R];%极坐标，A为角度，R为极径
EL_co = unique(EL_co,'rows');%去除相同的行数据，因为有的被重复计算
EL_part = EL_co((EL_co(:,1)<deg2rad(5+ang)),:);%找到角度小于5+ang
EL_part = EL_part((EL_part(:,1)>deg2rad(ang)),:);%找到角度大于ang
% polarscatter(EL_part(:,1),EL_part(:,2),'.','r');%对找到的点做图
one_dis = (max(EL_part(:,2)))/NU;%求一个区间的距离
sameNU = hist(EL_part(:,2),NU);%分到一些个箱子里
sameNU = [sameNU;zeros(1,size(sameNU,2))];
for i = 1:size(sameNU,2)
    sameNU(1,i) = sameNU(1,i)/(one_dis*i);%每个区间的个数要除以半径，，来抵消空间的差异
    sameNU(2,i) = (one_dis*i);
end
histogram(sameNU,NU);
% hist(EL_part(:,2));


%做整个的图
polarscatter(A,R,'.','r');%对所有点做图
scatter(EU_co(:,1),EU_co(:,2),'.','r');
% hist(R,100);
% polarscatter(a,r,'.');

%做个椭圆
ecc = axes2ecc(1.8,0.8);%（长轴 短轴）
[elat,elon] = ellipse1(0,0,[1.8 ecc],0);
hold on 
plot(elat,elon,'b')

% dis = d;
% dis(find(dis>=1))=[];
% hist(dis);
% R(find(R>=1.5))=[];
% hist(R);
% save;
% shutdown;%计算完之后自动关机
end

