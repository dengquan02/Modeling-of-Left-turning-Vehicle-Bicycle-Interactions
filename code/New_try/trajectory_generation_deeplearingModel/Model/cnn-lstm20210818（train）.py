print('start!')

from keras.optimizers import SGD, Adadelta, RMSprop,Nadam,Adam   #SGD=随机梯度下降；Adadelta=优化方法，这些都是优化算法；
from keras.models import Sequential   #从keras.models中输入顺序模型
from keras.layers import LSTM, Dropout, Conv2D, MaxPooling2D, AveragePooling2D, Activation,Permute,ConvLSTM2D,Reshape  #Dropout是在传播过程中抛弃一些东西；Permute和reshape都是重新排列一个数组
from keras.layers.core import Dense, Flatten,regularizers  #flatten返回一个一维的数组 ； regularizers=正则化
from keras.layers.convolutional import Conv2D  #卷积层
from keras.layers.wrappers import TimeDistributed  #wrappers表示包装器，TimeDistributed将一个层应用于每个时间片
from keras.callbacks import EarlyStopping  #callback=回调函数  earlystoping=提前停止训练（可以达到当训练集上的loss不在减小（即减小的程度小于某个阈值）的时候停止继续训练。）
from keras.layers.advanced_activations import PReLU #=激活函数  当神经元未激活时，它仍允许赋予一个很小的梯度
import numpy as np  #基础包，可对N维数组进行操作
import pandas as pd   ###强大的分析结构化数据的工具集
from keras import backend as K
import csv
import os  #获取当前目录，python 的工作目
os.environ['TF_CPP_MIN_LOG_LEVEL'] = '3'  #设置环境变量，设置结果显示的级别，解释在word里
n_feature = 16  #输入特征数！！
n_input = 2 #输入轨迹点的个数   n_input*n_feature！！
n_feature_all = 16*2  #起终点全部的特征数！！
##########下面是读取一个数据：input  ##########################
###数据量太大，不能一下子读取完，所以分块读取，然后在进行粘和起来
rd = pd.read_csv(r"D:\File\Received File\交科赛大三\非机动车行为建模代码（TOPS）\非机动车行为建模代码（TOPS）\New_try\trajectory_generation_deeplearing_precessing\x_train.csv", iterator=True)   #read_csv()函数的iterator参数等于True时，表示返回一个TextParser以便逐块读取文件,,齐骁数据是一行是一个轨迹数据,叠加到一起了
loop=True #将loop令为true，true也是基本的一个数字类型，布尔数字；
dflst = []  #[]表示list列表数据类型  ，  dflst用来存储分块读取的csv文件数据
i=0
while loop:   #若满足loop=true则进入循环，否则停止循环，前面几次loop为true，进入循环，读取数据，读取数据出现错误以后loop=false，跳出循环。
    try:   #except 是一个发生错误时的应急预案
        i+=1  #加法赋值运算，相当于i=i+1
        #print(i)
        df0 = rd.get_chunk(1000)  #rd是csv数据变量 get_chunk表示分块读取，1000表示字符数，1000是否是一行的字符数呢？读取到最后剩下的不够1000时，它会全部读取，若没有东西了就会返回一个null
        dflst.append(df0)    #append表示在列表末尾添加新的对象。每次读取完1000条数据df0，添加至dflst后面
    except StopIteration:  #停止迭代，loop令为false
        loop =False
        #print("datareading done")
df = pd.concat(dflst)  #是将目标csv格式的文件，转换成pandas使用的文件格式。  pd.concat是数据的拼接 ，估计是将上面的一个一个的块拼起来
input = df.values  #读取字典中的数据值，返回值是一个list ，将整个读取的值赋予input   注意：字典中的输出顺序是python内部顺序
###以上是读取训练数据#####
##########下面是读取“值”数据，与上面的类似，输出一个：input_val###########
rd_val=pd.read_csv(r"D:\File\Received File\交科赛大三\非机动车行为建模代码（TOPS）\非机动车行为建模代码（TOPS）\New_try\trajectory_generation_deeplearing_precessing\x_ver.csv", iterator=True)    #读取验证数据
loop_val=True
dflst_val=[]
i=0
while loop_val:
    try:
        i+=1
        #print(i)
        df0_val = rd_val.get_chunk(1000)
        dflst_val.append(df0_val)
    except StopIteration:
        loop_val =False
        #print("datareading done")
df_val=pd.concat(dflst_val)
input_val=df_val.values  ##input_val是输入的验证集

