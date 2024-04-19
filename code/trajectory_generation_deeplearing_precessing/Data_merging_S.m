function [output] = Data_merging_S(S1,S2)
S = S1;
S2(:,12) = S2(:,12)+S(size(S,1),12);%第12列是轨迹ID
S = [S;S2];
S(:,14) = [];
output = S;
output(:,12) = S(:,13);%ID_in，换一下位置
output(:,13) = S(:,12);%ID
end

