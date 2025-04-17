
"""
variables 
"""
import pandas as pd
import numpy as np
from sklearn import datasets
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import MinMaxScaler
from sklearn.datasets import fetch_openml
from datetime import datetime
#from tensorflow.keras.datasets import cifar10


D = 10000
#U_th = 100
#D_th = 1
#d = [500,1000,1500,2000,2500]
num_levels = 10
n_threads = 20
# Load the Iris dataset
# mnist = fetch_openml('mnist_784')
# (X_download, y), (X_test, y_test) = cifar10.load_data()
# # X contains the pixel values (28x28 images, flattened into 784 features)

dataset = pd.read_csv('/home/arunp24/RISCHD/dataset/pamap2/pamap2.csv')
y = dataset['activityID']
X = dataset.drop('activityID', axis=1)
# X = mnist.data

# # y contains the target labels (digits 0-9)
# y = mnist.target.astype(int)
num_classes = len(np.unique(y))

# print(num_classes)
# print(y)
# X = X_download.reshape(X_download.shape[0],-1)

#loading dataset

print(X.shape)
print(y.shape)
print(num_classes)

# # Normalize features to [0,1] range
scaler = MinMaxScaler()
X = scaler.fit_transform(X)

#X_train_flattened = X_train.reshape(X_train.shape[0], -1)
# Normalize features to [0,1] range

X_new, X_new_test, y_new_train_top, y_new_test = train_test_split(X, y, test_size=0.2, random_state=42)
print(X_new.shape)
print(X_new_test.shape)
X_new_1, X_new_test_1, y_new_train_top_1, y_new_test_1 = train_test_split(X_new_test, y_new_test, test_size=0.2, random_state=42)
print(X_new_1.shape)
print(X_new_test_1.shape)

X_train_top, X_test, y_train_top, y_test = train_test_split(X_new_test_1, y_new_test_1, test_size=0.2, random_state=42)
print("Train")
print(X_train_top.shape)
print(X_test.shape)
X_train, X_val, y_train, y_val = train_test_split(X_train_top, y_train_top, test_size=0.2, random_state=42)

def generate_random_hv(D):
    return np.random.choice([-1, 1], size=D)


def encode_hypervector(features, feature_hvs, level_hvs, num_levels):
    encoded_hv = np.zeros(len(feature_hvs[0]))
    for i, value in enumerate(features):
        level_index = int(value * (num_levels - 1))  # Map feature to a level
        encoded_hv += feature_hvs[i] * level_hvs[level_index]
    # return encoded_hv,np.sign(encoded_hv)  # Binarize
    return np.sign(encoded_hv)

feature_hvs = [generate_random_hv(D) for _ in range(X_train.shape[1])]
level_hvs = [generate_random_hv(D) for _ in range(num_levels)]
print("Generation of Random Hypervectors done")
print("Generation of Encoded Hypervectors starts")
time_1 = datetime.now().strftime("%H:%M:%S")
print("Start Time:", time_1)
# Encode dataset into hypervectors
X_train_hv = np.array([encode_hypervector(x, feature_hvs, level_hvs, num_levels) for x in X_train])
X_val_hv = np.array([encode_hypervector(x, feature_hvs, level_hvs, num_levels) for x in X_val])

print("Generation of Encoded Hypervectors done")
time_2 = datetime.now().strftime("%H:%M:%S")
print("End Time:", time_2)