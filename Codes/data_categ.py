
from re import sub
import pandas as pd 
import numpy as np 
import subprocess


test_split_ratio = 0.9
compile  = subprocess.run(['rm -rf ./DataSets/CategorizedData'], stdout=subprocess.PIPE, shell=True, text=True)
compile = subprocess.run(['mkdir ./DataSets/CategorizedData'], stdout=subprocess.PIPE, shell=True, text=True)

for client_id in range(4)  :
    compile = subprocess.run([f'mkdir ./DataSets/CategorizedData/client{client_id+1}'], stdout=subprocess.PIPE, shell=True, text=True)
    try:
        file = open("class.txt", "r")
        submitted_classes = file.read()
        file.close()
        submitted_classes = submitted_classes.split(",")
    except: 
        submitted_classes = []

    data = pd.read_csv(f"./DataSets/PreprocessedData/client{client_id+1}.csv", delimiter=",")
    headers = data.columns
    data = data.to_numpy()
    temp = data.T
    lables = temp[len(temp)-1 ]
    classes = np.unique(lables)
    for label in classes : 
        if not label in submitted_classes:
            file = open("class.txt", "a")
            if len(submitted_classes):
                file.write(f",{label}")
            else :
                file.write(label)
            file.close()
            submitted_classes.append(label)
        index = np.where(lables == label)[0]
        # data = temp.T
        data = temp.T[index[0: int(test_split_ratio*len(index))]]
        test_data = temp.T[index[int(test_split_ratio*len(index)) : len(index)]]
        seperated = pd.DataFrame(data)
        test = pd.DataFrame(test_data)
        seperated.to_csv(f"./DataSets/CategorizedData/{label}.csv", mode = 'a', sep = ",", index= False, header= False)
        test.to_csv(f"./DataSets/CategorizedData/test.csv", mode = 'a', sep = ",", index= False, header= False)

         