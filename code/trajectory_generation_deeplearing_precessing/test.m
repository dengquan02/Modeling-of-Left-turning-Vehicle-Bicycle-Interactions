[E1]=xlsread('M:\New_try\三分类处理完成数据（T=0.12s）.xlsx',1);%左转非机动车
[E1V]=xlsread('M:\New_try\三分类处理完成数据（T=0.12s）.xlsx',2);%
[W1V]=xlsread('M:\New_try\三分类处理完成数据（T=0.12s）.xlsx',3);%
id_amount=max(E1(:,12))
endPoints=zeros(id_amount,2);
count=1;
len1=length(E1(:,12))
for i=1:len1-1
    if(E1(i+1,13)<E1(i,13))
        endPoints(count,1)=E1(i,2)
        endPoints(count,2)=E1(i,3)
        count=count+1
    end
end
endPoints(id_amount,1)=E1(len1,2);
endPoints(id_amount,2)=E1(len1,3);
endpoint_x=median(endPoints(:,1))
endpoint_y=median(endPoints(:,2))


