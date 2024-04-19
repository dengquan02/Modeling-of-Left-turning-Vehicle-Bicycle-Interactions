function[]= testdividing(input,path)
%将测试集分块输出 
dir = strcat(path,'\x_test_');
for i=1:size(input,1)
    dlmwrite([dir,num2str(i),'.txt'],input(i,:));
    %save(['x_test_',num2str(i),'.txt'],input(i,:));%[]表示语句连续；num2str()表示数值变成字符
end
end


