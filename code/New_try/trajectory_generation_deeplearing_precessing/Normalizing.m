function [output,mmin,mmax] = Normalizing(input)
%特征归一化
output=zeros(size(input,1),size(input,2));
mmin=zeros(1,size(input,2));
mmax=zeros(1,size(input,2));
for i=1:size(input,2)
    mmin(i)=min(input(:,i)); %输出每列最小值
    mmax(i)=max(input(:,i)); %输出每列最大值，留作以后反归一化
    for j=1:size(input,1)
        output(j,i)=(input(j,i)-mmin(i))/(mmax(i)-mmin(i)); %对每列（指标）进行归一化
    end
end
for i=1:size(output,1)
    for j=1:size(output,2)
        if isnan(output(i,j))%查找如果等于nan的话，就写成0；
           output(i,j)=0;
        end
    end
end
end

