import numpy as np
import math
import matplotlib.pyplot as plt

def rad_dmg(dist, t, falloutradius, maxt):
    raddmg = 15
    dist_mod = np.clip((falloutradius-float(dist)) / float(falloutradius), 0, 1)
    time_mod = math.pow((float(maxt) - time) / float(maxt), 4)
    dmg = np.clip(raddmg * dist_mod * time_mod, 0.25, 15)
    return dmg

"""
t = np.arange(1, 5001, 1)
radius = float(5000)
damage = []
for dist in range(5000):
    relation = np.clip((radius-dist) / radius, 0, 1)
    dmg = (relation)
    damage.append(dmg)

plt.title("radiation damage per second")
plt.plot(t, damage, color="blue", label="Original")
plt.xlabel('Distance')
plt.ylabel('Damage')
plt.show()

maxt = 200
t = np.arange(1, maxt+1, 1)
raddam = 15
damage = []
for time in range(0,maxt):
    d2 = (float(maxt) - time) / float(maxt)
    d2 = d2**4
    #rel2 = np.clip(d2, 0, 1)
    dmg = d2 * raddam
    dmg2 = np.clip(dmg, 1, 15)
    damage.append(dmg2)
plt.title("radiation damage over time")
plt.plot(t, damage, color="blue", label="Original")
#plt.plot(t, dam2, color="red", label="New")
plt.xlabel('Time')
plt.ylabel('Damage')
plt.show()
"""
maxt = 200
radius = 5000
t = np.arange(1, maxt+1, 1)
d1 = []
d2 = []
d3 = []
d4 = []
for time in range(0,maxt):
    d1.append(rad_dmg(500, time, radius, 200))
    d2.append(rad_dmg(1500, time, radius, 200))
    d3.append(rad_dmg(2500, time, radius, 200))
    d4.append(rad_dmg(4500, time, radius, 200))
plt.title("radiation damage per second")
plt.plot(t, d1, color="red", label="500 dist")
plt.plot(t, d2, color="orange", label="1000 dist")
plt.plot(t, d3, color="yellow", label="2500 dist")
plt.plot(t, d4, color="green", label="4500 dist")
plt.legend(loc='upper right', frameon=True)
plt.xlabel('Time')
plt.ylabel('Damage')
plt.show()
