%读取数据
[N1]=xlsread('E:\Prediction_of_BIM\Data_Preparing\data.xlsx',1);
[N2]=xlsread('E:\Prediction_of_BIM\Data_Preparing\data.xlsx',2);
[S1]=xlsread('E:\Prediction_of_BIM\Data_Preparing\data.xlsx',3);
[S2]=xlsread('E:\Prediction_of_BIM\Data_Preparing\data.xlsx',4);
[E1]=xlsread('E:\Prediction_of_BIM\Data_Preparing\data.xlsx',5);
[E2]=xlsread('E:\Prediction_of_BIM\Data_Preparing\data.xlsx',6);
[E1_add]=xlsread('E:\Prediction_of_BIM\Data_Preparing\data.xlsx',7);
[E2_add]=xlsread('E:\Prediction_of_BIM\Data_Preparing\data.xlsx',8);
[N1V]=xlsread('E:\Prediction_of_BIM\Data_Preparing\data.xlsx',9);
[N2V]=xlsread('E:\Prediction_of_BIM\Data_Preparing\data.xlsx',10);
[E1V]=xlsread('E:\Prediction_of_BIM\Data_Preparing\data.xlsx',11);
[E2V]=xlsread('E:\Prediction_of_BIM\Data_Preparing\data.xlsx',12);

%把各个方向的轨迹都弄到一起
[E] = Data_merging_E(E1,E1_add,E2,E2_add);
[EV] = Data_merging_EV(E1V,E2V);
[N] = Data_merging_N(N1,N2);
[NV] = Data_merging_NV(N1V,N2V);
[S] = Data_merging_S(S1,S2);

figure(1)%做图
scatter(E(:,2),E(:,3),'.','b')
hold on
scatter(N(:,2),N(:,3),'.','r')
hold on
scatter(S(:,2),S(:,3),'.','y')
hold on
scatter(EV(:,2),EV(:,3),'.','k')
hold on
scatter(NV(:,2),NV(:,3),'.','g')

%%%保存为excel%%%
output_cell_N = num2cell(N); 
title = {'GlobalTime', 'X[m]', 'Y[m]','Vx[m/s]','Vy[m/s]','Ax[m/s2]','Ay[m/s2]','Speed[km/h]','Acceleration[m/s2]','Space[m]','Curvature[1/m]','ID_in','ID','type'}; 
result_N = [title; output_cell_N];
s_N = xlswrite('data_SH.xlsx',result_N,1);  

output_cell_E = num2cell(E); 
result_E = [title; output_cell_E];
s_E = xlswrite('data_SH.xlsx',result_E,2);  

output_cell_NV = num2cell(NV); 
result_NV = [title; output_cell_NV];
s_NV = xlswrite('data_SH.xlsx',result_NV,3);  

output_cell_EV = num2cell(EV); 
result_EV = [title; output_cell_EV];
s_EV = xlswrite('data_SH.xlsx',result_EV,4);  

output_cell_S = num2cell(S); 
result_S = [title; output_cell_S];
s_S = xlswrite('data_SH.xlsx',result_S,5);  


        