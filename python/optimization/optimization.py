"""
Author: Bhargav D V, Research Scholar, IIITB, under guidance of Prof. Madhav Rao.
This script is used to evolve RISCV hyper dimensional computing architecture
"""

#import packages
from pymoo.algorithms.moo.nsga2 import NSGA2
from pymoo.algorithms.soo.nonconvex.ga import GA
from pymoo.optimize import minimize
from pymoo.problems import get_problem
from pymoo.util.ref_dirs import get_reference_directions
from pymoo.core.problem import Problem,ElementwiseProblem
from pymoo.operators.crossover.pntx import PointCrossover, SinglePointCrossover, TwoPointCrossover
from pymoo.operators.sampling.rnd import IntegerRandomSampling
from pymoo.operators.mutation.inversion import InversionMutation
from pymoo.operators.mutation.bitflip import BitflipMutation
from pymoo.termination import get_termination
from pymoo.core.problem import StarmapParallelization
from pymoo.optimize import minimize
from pymoo.core.callback import Callback
from pymoo.visualization.scatter import Scatter
from pymoo.core.mutation import Mutation
import random
import matplotlib.pyplot as plt
import numpy as np
import os
import multiprocessing
import re
from datetime import datetime
import math
#from HDIRIS import cross_validate_hdc
from prune_mnist import cross_validate_hdc
from globalVariables import *
from multiprocessing.pool import ThreadPool
#import packages


MUTATION_RATE=0.1
CURRENT_GEN=0
GENERATIONS=100
POPULATION=100
SEED=42
pool=ThreadPool(1)
#this custom problem class is used to describe parameters of problem to be optimized by NSGA2
class MyCallback:
    def __init__(self):
        self.data = []

    def __call__(self, algorithm):
        # Extract the objective values for all solutions in the current population
        F = algorithm.pop.get('F')
        # Store the objective values
        self.data.append(F)

class CustomMutation(Mutation):
    def _do(self, problem, X, **kwargs):
        global CURRENT_GEN
        CURRENT_GEN=CURRENT_GEN+1
        # Example: Add a small random value to each gene
        np.random.seed(SEED)
        x = CURRENT_GEN/GENERATIONS
        MUTATION_RATE = math.exp(-(x**2)/2)
        for i in range(len(X)):
            if(random.random()<MUTATION_RATE):
                X[i][0]=random.randint(1,problem.xu[0])
            if(random.random()<MUTATION_RATE):
                #X[i][1]=random.random(1,1,step=0.01)
                #X[i][0]=random.randrange(X[i][1],problem.xu[0],step=0.01)
                possible_values = np.arange(problem.xl[1], problem.xu[1]+1, 1)
                X[i][1]=np.random.choice(possible_values)
                
                possible_values = np.arange(problem.xl[2], X[i][1], 1)
                #print(X[i][1])
                X[i][2]=np.random.choice(possible_values)
           
        return X
    
class RISCV(Problem):
    def __init__(self,**kwargs):
                 #d   #U_th      #L_th
        self.xl=[1,    1.0,      0.0]
        self.xu=[10000, 100.0,     99.0]

        super().__init__(n_var=3, n_obj=1, n_ieq_constr=1,n_constr=0,elementwise_evaluation=False, xl=self.xl, xu=self.xu,vtype=int,**kwargs)

    def _evaluate(self, X, out, *args, **kwargs):
        global CURRENT_GEN
        
        
        CURRENT_GEN=CURRENT_GEN+1
        #print(X)
        params = [[X[k],k] for k in range(len(X))]
        if(CURRENT_GEN==1):
            file=open('/home/arunp24/RISCHD/nsga_results/pamap2/pamap2_results.txt',mode='w',encoding='utf-8')
            
            file.close()
        # calculate the function values in a parallelized manner and wait until done
        RESULT=pool.starmap(self.evaluateProblem, params)
        F=[]
        G=[]
        for i in RESULT:
            F.append(i[0])
            G.append(i[1])
        
        # store the function values and return them.
        out["F"] = np.array(F)
        out['G']= np.array(G)

    def evaluateProblem(self, x, Z):
        print('=======================================')
        print(x)
        
        print('d='+str(x[0]))
        print('dth='+str(x[2]))
        print('uth='+str(x[1]))
        
        accuracy,value_shapes=cross_validate_hdc(D,num_levels,x[1],x[2],x[0],X_train_hv,X_val_hv) #lower,upper,d
        #accuracy=random.random()
        #value_shapes = random.randint(1,10)
        print('Accuracy='+str(accuracy))
        print('Pruned d='+str(value_shapes))

        file=open('/home/arunp24/RISCHD/nsga_results/pamap2/pamap2_results.txt',mode='a',encoding='utf-8')
        file.write('Format: [d Uth Dth]\n')
        file.write('solution:\t ')
        file.write(str(x)+'\n')
        file.write(f'Pruned d=\t{value_shapes}\n')
        file.write('accuracy:\t')
        file.write(str(accuracy)+'\n========================================\n')
        file.close()

        return [[-accuracy],[0]]

def runFramework():
    
    file=open('/home/arunp24/RISCHD/nsga_results/pamap2/duration.txt',mode='w',encoding='utf-8')
    # get the current date and time
    # Get current date and time
    current_datetime = datetime.now()

    # Extract date, time, and day
    current_date = current_datetime.date()
    current_time = current_datetime.time()
    current_day = current_datetime.strftime("%A")

    file.write("Started Current Date:"+ str(current_date)+" Current Time:"+ str(current_time)+" Current Day:"+ str(current_day)+'\n')
    file.close()
    solution1=[10,1,0]
    #solution2=[10,1,2]
    sampling=np.array([solution1]*(POPULATION-1))
    #print(sampling)
    #sampling=np.vstack((np.array([solution1]),np.random.randint(low=1,high=2,size=(POPULATION-1,3))))

    problem=RISCV()
    callback = MyCallback()
    #ref_dirs = get_reference_directions("energy", 4,4)
    algorithm = GA(pop_size=POPULATION,
                        
            sampling=sampling,
        crossover=PointCrossover(n_points=47,prob=0.00),
        mutation=CustomMutation(),
                eliminate_duplicates=True,)
    termination = get_termination("n_gen", GENERATIONS)
    res = minimize(problem,
                    algorithm,
                    termination,
                    seed=SEED,
                    save_history=False,
                    callback=callback,
                    
                    verbose=True)

    print('Objectives='+str(res.F))
   
    
    print('solution='+str(res.X))
    file=open('/home/arunp24/RISCHD/nsga_results/pamap2/final_pamap2_results.txt',mode='w',encoding='utf-8')
    file.write('Format: [d Uth Dth]\n')
    file.write('solution:\t ')
    file.write(str(res.X)+'\n')
    file.write('accuracy:\t')
    file.write(str(-res.F)+'\n========================================\n')
    file.close()

    #print(callback.data)
    data=callback.data[1:]
    
    #data=np.delete(data,0)
    np.save('/home/arunp24/RISCHD/nsga_results/pamap2/fitness.npy',data)

    file=open('/home/arunp24/RISCHD/nsga_results/pamap2/duration.txt',mode='a',encoding='utf-8')
    # get the current date and time
    # Get current date and time
    current_datetime = datetime.now()

    # Extract date, time, and day
    current_date = current_datetime.date()
    current_time = current_datetime.time()
    current_day = current_datetime.strftime("%A")

    file.write("Ended Current Date:"+ str(current_date)+" Current Time:"+ str(current_time)+" Current Day:"+ str(current_day)+'\n')
    file.close()

runFramework()