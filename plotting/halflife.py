import numpy as np
import math
import matplotlib.pyplot as plt

radpower = 1000
n = 240
hl = float(20)

"""
n0*(1/2)^(t/hl)
"""

t = np.arange(1, n, 1)
d1 = []
d2 = []
for time in range(1,n):
    hlt = time/hl
    power = radpower * (math.pow(float(0.5), float(time)/hl))
    print time, hlt, power
    d1.append(power)
    
plt.title("")
plt.plot(t, d1, color="red")
plt.xlabel('Time')
plt.ylabel('Rad power')
plt.show()


