[input]=xlsread('E:\Prediction_NV\Data_preprocessing\������ϴ����\ԭʼ����\������·ī��·������.xlsx',4);
%datdawash
%Ѱ�����յ����ض�����Ĺ켣
%ȥ����������
input(:,1)=[];
scatter(input(:,2),input(:,3),'.','r');%��ͼ
N=sum(isnan(input(:,1)));%����켣����
n=0;
for i=1:size(input,1)%��ͬһ���켣���Ϻ�
    s=isnan(input(i,1));
    if s==1
       n=n+1;
       input(i,12)=n;
    else
       input(i,12)=n;
    end
end
for i=1:size(input,1)%�޳������
    if 60<input(i,2)||input(i,2)<-20||50<input(i,3)||input(i,3)<10%�޳�������������
       aaa1=input(i,12);%��ȡ�켣���
       for i2=1:size(input,1)%�ҵ��켣�����յ�
          if input(i2,12)==aaa1
             input(i2,:)=nan;%���Ϻ�1��ʾ��ֱ�зǻ�����
          end
       end
    end
end

for i=1:size(input,1)%��ͬһ�켣��ÿ���켣����
    s2=isnan(input(i,1)); 
    if s2==1
       n_in=0;
    else
       n_in=n_in+1;
    end
    input(i,13)=n_in;
end
% AA=0;
% AAA=0;
% for i=1:size(input,1)%�ҵ��켣�����յ�
%     if input(i,13)==1&&-10<input(i,2)&&input(i,2)<60&&10<input(i,3)&&input(i,3)<60%�ж�����Ƿ���ָ������
%         AAA=AAA+1;
%         sp=i;
%            while input(sp+1,13)~=0%�ҵ���Ӧ���յ�
%                if (sp+1)>=size(input,1)
%                    break
%                else
%                    sp=sp+1; 
%                end
%            end
%         if -10<input(sp,2)&&input(sp,2)<60&&10<input(sp,3)&&input(sp,3)<60%�ж��յ��Ƿ���ָ������
%            AA=AA+1;
%              aaa=input(i,12);%��ȡ�켣���
%                for i1=1:size(input,1)%�ҵ��켣�����յ�
%                    if input(i1,12)==aaa
%                        input(i1,14)=1;%���Ϻ�1��ʾ��ֱ�зǻ�����
%                        input(i1,15)=AA;
%                    end
%                end
%         end
%     end
% end

% for i=1:size(input,1)%������ֱ�еĹ켣��Ū��nan
%     if input(i,14)~=1
%         input(i,:)=nan;
%     end
% end
for i=1:size(input,1)
    input(i,16)=3;%���Ϻ�3��ʾ�ǻ�����
end      
scatter(input(:,2),input(:,3),'.','r');%��ͼ
output=input(~any(isnan(input),2),:);%ɾ��nan
output(:,14)=[];
%output(:,4:11)=[];
output_cell = num2cell(output); 
% title = {'GlobalTime', 'X[m]', 'Y[m]','ID','ID_in','ID_straight','type'}; 
title = {'GlobalTime', 'X[m]', 'Y[m]','Vx[m/s]','Vy[m/s]','Ax[m/s2]','Ay[m/s2]','Speed[km/h]','Acceleration[m/s2]','Space[m]','Curvature[1/m]','ID','ID_in','ID_straight','type'}; 
result = [title; output_cell];
s = xlswrite('data.xlsx',result,12);  

        