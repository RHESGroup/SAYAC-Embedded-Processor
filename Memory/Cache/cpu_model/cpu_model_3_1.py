# -*- coding: utf-8 -*-
"""
Created on Mon Jun 27 21:03:37 2022

@author: alireza

Simple Read & write
"""


def int2bin2sComp(val, width):
    if val < 0 :
        val = 2**width + val
    return val

SIZE = 16384;

A = range(0, SIZE)

fbin = open("data_mem.bin", "w")

for i in range(0,SIZE):
    fbin.write( format(int2bin2sComp(A[i], 16), "016b")  + "\n")

fbin.close()
