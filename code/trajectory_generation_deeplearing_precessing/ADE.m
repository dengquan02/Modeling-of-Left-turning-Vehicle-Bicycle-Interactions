function [output] = ADE(inputArg1,inputArg2)
MDE = [];
maxtr = inputArg1-inputArg2;
for i =1:size(maxtr,1)
   MDE = [MDE;norm(maxtr(i,:))];
end
output = mean(MDE);
end

