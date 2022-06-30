# -*- coding: utf-8 -*-
"""
Created on Sun Jun 26 11:02:34 2022

@author: alireza

 MATRIX MULTIPLICATION
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
for i in range(0,SIZE):
    for j in range(0,SIZE):
        fbin.write( format(int2bin2sComp(A[i,j], 16), "016b")  + "\n")
        fdec.write( str(A[i,j]) + "\n")
for i in range(0,SIZE):
    for j in range(0,SIZE):
        fbin.write( format(int2bin2sComp(B[i,j], 16), "016b")  + "\n")
        fdec.write( str(B[i,j]) + "\n")

ab = [0]*SIZE
for i in range(0,SIZE):
    for j in range(0,SIZE):
        par_sum = 0
        for k in range(0,SIZE):
            ab[k] = A[i,k] * B[k,j]
            par_sum  = par_sum  + ab[k]
#            fbin.write( format(int2bin2sComp(ab[i], 16), "016b")  + "\n")
#            fdec.write( str(ab[i]) + "\n")
        AB[i,j] = par_sum
print(AB)
for i in range(0,SIZE):
    for j in range(0,SIZE):
        fbin.write( format(int2bin2sComp(AB[i,j], 16), "016b")  + "\n")
        fdec.write( str(AB[i,j]) + "\n")
fbin.close()
fdec.close()

AB_GOLD = np.matmul(A, B)

np.array_equal(AB, AB_GOLD)


np.array_equal(AB_FILE_R, AB_FILE_G)