from cProfile import label
from mpl_toolkits.mplot3d import Axes3D
import matplotlib.pyplot as plt
import pandas as pd 
import numpy as np 

data = pd.read_csv("./DataSets/14107121/Client4.csv", delimiter=",")
headers = data.columns
data = data.to_numpy()
temp = data.T
lables = temp[0]
data = temp[2:5]
classes = np.unique(lables)

# creating figure

fig = plt.figure()
ax = plt.axes(projection = "3d")
for label in classes :  
    temp_data = data[:, np.where(lables == label)[0]]
    plot_geeks = ax.scatter3D(temp_data[0], temp_data[1], temp_data[2],  label = label)



# plot_geeks = ax.plot(temp_data[0], temp_data[1], temp_data[2], color='orange', label = f"{classes[3]}")

# setting title and labels
ax.set_title("3D plot")
ax.set_xlabel('x-axis')
ax.set_ylabel('y-axis')
ax.set_zlabel('z-axis')
# ax.legend(classes[0], classes[1], classes[2])  
ax.legend(loc="best")
ax.view_init(0, -180)
# displaying the plot
plt.show()
