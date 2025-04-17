"""
Author: Bhargav D V, Research Scholar, IIITB, under guidance of Prof. Madhav Rao.
This script is used to generate fitness plots for multiplier evolution for NSGA evolution
"""

#import packages
import numpy as np
import matplotlib.pyplot as plt
#from globalVariables import *
#import packages


#--------------------global variables--------------------------
#DESIGN='8x8'
DPI=500

#----------------------global variables---------------------------


def generateFitnessPlot():
    #read numpy array data
    
    
    fitnessData=np.load('/home/arunp24/RISCHD/nsga_results/isolet/fitness.npy')
    previousBestFitness=0
    #print(fitnessData[0][1][0])
    #x axis
    X=range(0,len(fitnessData)+1)
    # X=range(0,11)
    #y axis
    FitnessPlot1=[]
    #mean_actual=21307064320/65536
    for gen in fitnessData:
        euclideanValues=[]
        for value in gen:
            euclideanValues.append(abs(value[0])*100) #absolute to make accuracy positive
        bestFitness=np.mean(np.array((euclideanValues)))
        #bestFitness=min(euclideanValues)
        if(bestFitness>previousBestFitness):
            FitnessPlot1.append(bestFitness)
            previousBestFitness=bestFitness
        else:
            FitnessPlot1.append(previousBestFitness)

    
    plt.figure(dpi=DPI)
    plt.title("ISOLET Dataset")
    #plt.scatter(0, 3**0.5, color='red',label='Initial Solution')
    plt.plot(X,[0]+FitnessPlot1, "--",color="blue",)
    
    plt.xlabel('Generations', fontsize=14)
    plt.ylabel('Accuracy(%)', fontsize=14)
    #plt.legend()
    plt.savefig('/home/arunp24/RISCHD/nsga_results/isolet/fitness.png')
    #plt.savefig(FITNESS_PLOT_PATH)
    plt.close()
    #plt.show()

        


generateFitnessPlot()