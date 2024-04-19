function [NVinterract,Vinterract] = DATA_merge (E1,N1,E1V,N1V,S)
%DATA merge
NVinterract = E1;
if ~isempty(N1)
    N1(:,13) = N1(:,13)+NVinterract(size(NVinterract,1),13);%第13列是轨迹ID
    NVinterract  = [NVinterract;N1];
end
if ~isempty(S)
    S(:,13) = S(:,13)+NVinterract(size(NVinterract,1),13);%第13列是轨迹ID
    NVinterract  = [NVinterract;S];
end

Vinterract = E1V;
N1V(:,13) = N1V(:,13)+Vinterract(size(Vinterract,1),13);%第13列是轨迹ID
Vinterract  = [Vinterract;N1V];
end