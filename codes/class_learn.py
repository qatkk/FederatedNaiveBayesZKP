from math import floor
import numpy as np
import pandas as pd
import json 



data_file_dir = "../output/data.txt"
sc_input_file_dir = "../output/sc_input.txt"

file = open('../configs/params.json')
params = json.load(file)
file.close
class NpEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj, np.integer):
            return int(obj)
        if isinstance(obj, np.floating):
            return float(obj)
        if isinstance(obj, np.ndarray):
            return obj.tolist()
        return json.JSONEncoder.default(self, obj)



def train_on_class(label, batch_size, submit_number, zokrates_input_numbers, values):
        train_data_split = values[submit_number*batch_size : (submit_number+1)*batch_size, :]
        accuracy = 100
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


def train(label) :
    data = pd.read_csv(f"../DataSets/CategorizedData/{label}.csv", delimiter=",")
    data = data.to_numpy()
    np.random.shuffle(data)
    print("\nLearning the model parameters for class", label)
    values = data
    batch_size = params['batch_size']
    values = values[:, 0:len(values.T) - 1]
    output =  train_on_class(label, batch_size = batch_size, submit_number= 0 , zokrates_input_numbers = batch_size,  values= values)
    print("\nLearn model parameters are:", "\nMeans: ", *output["means"], '\nVariences: ', *output["vars"], "\nwith the accuracy parameter", output["accuracy"])
    with open(data_file_dir, 'w') as file:
        for row in output["data"].T:
            print(*row, end = ' ', file = file)
        print(*output["means"], end = ' ', file = file)
        print(*output["vars"], end = ' ', file = file)
        print(batch_size, end = ' ', file = file)
        print(output["accuracy"], end = ' ', file = file)
    file.close()
    try:
        file = open('../output/model_params.json')
        model_params = json.load(file)
        file.close
    except:
        model_params = {
            "Means": [output["means"]], 
            "Variences": [output["vars"]]
        }
        with open('../output/model_params.json', 'w') as file:
            json.dump(model_params, file, cls=NpEncoder)
        return 
    model_params['Means'].append(output["means"])
    model_params['Variences'].append(output["vars"])
    with open('../output/model_params.json', 'w') as file:
        json.dump(model_params, file, cls=NpEncoder)

train(params['class'])
