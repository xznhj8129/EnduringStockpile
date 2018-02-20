#import numpy as np
import math
import matplotlib.pyplot as plt


"""
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
"""
def inverse_square(p,r):
    return p/(float(4)*math.pi*math.pow(r,2))
def rad_dose(p,r):
    return inverse_square(p, r)/math.pow(r,3.8)
def rad_dose2(p,r):
    return inverse_square(p, r)/math.pow(r,4)
#10kt = 3.11710999999e+25
#250kt = 1.15745639974e+27

r5000 = 3200
r1000 = 4300
r500 = 4900

dose = 500
d = 0
p=0
ld = 0
mod = float(10)
while d<dose:
    ld = d
    d=rad_dose(p, r500)
    #print p, d
    p=p+mod

    rd = d-ld
    if rd< float(0.1):
        mod=mod*10
print p, d
print
p=1.60111111111e+25
dd=[]
dd2=[]
dd3=[]
distlist = [r5000,r1000,r500]
for i in range(1,200):
    dist = i*100
    dose = rad_dose(p,dist)
    dose2 = rad_dose2(p,dist)
    dd.append(dose)
    dd2.append(dose2)
    dd3.append(dose/2)
    #if i in distlist:
    #    print 'dist',i,':', dose,'rads'
    print dist, round(dose),round(dose/2), round(dose2)
print 'power', p
print 'mod',mod
plt.title("Rads for distance")
plt.semilogy(range(1,200), dd, color="red")
plt.semilogy(range(1,200), dd2, color="blue")
plt.semilogy(range(1,200), dd3, color="black")
plt.xlabel('Distance')
plt.ylabel('Dose (rads)')
plt.show()
