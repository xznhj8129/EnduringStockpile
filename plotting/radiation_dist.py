import numpy as np
import math
import matplotlib.pyplot as plt

def inverse_square(r):
    return float(1)/math.pow(r,2)

def calc_rads(dist, falloutradius):
    dist_mod = np.clip((falloutradius-float(dist)) / float(falloutradius), 0, 1)
    rads = round(5000*dist_mod)
    return rads

def format_rads(r):
    if (r<1):
        return str(int(round(r*float(1000))))+' milirads'
    elif (r<0.001):
        return str(int(round(r*float(1000000))))+' microrads'
    else:
        return str(int(round(r)))+' rads'

radius = 1000
radpower = 100
n = 500
hammer_to_meter = 52.521

d=1
while 1:
    distance = d/float(10)
    r = radpower*inverse_square(distance)
    print distance, str(distance*hammer_to_meter)+'u',format_rads(r)
    if r <= float(0.1):
        break
    d+=1
    

t = np.arange(1, n, 1)
d1 = []
d2 = []
for dist in range(1,n):
    d1.append(calc_rads(dist, radius))
    d2.append(5000*inverse_square(dist))
    #print dist, 5000*inverse_square(dist)
plt.title("")
plt.plot(t, d1, color="red")
plt.plot(t, d2, color="blue")
plt.xlabel('Dist')
plt.ylabel('Rads/min')
#plt.show()
