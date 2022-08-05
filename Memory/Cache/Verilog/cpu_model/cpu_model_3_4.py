# -*- coding: utf-8 -*-
"""
Created on Sun Jun 26 21:54:41 2022

@author: alireza

matrix multiplication & replacement
for 
    AB <- AXB
    A  <- AB/256

"""

def int2bin2sComp(val, width):
    if val < 0 :
        val = 2**width + val
    return val

import numpy as np # linear algebra

SIZE = 16;

A = np.random.randint(-64,63,size=(SIZE, SIZE))
B = np.random.randint(-64,63,size=(SIZE, SIZE))

AB = np.zeros((SIZE, SIZE), dtype=int)  #[[0] * SIZE] * SIZE

fbin = open("data_mem.bin", "w")
fdec = open("data_mem.dec", "w")

A_GOLD = np.zeros((SIZE, SIZE), dtype=int)
B_GOLD = np.zeros((SIZE, SIZE), dtype=int)
for i in range(0,SIZE):
    for j in range(0,SIZE):
        fbin.write( format(int2bin2sComp(A[i,j], 16), "016b")  + "\n")
        A_GOLD[i,j] = A[i,j]
for i in range(0,SIZE):
    for j in range(0,SIZE):
        fbin.write( format(int2bin2sComp(B[i,j], 16), "016b")  + "\n")
        B_GOLD[i,j] = B[i,j]

ab = [0]*SIZE
for itr in range (0, 3):
    for i in range(0,SIZE):
        for j in range(0,SIZE):
            par_sum = 0
            for k in range(0,SIZE):
                ab[k] = A[i,k] * B[k,j]
                par_sum  = par_sum  + ab[k]
            AB[i,j] = par_sum
    #print(AB)
    for i in range(0,SIZE):
        for j in range(0,SIZE):
            A[i,j] = AB[i,j]/256

for i in range(0,SIZE):
    for j in range(0,SIZE):
        fdec.write( str(A[i,j]) + "\n")
for i in range(0,SIZE):
    for j in range(0,SIZE):
        fdec.write( str(B[i,j]) + "\n")
for i in range(0,SIZE):
    for j in range(0,SIZE):
        fdec.write( str(AB[i,j]) + "\n")
    
fbin.close()
fdec.close()
#
#for itr in range (0, 2):
#    AB_GOLD = np.matmul(A_GOLD, B_GOLD)
#    A_GOLD = [row[:] for row in AB_GOLD]
#    A_GOLD = np.divide(A_GOLD, 1000, dtype=int)
#    
#
#np.array_equal(AB, AB_GOLD)
#
#
#np.array_equal(AB_FILE_R, AB_FILE_G)