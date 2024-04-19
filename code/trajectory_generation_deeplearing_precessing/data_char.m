function [output_E] = data_char(E_straight,NVinterract,Vinterract,Num_No,Num_V,index_zeros)
%E_straight是预测主体，后面的五个矩阵都是交互客体，从里面选出交互的来；
disp('start data_handle');
disp('start E非');
%整理E_straight
E_straight = [E_straight(:,14) E_straight(:,12) E_straight ];
E_straight(:,14) = [];
E_straight(:,15) = [];
%整理NVinterract
NVinterract = [NVinterract(:,13) NVinterract(:,12) NVinterract ];
NVinterract(:,14:15) = [];
%整理Vinterract
Vinterract = [Vinterract(:,13) Vinterract(:,12) Vinterract ];
Vinterract(:,14:15) = [];

%%%for NV
Nu_NVinterract = zeros(size(E_straight,1),1);%number of interacting NV
all_NVinterract = zeros(size(E_straight,1),Num_No*11);%Selected of interactive NV
chosed_NVinterract = zeros(size(E_straight,1),Num_No*11);%All of interactive NV

for i=1:size(E_straight,1)%给每个直行轨迹点都弄好特征
    nu=0;
    except_me = NVinterract((NVinterract(:,1)~=i),:);%find all of orthers except me
    all_NVinterract = except_me((except_me(:,3)==E_straight(i,3)),:);%find interactive obejct at the same time
    
    for i1=1:size(NVinterract,1)%找一个轨迹点的所有交互非机动车，并存放在E2中
        if NVinterract(i1,1)==E_straight(i,1)%判断是否存在相同时间的轨迹点（包括原轨迹点）
           nu=nu+1;%交互对象计数
           all_NVinterract(i,((nu*11)-10):((nu*11)-1))=NVinterract(i1,2:11);%赋予非机动车的第2位到第11位
           all_NVinterract(i,(nu*11))=NVinterract(i1,14);%赋予非机动车的类型(第十一位)
        end
    end
    Nu_NVinterract(i,1)=nu-1;%number of interract NV(-1是因为其中有一个是自己)   
    d=zeros(2,max(nu,Num_No));%存放交互两者之间的距离，选取距离最短的Num个（不为0）
    for i2=1:max(nu,Num_No)
        d(1,i2)=i2;%第一行放他们的编号
        if  all_NVinterract(i,(i2*3)-2)~=0%若交互对象不为0的话
            d(2,i2)=((NVinterract(i1,2)- all_NVinterract(i,(i2*3)-2))^2+(NVinterract(i1,3)- all_NVinterract(i,(i2*3)-1))^2)^0.5;%第二行放他们的距离
       end
    end
    d(:,(find(d(2,:)==0)))=[];%删掉距离为0的列
    d=(sortrows(d',2))';%对交互距离进行升序排列，找到前Num个序列
    for i3=1:min(Num_No,size(d,2))
        chosed_NVinterract(i,(i3*11-10):(i3*11-1))=all_NVinterract(i,((d(1,i3)*11)-10):(d(1,i3)*11)-1);
        chosed_NVinterract(i,i3*11)=all_NVinterract(i,(d(1,i3)*11));
    end
    disp(['E非已完成',num2str(i/size(E_straight,1)*100),'%']);
end

%%%%%%%for V
Nu_Vinterract=zeros(size(E_straight,1),1);%每个轨迹点（同一时刻）有几个交互机动车
all_Vinterract=zeros(size(E_straight,1),Num_V*11);%用来存放每个非机动车的同一时刻全部机动车（存在的）
chosed_Vinterract=zeros(size(E_straight,1),Num_V*11);%用来存放每个非机动车的交互的三个机动车
for i=1:size(E_straight,1)%给每个轨迹点都弄好特征
    nu_V=0;
    for i1=1:size(Vinterract,1)%找一个轨迹点的特征
        if Vinterract(i1,1)==E_straight(i,1)%判断是否存在相同时间的轨迹点
           nu_V=nu_V+1;%交互对象计数
           all_Vinterract(i,((nu_V*11)-10):((nu_V*11)-1))=Vinterract(i1,2:11);%赋予机动车的x值(第一位到第十位)
           all_Vinterract(i,(nu_V*11))=Vinterract(i1,14);%赋予机动车的类型(第十一位)
        end
    end
    Nu_Vinterract(i,1)=nu_V-1;   
    d2=zeros(2,max(nu_V,Num_V));%存放交互两者之间的距离，选取距离最短的Num个（不为0）
    for i2=1:max(nu_V,Num_V)
        d2(1,i2)=i2;%第一行放他们的编号
        if  all_Vinterract(i,(i2*3)-2)~=0%若交互对象不为0的话
            d2(2,i2)=((Vinterract(i1,2)- all_Vinterract(i,(i2*3)-2))^2+(Vinterract(i1,3)- all_Vinterract(i,(i2*3)-1))^2)^0.5;%第二行放他们的距离
       end
    end
    d2(:,(find(d2(2,:)==0)))=[];%删掉距离为0的列
    d2=(sortrows(d2',2))';%对交互距离进行升序排列，找到前Num个序列
    for i3=1:min(Num_V,size(d2,2))
        chosed_Vinterract(i,(i3*11-10):(i3*11-1))=all_Vinterract(i,((d2(1,i3)*11)-10):(d2(1,i3)*11)-1);
        chosed_Vinterract(i,i3*11)=all_Vinterract(i,(d2(1,i3)*11));
    end
    disp(['E机已完成',num2str(i/size(E_straight,1)*100),'%']);
end

%%%%%%%%%%输出E的数据%%%%%%%%%%%
E=E_straight;
E(:,1)=E_straight(:,14);%第1列放轨迹标号ID
E(:,2)=E_straight(:,12);%第2列放轨迹内部轨迹标号ID_in
E(:,3:5)=E_straight(:,1:3);%时间和预测主体的时间和坐标
E(:,6:13)=E_straight(:,4:11);%预测主体的其他信息
E(:,14)=E_straight(:,13);%预测主体的类型
E(:,15:(14+Num_No*11))=chosed_NVinterract(:,1:(Num_No*11));%交互非机动车
E(:,(15+Num_No*11):((14+Num_No*11)+Num_V*11))=chosed_Vinterract(:,1:Num_V*11);%交互机动车



%输出值
output_E =E;

% %去掉交互对象为0的点
% output_E = [];
% ID_E = 1;
% for i = 1:E(size(E,1),1)
%     current_output_E = E(find(E(:,1)==i),:);
%     current_output_E(:,1) = ID_E;
%     zero_index_N = sum(sum(current_output_E==0));
%     if zero_index_N<=index_zeros
%         output_E = [output_E;current_output_E];
%         ID_E = ID_E+1;
%     end
% end
% output_N = [];
% ID_N = 1;
% for i = 1:N(size(N,1),1)
%     current_output_N = N(find(N(:,1)==i),:);
%     current_output_N(:,1) = ID_N;
%     zero_index_N = sum(sum(current_output_N==0));
%     if zero_index_N<=index_zeros
%         output_N = [output_N;current_output_N];
%         ID_N = ID_N+1;
%     end
% end
end

