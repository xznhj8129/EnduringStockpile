import numpy as np
import math
import matplotlib.pyplot as plt

# Iodine-131: 8 days
# Strontium-90: 28 years
# Caesium-137: 30 years


n = 600

radpower1 = 1000
hl1 = float(30)
radpower2 = 100
hl2 = float(120)

"""
n0*(1/2)^(t/hl)
"""

t = np.arange(1, n, 1)
d1 = []
d2 = []
dt = []
for time in range(1,n):
    power1 = radpower1 * (math.pow(float(0.5), float(time)/hl1))
    power2 = radpower2 * (math.pow(float(0.5), float(time)/hl2))
    print time, power1, power2
    d1.append(power1)
    d2.append(power2)
    dt.append(power1+power2)
    
plt.title("")
plt.plot(t, d1, color="red")
plt.plot(t, d2, color="blue")
plt.plot(t, dt, color="black")
plt.xlabel('Time')
plt.ylabel('Rad power')
plt.show()


