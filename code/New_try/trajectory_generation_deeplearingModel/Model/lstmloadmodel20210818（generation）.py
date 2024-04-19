from keras.optimizers import SGD, Adadelta, RMSprop, Adam   #SGD=随机梯度下降；Adadelta=优化方法，这些都是优化算法；
from keras.models import Sequential
from keras.layers import Masking, Embedding   #keras的一层，Embedding层只能作为第一层
from keras.layers import LSTM
from keras.layers.core import Dense, Activation
from keras import backend as K
import numpy as np
import csv
import os
import math
from keras.models import load_model  #加载模型

os.environ['TF_CPP_MIN_LOG_LEVEL']='3'  #设置环境变量，设置结果显示的级别，解释在word里
n_feature = 16  #起点的特征数，同时也是中间点的特征数
n_input = 2 #输入轨迹点的个数
n_feature_all = 16*2   #x的全部输入矩阵
n_feature_y = 16

model = load_model('trajectory_generation（1124_1）.h5')   #读取模型“cnnlstm（1223）.h5”
model.summary()  ##打印出模型概况，它实际调用的是keras.utils.print_summary
n = 1  #计算计数
dir = r"D:\File\Received File\交科赛大三\非机动车行为建模代码（TOPS）\非机动车行为建模代码（TOPS）\New_try\trajectory_generation_deeplearingModel\data_test"  #r表示不转义，即字符串里的\就是\，而不转义为制表符   dir表示这个路径
filenames = os.listdir(dir)#所有文件的文件面
#filenames.sort(key=lambda x:int(x[8:-3]))#按照数字顺序排序，他读取没有顺序的
for filename in filenames:  #路径下的文件有215+1个吗？
    x_input = np.loadtxt(open(r"D:\File\Received File\交科赛大三\非机动车行为建模代码（TOPS）\非机动车行为建模代码（TOPS）\New_try\trajectory_generation_deeplearingModel\data_test\{0}".format(filename), "rb"), #
                         delimiter=",", skiprows=0)  #大括号是字典字符，delimiter表示分割符  skiprows表示跳过头行  format格式化字符串的函数
    test_x = x_input.reshape(1, n_feature_all)  #后面的模型需要（1,28）的形状，(行，列)
    #test_x = np.column_stack((test_x, np.zeros((1, (n_input * n_feature - n_feature_all)))))  # 用0补充完整  原来的完整轨迹
    y_pred = []  #定义list值
    PRED_SIZE = 17 #  生成只能生吃3/5/9/17/33步，每次加密   试试看各个步长的准确率  先试试17个步长的
    PRED_BATCH = 1   #批大小。在深度学习中，一般采用SGD训练，即每次训练在训练集中取batchsize个样本训练
    y_batch_r = np.zeros((PRED_SIZE, n_feature))  #每个样本的计算结果，返回来一个给定形状和类型的用0填充的数组  (PRED_SIZE, n_feature)表示其形状
    y_pred_final = np.zeros(((PRED_SIZE+n_input), n_feature))  # 最终的输出值

    #对每个文件中的轨迹进行生成，生成起终点之间的多个点
    #首先读取需要循环几次  2+（1+2+4+8）=17
    based_x = test_x.reshape(-1, n_feature)#变换成每个点占一行的  并将初始点赋予based_x
    for level in range(0, 4):  #17个步长就是4次，33个步长就是5次    2+（1+2+4+8+16）
        output_j = based_x[0, :]  # 赋予初始起点，取前n_feature，起点的特征
        for j in range(0, based_x.shape[0]-1, PRED_BATCH):  #range(start, stop, step)  ##对一个轨迹预测  PRED_SIZE=25 PRED_BATCH=1
            input_point = based_x[j:j+2, :].reshape(1, (n_input*n_feature)) #取前面n_feature_all个特征值进行输出，将输入点的计算位置换算成一行，以便放入预测中
            input_point1 = input_point#input_point[:, 1:n_feature_all+1]   #  所有点特征一样时可以删掉， 只取起点所有特征和终点的位置特征  input_point1 = input_point[:, 1:n_feature_all+1]
            y_batch = model.predict(input_point1)  #模型输入的维度是（1,44）输出=（1,22） [:,j]表示选定其中某列进行预测输入
            y_batch = y_batch[0, :]  #把二维数组变成1维
            ## 将预测到的相对值整合为绝对坐标
            #print(input_point[0, 0])
            y_batch[0] = input_point[0, 0] + y_batch[0] * (input_point[0, n_feature]-input_point[0, 0])  #将x和y由与起终点的比例信息转化为真实信息（归一化后）
            y_batch[1] = input_point[0, 1] + y_batch[1] * (input_point[0, n_feature + 1] - input_point[0,1])
            ## 结束
            end_point = based_x[j+1,:] #每个操作位置的终点，也就是下一个的起点
            output_j = np.row_stack((output_j, [y_batch, end_point]))  #将后续的一个生成点和终点追加至后面
        based_x = output_j

       # test_x
       # based_x = test_x.reshape(-1, n_feature)  # 变换成每个点是一行的
       # based_x =
        #alone = y_batch.shape[1] #读取列数 ，也就是每次需要替换的数据数量 ,就是一个轨迹点
       # y_batch_r[j,:] = y_batch #存放轨迹，形状为[20,39]
       # y_pred = test_x   #将输入数据赋予y_pred,开始更新输入
        #y_pred = np.reshape(y_pred,[n_input, n_feature])  #变形
       # y_pred = np.row_stack((y_pred, y_batch))  # y_pred 是预留的空数据  y_batch加入到里面  ，记住后面是两个括号(())
       # y_pred = np.delete(y_pred, 1, axis = 0)  #删掉一行, (x,行（列）数， 行=0or列=1？)
       # y_pred = np.reshape(y_pred, [1, (n_input*n_feature)])  #恢复形状到原来的输入
       # test_x = y_pred  #将更新后的数据赋予输入的j+1行，进入下一次循环

    csvfile = open(r'D:\File\Received File\交科赛大三\非机动车行为建模代码（TOPS）\非机动车行为建模代码（TOPS）\New_try\trajectory_generation_deeplearingModel\result_test\{0}'.format(filename), 'w', newline="") #打开文件，写入   newline 是分割形式，防止每行最后有空格
    writer = csv.writer(csvfile)
    writer.writerows(output_j)
    #print(np.shape(output_j))
    csvfile.close()
    n=n+1
    print(n)
    print('%.2f' %(n/285*100),'%') #进度条，百分比，保留两位小数
print('The trajectory generation is completed !')
