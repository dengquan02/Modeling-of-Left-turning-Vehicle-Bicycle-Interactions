function [output] = Data_merging_EV(E1V,E2V)
EV = E1V;
E2V(:,12) = E2V(:,12)+EV(size(EV,1),12);%第12列是轨迹ID
EV = [EV;E2V];
EV(:,14) = [];
output = EV;
output(:,12) = EV(:,13);%ID_in，换一下位置
output(:,13) = EV(:,12);%ID
end

