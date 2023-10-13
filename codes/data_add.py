from audioop import add
from cmath import isnan, nan
from curses import window
from math import floor
from re import L, sub
import numpy as np
import pandas as pd
from sklearn import tree
from scipy.stats import norm 
from sklearn import  preprocessing
file = open("../output/class.txt", "r")
classes = file.read()
classes = classes.split(",")
file.close()
duplicate_ratio = 2
number_of_features = 13
for label in classes: 
    data = pd.read_csv(f"../test_data/{label}.csv", delimiter=",")
    data = data.to_numpy()
    np.random.shuffle(data)
    lables = data[:, len(data.T)-1]
    values = pd.DataFrame(data[:, 0:len(data.T) - 1])
    added = values.rolling(window = number_of_features).median()
    added = added.to_numpy()
    # added = added[np.where(added != nan)[0]]
    index = np.where(np.isnan(added[:,0]) == False)[0]
    added = added[index, :]
    added_labels = np.asarray([label]* len(added))
    adding = np.concatenate((added, added_labels[:, None]), axis=1)
    adding = pd.DataFrame(adding)
    adding.to_csv(f"../test_data/{label}.csv", mode = 'a', sep = ",", index= False, header= False)