print("DataReading done")
###########以下是读取数据部分，输出一个：output   output_val#########################################
###########val_data=input_val+output_val  输出一个val_data  和   output
output = np.loadtxt(open(r"D:\File\Received File\交科赛大三\非机动车行为建模代码（TOPS）\非机动车行为建模代码（TOPS）\New_try\trajectory_generation_deeplearing_precessing\y_train.csv", "rb"),delimiter=",", skiprows=0)   #open用于打开一个文件，创建一个file对象，相关的方法才可以调用它进行读写 ，rb表示以二进制格式打开一个文件用于只读，一般用于图片等非文本格式。
output=np.delete(output,0,0)    #表示删除output矩阵元素0的整行，第一个0表示删除第几个行（列),第二个行列：行=0；列=1；
output_val = np.loadtxt(open(r"D:\File\Received File\交科赛大三\非机动车行为建模代码（TOPS）\非机动车行为建模代码（TOPS）\New_try\trajectory_generation_deeplearing_precessing\y_ver.csv", "rb"),delimiter=",", skiprows=0)
output_val=np.delete(output_val,0,0)  ###输出的验证集
val_data=(input_val,output_val)   #合并到一起，（）表示tuple元组数据类型，元组是一种不可变序列  前面是x，后面是y
###########以上是数据读取部分，下面是构建模型##############################
#def relative_mean_squared_error(y_true, y_pred):
 #   return K.mean(K.square(y_pred - y_true), axis=-1)
  #  return relative_mean_squared_error



###########以上是定义一个loss函数##################################################
model2 = Sequential()   #构建顺序连接模型
model2.add(Reshape((1, n_feature_all, -1), input_shape=(( n_feature_all ),)))   #输入是640行，24522列，reshape（轨迹点，特征值）   python是按照行reshape，而matlab是按照列   model2.add(Reshape((n_input, n_feature, -1), input_shape=((n_input*n_feature),)))
model2.add(Conv2D(128, (1, 3), padding='valid'))   #100表示输出通道的数量，应该类似于特征数吧；（5,20）表示卷积核；padding表示卷积的方式，只能是"SAME","VALID"其中之一，这个值决定了不同的卷积方式，SAME代表卷积核可以停留图像边缘，VALID表示不能
model2.add(Activation('relu'))   #激活函数采用relu 让线性不可分的东西变得线性可分 最初的激活函数为relu,改为softmax以后预测效果变好；
#model2.add(MaxPooling2D(pool_size=(1, 2), strides=None, padding='valid', data_format=None))  #增加池化层
model2.add(TimeDistributed(Flatten()))   #批量实现张量降维   Flatten层用来将输入“压平”，即把多维的输入一维化，常用在从卷积层到全连接层的过渡
model2.add(LSTM(128, dropout_W=0.1, dropout_U=0.1, activation='relu',return_sequences=False))  #100表示输出维度  dropout是正则化，就是随意丢弃一些东西； return_sequences=False表示返回所有序列状态的输出，是一个（samples，timesteps，output_dim）3D张量 最初的激活函数是relu
model2.add(Dense(128, activation='tanh'))  #全连接层  激活函数为tanh和默认时预测结果比价好
#model2.add(Dense(64, activation='tanh'))  #全连接层  激活函数为tanh和默认时预测结果比价好
model2.add(Dropout(0.1))  #正则化
model2.add(Dense(n_feature, activation='relu'))   #全连接层,32是特征值数目  激活函数原来是tanh  relu   14  要跟输出的特征数相同
model2.compile(loss='mean_absolute_error', optimizer='Adam')   #编译
model2.summary()   #打印出模型概况
early_stopping = EarlyStopping(monitor='val_loss', patience=3)   #停止条件  monitor='val_loss'表示监视条件   patience=2表示当early stop被激活（如发现loss相比上一个epoch训练没有下降），则经过patience个epoch后停止训练。一般情况设置此值较大些，因为神经网络学习本来就不稳定，只有加大些才能获得“最优”解。
history2 = model2.fit(input, output, batch_size=20, epochs=50,  verbose=1, validation_data=val_data, callbacks=[early_stopping])  #梯度下降时batch_size表示每个batch包含的样本数， epochs表示训练达到该值停止  verbose表示显示，=1表示显示进度条 validation_data表示指定的验证集  calllist回调函数
print('history', history2) #打印history
model2.save('trajectory_generation（1124_1）.h5')  #保存模型 ，保存格式是h5
with open(r'D:\File\Received File\交科赛大三\非机动车行为建模代码（TOPS）\非机动车行为建模代码（TOPS）\New_try\trajectory_generation_deeplearingModel\Model\trajectory_generation(20210818).csv','w') as ff:  #以写入的方式打开file文件，并将文件存储到变量中
    ff.write(str(history2.history))  ##write表示将字符串str写入到文件，str()将对象转化为适合人阅读的格式
# print('save model success')
# del model2
print('done!')