# -*- coding: utf-8 -*-
"""
Created on Tue Jun 21 19:07:26 2022

@author: alireza
"""

import numpy as np # linear algebra

size = 16;

A = list(range(-5, size-5))
B = list(range(8, -size+8, -1))

ab = [0]*size
AB = 0
for i in range(0,size):
    AB = AB + A[i] * B[i]
    ab[i] = A[i] * B[i]
print(AB)


## drag and drop output_ram.txt (modelsim result file) and next next 
## then run lines below:
#diff = 0
#for i in range(0,577):
#    diff += OA[i] - output_ramtxt[i]
#print(diff)
## diff must be zero for validation check mark