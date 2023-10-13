import pandas as pd 
import numpy as np 
import subprocess



compile  = subprocess.run(['rm -rf ../DataSets/PreprocessedData'], stdout=subprocess.PIPE, shell=True, text=True)
compile = subprocess.run(['mkdir ../DataSets/PreprocessedData'], stdout=subprocess.PIPE, shell=True, text=True)
file = open("../configs/number_of_features.txt")
temp = file.read()
file.close()
number_of_features = int(temp)
for client_id in range(4):
    data = pd.read_csv(f"../DataSets/14107121/Client{client_id+1}.csv", delimiter=",")
    headers = data.columns
    data = data.to_numpy()
    temp = data.T
    lables = temp[0]
    data = temp[2:5]
    classes = np.unique(lables)
    data = pd.DataFrame(data.T)
    temp_diff = data.diff(axis= 0)
    first_diff = temp_diff[2: len(data)]
    # Adding extra feature to the dataset 
    accelerated = np.power(data.to_numpy()[:, 0], 2) + np.power(data.to_numpy()[:, 1], 2) + np.power(data.to_numpy()[:, 2], 2)
    accelerated = np.sqrt(accelerated.astype(float))
    data = data [2:len(data)]
    temp = np.concatenate((data, accelerated[2:len(accelerated), None], accelerated[2:len(accelerated), None]), axis = 1 )
    data = temp
    for feature in range(len(data[1, :]), number_of_features):
        data = np.concatenate((data, accelerated[2:len(accelerated), None]), axis = 1 )
    data = data + 100 
    client = pd.DataFrame(np.concatenate((data, lables[2:len(lables), None]), axis = 1)) 
    client.to_csv(f"../DataSets/PreprocessedData/client{client_id+1}.csv", index= False, sep = ",", header= False)

