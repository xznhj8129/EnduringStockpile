import numpy as np
import math
import matplotlib.pyplot as plt

def rad_dmg(dist, t, falloutradius, maxt):
    raddmg = 15
    dist_mod = np.clip((falloutradius-float(dist)) / float(falloutradius), 0, 1)
    time_mod = math.pow((float(maxt) - time) / float(maxt), 6)
    dmg = np.clip(raddmg * dist_mod * time_mod, 0.1, raddmg)
    return dmg

def calc_rads(dist, t, falloutradius, maxt):
    raddmg = 15
    dist_mod = np.clip((falloutradius-float(dist)) / float(falloutradius), 0, 1)
    time_mod = math.pow((float(maxt) - time) / float(maxt), 6)
    rads = round(5000*dist_mod*time_mod)
    return rads

# approx 0.003 damage/sec/rad
maxt = 200
radius = 8400
t = np.arange(1, maxt+1, 1)
d1 = []
d2 = []
d3 = []
d4 = []
d5 = []
for time in range(0,maxt):
    d1.append(rad_dmg(500, time, radius, 200))
    d2.append(rad_dmg(2000, time, radius, 200))
    d3.append(rad_dmg(3500, time, radius, 200))
    d4.append(rad_dmg(5000, time, radius, 200))
    d5.append(rad_dmg(7500, time, radius, 200))
plt.title("20 kilotons ground blast, rad damage per second")
plt.plot(t, d1, color="red", label="500 distance from ground zero")
plt.plot(t, d2, color="orange", label="2000 distance from ground zero")
plt.plot(t, d3, color="yellow", label="3500 distance from ground zero")
plt.plot(t, d4, color="green", label="5000 distance from ground zero")
plt.plot(t, d5, color="blue", label="7500 distance from ground zero")
plt.legend(loc='upper right', frameon=True)
plt.xlabel('Seconds')
plt.ylabel('Damage/second')
plt.show()

d1 = []
d2 = []
d3 = []
d4 = []
d5 = []
line = []
for time in range(0,maxt):
    d1.append(calc_rads(500, time, radius, 200))
    d2.append(calc_rads(2000, time, radius, 200))
    d3.append(calc_rads(3500, time, radius, 200))
    d4.append(calc_rads(5000, time, radius, 200))
    d5.append(calc_rads(7500, time, radius, 200))
    line.append(1000)
plt.title("20 kilotons ground blast, rads/hr")
plt.plot(t, d1, color="red", label="500 distance from ground zero")
plt.plot(t, d2, color="orange", label="2000 distance from ground zero")
plt.plot(t, d3, color="yellow", label="3500 distance from ground zero")
plt.plot(t, d4, color="green", label="5000 distance from ground zero")
plt.plot(t, d5, color="blue", label="7500 distance from ground zero")
plt.plot(t, line, color="black", label="max level for hazmat suit")
plt.legend(loc='upper right', frameon=True)
plt.xlabel('Seconds')
plt.ylabel('Rads/hr')
plt.show()
