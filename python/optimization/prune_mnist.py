import numpy as np
import random
import seaborn as sns
from sklearn import datasets
import matplotlib.pyplot as plt
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import MinMaxScaler
from sklearn.metrics import accuracy_score
from sklearn.model_selection import KFold
from sklearn.datasets import fetch_openml
from datetime import datetime
from globalVariables import *

current_date = datetime.now().strftime("%Y-%m-%d")

print("Current Date:", current_date)
start_time = datetime.now().strftime("%H:%M:%S")

print("Start Time:", start_time)

# Hyperparameters
#D=[5000,10000,15000,20000,25000]
#D = 25000
# U_th = 100
# D_th = 1
# d =[500,1000,1500,2000,2500]
# #d = 5000
# num_levels = 10


# Load the MNIST dataset
# mnist = fetch_openml('mnist_784')

# # X contains the pixel values (28x28 images, flattened into 784 features)
# X = mnist.data

# # y contains the target labels (digits 0-9)
# y = mnist.target.astype(int)

# num_classes = len(np.unique(y))


# # Normalize features to [0,1] range
# scaler = MinMaxScaler()
# X = scaler.fit_transform(X)

# X_train_top, X_test, y_train_top, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
# X_train, X_val, y_train, y_val = train_test_split(X_train_top, y_train_top, test_size=0.2, random_state=42)

# Function to create a random hypervector
def generate_random_hv(D):
    return np.random.choice([-1, 1], size=D)

# Generate base hypervectors for feature encoding
# feature_hvs = [generate_random_hv(D) for _ in range(X.shape[1])]  #4x10,000
# level_hvs = [generate_random_hv(D) for _ in range(num_levels)]    #10x 10,000
# print(len(feature_hvs[1]))
#np.array(feature_hvs).shape
# np.array(level_hvs).shape

# Function to encode a feature vector into a hypervector
def encode_hypervector(features, feature_hvs, level_hvs, num_levels):
    encoded_hv = np.zeros(len(feature_hvs[0]))
    for i, value in enumerate(features):
        level_index = int(value * (num_levels - 1))  # Map feature to a level
        encoded_hv += feature_hvs[i] * level_hvs[level_index]
    # return encoded_hv,np.sign(encoded_hv)  # Binarize
    return np.sign(encoded_hv)
# Function to train and evaluate HDC using cross-validation

import numpy as np

def search_index(value, U_th, D_th):
    return D_th <= value < U_th  # Check if value is within threshold range

def prune_effectual_dimensions(C_D, U_th, D_th, d):
    D = len(C_D)  # Total number of dimensions
    
    # Sort indices based on hypervector sum values
    sorted_indices = np.argsort(C_D)
    
    # Split into two groups: lower half (likely zero) and upper half (likely one)
    D_half = D // 2
    zi_N = sorted_indices[:D_half]  # Indices with low values (zeros)
    oi_N = sorted_indices[D_half:]  # Indices with high values (ones)
    
    S_d = []  # Stores selected effectual dimensions
    S_d_values = []  # Stores corresponding hypervector values
    count = 0
    i = 0
    
    while count < d and i < D_half:
        if search_index(C_D[zi_N[i]], U_th, D_th):
            S_d.append(zi_N[i])
            S_d_values.append(C_D[zi_N[i]])
            count += 1
        
        if count < d and search_index(C_D[oi_N[i]], U_th, D_th):
            S_d.append(oi_N[i])
            S_d_values.append(C_D[oi_N[i]])
            count += 1
        
        i += 1
    
    return S_d

def prune(class_prototypes,U_th, D_th, d):
    #C_D = [None] * len(class_prototypes)
    C_D = {}
    all_selected_dimensions =[]
    for i in range(len(class_prototypes)):
        print("Pruning for Class:",i)
        C_D[i] = class_prototypes[i]
        selected_dimensions= prune_effectual_dimensions(C_D[i], U_th, D_th, d)
        all_selected_dimensions.extend(selected_dimensions)

    # Remove duplicates by converting the list to a set, and then back to a sorted list
    unique_sorted_dimensions = sorted(list(set(all_selected_dimensions)))
    pruned_class_prototypes = {}
    for i in range(len(class_prototypes)):
        pruned_class_prototypes[i] = [class_prototypes[i][j] for j in unique_sorted_dimensions]
    return unique_sorted_dimensions,pruned_class_prototypes


def cross_validate_hdc(D, num_levels,U_th,D_th,d,X_train_hv,X_val_hv):
    #print(d,U_th,D_th)
    accuracies = []

    # Generate feature and level hypervectors
    # feature_hvs = [generate_random_hv(D) for _ in range(X_train.shape[1])]
    # level_hvs = [generate_random_hv(D) for _ in range(num_levels)]

    # # Encode dataset into hypervectors
    # X_train_hv = np.array([encode_hypervector(x, feature_hvs, level_hvs, num_levels) for x in X_train])
    # X_val_hv = np.array([encode_hypervector(x, feature_hvs, level_hvs, num_levels) for x in X_val])

    # Train class prototypes
    class_prototypes = {cls: np.zeros(D) for cls in range(num_classes)}
    for x, label in zip(X_train_hv, y_train):
        #label = label[0] #commented this
        class_prototypes[label] += x  # Accumulate class vectors

    merged_index_list,pruned_class_prototypes = prune(class_prototypes,U_th,D_th,d)
    
    keys = len(pruned_class_prototypes)
    values_shapes = [len(value) for value in pruned_class_prototypes.values()]
    # print(f"Number of keys: {keys}")
    # print(f"Shape of values in dictionary (if list values): {values_shapes}")
    pruned_class_prototypes_bin = pruned_class_prototypes.copy()
    # Binarize class prototypes
    for cls in pruned_class_prototypes:
        pruned_class_prototypes_bin[cls] = np.sign(pruned_class_prototypes[cls])
        #pruned_class_prototypes_bin[cls] = (pruned_class_prototypes[cls] > 0).astype(int)
    
    X_val_pruned_hv = np.array([X_val_hv[:, i] for i in merged_index_list]).T
    # Classification using cosine similarity
    def classify_hdc(sample):
        similarities = {cls: np.dot(sample, pruned_class_prototypes_bin[cls]) for cls in pruned_class_prototypes_bin}
        return max(similarities, key=similarities.get)

    # Predict and compute accuracy
    y_pred = np.array([classify_hdc(x) for x in X_val_pruned_hv])
    accuracies.append(accuracy_score(y_val, y_pred))

    return np.mean(accuracies),values_shapes[0]  # Return average accuracy


####################################################################################################################################################################
#TODO: GENETIC ALGO/PCA/CV
# for i in [0,1,2,3,4]:
#     for j in [0,1,2,3,4]:
# accuracy= cross_validate_hdc(D,num_levels,U_th,D_th,d)
# print(f"D={D},d={d},Accuracy={accuracy:.4f}")

####################################################################################################################################################################

end_time = datetime.now().strftime("%H:%M:%S")

print("End Time:", end_time)

start = datetime.strptime(start_time, "%H:%M:%S")
end = datetime.strptime(end_time, "%H:%M:%S")

#Calculate the difference
execution_time = end - start

#Get the total seconds from the timedelta and convert to HH:MM:SS format
execution_seconds = execution_time.total_seconds()
hours = int(execution_seconds // 3600)
minutes = int((execution_seconds % 3600) // 60)
seconds = int(execution_seconds % 60)

#Print the result in HH:MM:SS format
print(f"Execution time: {hours:02}:{minutes:02}:{seconds:02}")