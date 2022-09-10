from math import floor
import numpy as np
import pandas as pd
from matplotlib import backend_tools, pyplot as plt
from random import shuffle 

client_id  = 1
data = pd.read_csv(f"./data/client{client_id}.csv", delimiter=",")
headers = data.columns
data = data.to_numpy()
np.random.shuffle(data)
values = data
lables = values[:, len(values.T)-1]
values = values[:, 0:len(values.T) - 1]
classes = np.unique(lables)
total_value = len(values)
train = 0.8 * total_value 
test = 0.2 * total_value 
number_of_agents = 5


batch_size = 100
data_size_threshold = batch_size * 0.2
train_data = values[0:int(batch_size), : ]
train_label = lables[0:int(batch_size)]
label_values = np.unique(train_label) 

train_data_split = []
means = []
vars = []
samplePerAtt = []

# #  Do the search for just one class 

for class_value in label_values :
    indices = np.where(train_label == class_value)[0]
    if (len(indices) >= data_size_threshold):
        train_data_split = train_data[indices, :]
        vars = np.var(train_data_split, axis = 0)
        min = np.min(vars)
        scale = np.log10(min)
        if (scale > 0) :
            accuracy = 100
        else :
            accuracy = 10**(-floor(scale)) 
        train_data_split = train_data_split.astype(int) * accuracy
        means = np.mean(train_data_split, axis = 0)
        vars = np.var(train_data_split, axis = 0)
        print(f'length of class', class_value,'is', len(indices) )
        means_duplicated = np.tile(means, (batch_size - len(indices),1))
        data_output = np.concatenate((train_data_split, means_duplicated), axis = 0)
        output = data_output 
        output = output.astype(int)
        output_mean = means 
        output_mean = output_mean.astype(int)
        output_var = vars 
        output_var = output_var.astype(int)

        break

    else : 
        print('not enough data avaialble in this class', class_value)


with open('data.txt', 'w') as file:
    for row in output.T:
        print(*row, end = ' ', file = file)
    print(*output_mean, end = ' ', file = file)
    print(*output_var, end = ' ', file = file)
    print(len(indices), end = ' ', file = file)
    print(accuracy, end = ' ', file = file)
file.close()

with open('class.txt', 'w') as file:
     print(class_value, file= file )
file.close()