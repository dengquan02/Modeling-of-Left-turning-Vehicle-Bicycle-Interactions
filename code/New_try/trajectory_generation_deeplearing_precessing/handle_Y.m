function [y_train,x_train] = handle_Y(y_train,x_train) 
%%  本函数的目的是将y的绝对坐标换成相对坐标
leng_point = size(y_train,2);
index_del = [];
for i = 1:size(y_train,1)
    x_potint = (y_train(i,1)-x_train(i,1))/(x_train(i,leng_point+1)-x_train(i,1));%求得x比例
    y_potint = (y_train(i,2)-x_train(i,2))/(x_train(i,leng_point+2)-x_train(i,2));%求得y比例
    if x_potint == inf||isnan(x_potint)
        x_potint = 0.5;
    end
    if y_potint == inf||isnan(y_potint)
        y_potint = 0.5;
    end
    if abs(x_potint)>5||abs(y_potint)>5
        index_del = [index_del i];
    end
    y_train(i,1) = x_potint ;
    y_train(i,2) = y_potint;
end
y_train(index_del,:)=[];
x_train(index_del,:)=[];
end