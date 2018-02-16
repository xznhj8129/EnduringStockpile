import numpy as np
import math
import matplotlib.pyplot as plt

# approx 0.01 damage/sec/rad
maxt = 200
radius = 8400
d=range(1,5000)
dps = float(0.01)
dpsl=[]
for i in d:
    dpsl.append(i*dps)
plt.title("Damage/sec per dose")
plt.plot(d, dpsl, color="red")
plt.xlabel('Dose (rads)')
plt.ylabel('DPS')
plt.show()

ttd = []
for i in dpsl:
    ddps = float(100)/i
    ttd.append(ddps)
plt.title("Time to death for dose")
plt.plot(d, ttd, color="red")
plt.xlabel('Dose (rads)')
plt.ylabel('Seconds to death')
plt.show()
