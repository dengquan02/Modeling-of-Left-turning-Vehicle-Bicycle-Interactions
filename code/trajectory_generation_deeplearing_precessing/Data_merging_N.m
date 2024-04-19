function [output] = Data_merging_N(N1,N2)
N = N1;
N2(:,12) = N2(:,12)+N(size(N,1),12);%第12列是轨迹ID
N = [N;N2];
N(:,14) = [];
output = N;
output(:,12) = N(:,13);%ID_in，换一下位置
output(:,13) = N(:,12);%ID
end

