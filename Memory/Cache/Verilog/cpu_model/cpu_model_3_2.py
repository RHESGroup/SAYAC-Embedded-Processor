# -*- coding: utf-8 -*-
"""
Created on Sat Jun 25 23:08:11 2022

@author: alireza
"""

def int2bin2sComp(val, width):
    if val < 0 :
        val = 2**width + val
    return val

import numpy as np # linear algebra

SIZE = 16;

A = np.random.randint(-128,127,size=(SIZE))
B = np.random.randint(-128,127,size=(SIZE))

fbin = open("data_mem.bin", "w")
fdec = open("data_mem.dec", "w")
for i in range(0,SIZE):
    fbin.write( format(int2bin2sComp(A[i], 16), "016b")  + "\n")
    fdec.write( str(A[i]) + "\n")
for i in range(0,SIZE):
    fbin.write( format(int2bin2sComp(B[i], 16), "016b")  + "\n")
    fdec.write( str(B[i]) + "\n")

ab = [0]*SIZE
AB = 0
for i in range(0,SIZE):
    AB = AB + A[i] * B[i]
    ab[i] = A[i] * B[i]
    fbin.write( format(int2bin2sComp(ab[i], 16), "016b")  + "\n")
    fdec.write( str(ab[i]) + "\n")
print(AB)
fbin.write( format(int2bin2sComp(AB, 16), "016b")  + "\n")
fdec.write( str(AB) + "\n")
fbin.close()
fdec.close()