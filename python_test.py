import numpy as np
import pandas as pd
from scipy.stats import norm
from matplotlib import pyplot as plt

path = './DataSets/Abalone'
values = np.asarray(pd.read_csv('abalone.data'))


total_value = len(values[:,1])
train = 0.8 * total_value 
test = 0.2 * total_value 
print('total number of sampels',total_value)

train_data = values[0:int(train) , 1:7]
train_label = values[0:int(train), 8]
test_data = values[int(train): total_value, 1:7]
test_label = values[int(train): total_value, 8]
label_values = np.unique(train_label) 


train_data_split = [[]]
means = [[]]
vars = [[]]
for i in range(len(label_values)):
    # print(train_data[np.where(train_label == label_values[i])[0]])
    train_data_split.append(train_data[np.where(train_label == label_values[i])[0]])
    print("length of class", label_values[i], "is", len(train_data_split[i]))
    means.append(np.mean(train_data_split[i], axis = 0))
    vars.append(np.var(train_data_split[i], axis = 0))


print("mean values \n", means, '\n', "variances \n", vars)
inst  = [] 
for i in range(len(means)) : 
    inst.append(norm(loc = means[i],scale = vars[i]))

print(inst[0].pdf(10))