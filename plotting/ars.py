import numpy as np
import math
import matplotlib.pyplot as plt

def inverse_square(p,r):
    return p/(float(4)*math.pi*math.pow(r,2))
def rad_damage_test(p,r):
    return inverse_square(p, r)*math.pow(r,3.8)
def rd2(r):
    if r<1000:
        return 1.089031e-13 * math.pow(r,4.320986)
    else:
        return (r/float(1000))**2

# approx 0.001 damage/sec/rad
maxt = 200
radius = 8400
d=range(1,5000)
dps = float(0.001)
dpsl=[]
dpsle=[]
for i in d:
    dpsl.append(i*dps)
for i in d:
    dpsle.append(
    rd2(i)
    )
plt.title("Damage/sec per dose")
plt.plot(d, dpsl, color="red")
plt.plot(d, dpsle, color="blue")
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
#plt.show()
