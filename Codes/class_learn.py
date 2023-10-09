from math import floor
import numpy as np
import pandas as pd
from matplotlib import backend_tools, pyplot as plt

file = open("class.txt", "r")
classes = file.read()
classes = classes.split(",")
file.close()

data_file_dir = "./output/data.txt"
sc_input_file_dir = "./output/sc_input.txt"

file = open("./configs/number_of_features.txt")
number_of_features  = int(file.read())
file.close()

print (number_of_features)
def train_on_class(label, batch_size, submit_number, zokrates_input_numbers, values):
        train_data_split = values[submit_number*batch_size : (submit_number+1)*batch_size, :]
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
        if (batch_size != zokrates_input_numbers):
            means_duplicated = np.tile(means, (batch_size - len(zokrates_input_numbers),1))
            data_output = np.concatenate((train_data_split, means_duplicated), axis = 0)
        else : 
            data_output = train_data_split

        output = data_output.astype(int)
        output_mean = means.astype(int)
        output_var = vars.astype(int)
        return {
            "means": output_mean,
            "vars": output_var, 
            "data": output, 
            "accuracy": accuracy
        }


def test(label) :
    data = pd.read_csv(f"./DataSets/CategorizedData/{label}.csv", delimiter=",")
    data = data.to_numpy()
    np.random.shuffle(data)
    values = data
    batch_size = 100
    lables = values[:, len(values.T)-1]
    values = values[:, 0:len(values.T) - 1]
    output =  train_on_class(label, batch_size = batch_size, submit_number= 0 , zokrates_input_numbers = batch_size,  values= values)
    



    with open(data_file_dir, 'w') as file:
        for row in output["data"].T:
            print(*row, end = ' ', file = file)
        print(*output["means"], end = ' ', file = file)
        print(*output["vars"], end = ' ', file = file)
        print(batch_size, end = ' ', file = file)
        print(output["accuracy"], end = ' ', file = file)
    file.close()

    # with open(sc_input_file_dir, 'w') as file:
    #     print("\"accuracy\": " + output["accuracy"], end = ' ', file = file)
    # file.close()

    with open('class.txt', 'w') as file:
        print(label, file = file )
    file.close()

label = "Jogging"
test(label = label)
