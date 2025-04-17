import numpy as np
import pandas as pd
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

# Hyperparameters
D = 10000  # Dimensionality of hypervectors
num_levels = 10  # Quantization levels for feature mapping

current_date = datetime.now().strftime("%Y-%m-%d")

print("Current Date:", current_date)
start_time = datetime.now().strftime("%H:%M:%S")

print("Start Time:", start_time)
# Load the Iris dataset
# mnist = fetch_openml('mnist_784')

# # X contains the pixel values (28x28 images, flattened into 784 features)
# X = mnist.data

# # y contains the target labels (digits 0-9)
# y = mnist.target.astype(int)
dataset = pd.read_csv('/home/arunp24/RISCHD/dataset/isolet/isolet_dataset.csv')
y = dataset['label']
X = dataset.drop('label', axis=1)
num_classes = len(np.unique(y))

num_classes = len(np.unique(y))
print(X.shape[1])#no of features
print(X.shape[0])
print(num_classes)

# Normalize features to [0,1] range
scaler = MinMaxScaler()
X = scaler.fit_transform(X)

# Function to create a random hypervector
def generate_random_hv(D):
    return np.random.choice([-1, 1], size=D)

# Generate base hypervectors for feature encoding
feature_hvs = [generate_random_hv(D) for _ in range(X.shape[1])]  #4x10,000
level_hvs = [generate_random_hv(D) for _ in range(num_levels)]    #10x 10,000
print(len(feature_hvs[1]))#no of new features
print(np.array(feature_hvs).shape)
print(np.array(level_hvs).shape)

# Function to encode a feature vector into a hypervector
def encode_hypervector(features, feature_hvs, level_hvs, num_levels):
    encoded_hv = np.zeros(len(feature_hvs[0]))
    for i, value in enumerate(features):
        level_index = int(value * (num_levels - 1))  # Map feature to a level
        encoded_hv += feature_hvs[i] * level_hvs[level_index]
    # return encoded_hv,np.sign(encoded_hv)  # Binarize
    return np.sign(encoded_hv)

# Function to train and evaluate HDC using cross-validation
def cross_validate_hdc(D, num_levels, k_folds=5):
    kf = KFold(n_splits=k_folds, shuffle=True, random_state=42)
    accuracies = []

    for train_index, test_index in kf.split(X):
        X_train, X_test = X[train_index], X[test_index]
        y_train, y_test = y[train_index], y[test_index]
        # print("X_train.shape")
        # print(X_train.shape)
        # Generate feature and level hypervectors
        feature_hvs = [generate_random_hv(D) for _ in range(X.shape[1])]
        level_hvs = [generate_random_hv(D) for _ in range(num_levels)]

        # Encode dataset into hypervectors
        X_train_hv = np.array([encode_hypervector(x, feature_hvs, level_hvs, num_levels) for x in X_train])
        X_test_hv = np.array([encode_hypervector(x, feature_hvs, level_hvs, num_levels) for x in X_test])
        # print("X_train_hv_shape")
        # print(X_train_hv.shape)
        # Train class prototypes
        class_prototypes = {cls: np.zeros(D) for cls in range(num_classes)}
        for x, label in zip(X_train_hv, y_train):
            class_prototypes[label] += x  # Accumulate class vectors
        # print("Class HV")
        # print(class_prototypes)
        class_prototypes_bin = class_prototypes.copy()
        # Binarize class prototypes
        for cls in class_prototypes:
            class_prototypes_bin[cls] = np.sign(class_prototypes[cls])

        # Classification using cosine similarity
        def classify_hdc(sample):
            similarities = {cls: np.dot(sample, class_prototypes_bin[cls]) for cls in class_prototypes_bin}
            return max(similarities, key=similarities.get)

        # Predict and compute accuracy
        y_pred = np.array([classify_hdc(x) for x in X_test_hv])
        accuracies.append(accuracy_score(y_test, y_pred))

    return np.mean(accuracies),class_prototypes  # Return average accuracy

# List of different dimensionalities to test
#dimensionalities = [1000, 5000, 10000, 15000, 20000]
dimensionalities = 1000
# Run cross-validation for each D
best_D = None
best_accuracy = 0
results = {}
num_levels = [5,10,11,12,13,14 ,15,16,17,20]

accuracy,class_prototypes = cross_validate_hdc(D, 10)
results[D] = accuracy
print(f"D={D}, Accuracy={accuracy:.4f}")

# if accuracy > best_accuracy:
#     best_accuracy = accuracy
#     best_D = D

# print(f"\nBest dimensionality: {best_D} with accuracy {best_accuracy:.4f}")
print("Class HV")
print(class_prototypes)
print(len(class_prototypes[0]))
# for l in num_levels:
#    results[D] = accuracy
#    print(f"D={D}, Accuracy={accuracy:.4f}")
#
#    if accuracy > best_accuracy:
#        best_accuracy = accuracy
#        best_l = l
#
#print(f"\nBest dimensionality: {best_l} with accuracy {best_accuracy:.4f}")