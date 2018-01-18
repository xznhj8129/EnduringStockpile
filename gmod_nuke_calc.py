import math

def roundup(x):
    return int(math.ceil(x / 100.0)) * 100


data = """1kt
Fireball radius: 80 m 
Air blast radius (200 psi): 80 m 
Air blast radius (20 psi): 220 m 
Air blast radius (10 psi): 310 m 
Air blast radius (5 psi): 460 m 
Air blast radius (1.5 psi): 0.98 km 
Radiation radius (5000 rem): 0.51 km 
Radiation radius (1000 rem): 0.73 km 
Radiation radius (500 rem): 0.84 km
Thermal radiation radius (100 cal/cm2): 80 m 
Thermal radiation radius (35 cal/cm2): 230 m 
Thermal radiation radius (3rd degree burns): 0.5 km
Thermal radiation radius (2nd degree burns (50%)): 0.66 km
Thermal radiation radius (1st degree burns (50%)): 0.94 km 

10kt
Fireball radius: 200 m 
Air blast radius (200 psi): 170 m 
Air blast radius (20 psi): 470 m 
Air blast radius (10 psi): 0.67 km 
Air blast radius (5 psi): 0.99 km 
Air blast radius (1.5 psi): 2.11 km 
Radiation radius (5000 rem): 0.84 km 
Radiation radius (1000 rem): 1.12 km 
Radiation radius (500 rem): 1.25 km 
Thermal radiation radius (100 cal/cm2): 420 m 
Thermal radiation radius (35 cal/cm2): 0.71 km 
Thermal radiation radius (3rd degree burns): 1.41 km
Thermal radiation radius (2nd degree burns (50%)): 1.85 km 
Thermal radiation radius (1st degree burns (50%)): 2.58 km

20kt
Fireball radius: 260 m 
Air blast radius (200 psi): 220 m 
Air blast radius (20 psi): 0.59 km
Air blast radius (10 psi): 0.85 km 
Air blast radius (5 psi): 1.24 km 
Air blast radius (1.5 psi): 2.65 km 
Radiation radius (5000 rem): 0.97 km 
Radiation radius (1000 rem): 1.27 km 
Radiation radius (500 rem): 1.41 km 
Thermal radiation radius (100 cal/cm2): 0.59 km 
Thermal radiation radius (35 cal/cm2): 0.99 km 
Thermal radiation radius (3rd degree burns): 1.91 km 
Thermal radiation radius (2nd degree burns (50%)): 2.52 km 
Thermal radiation radius (1st degree burns (50%)): 3.52 km 

50kt
Fireball radius: 380 m 
Air blast radius (200 psi): 300 m
Air blast radius (20 psi): 0.8 km
Air blast radius (10 psi): 1.45 km
Air blast radius (5 psi): 1.69 km
Air blast radius (1.5 psi): 3.6 km
Radiation radius (5000 rem): 1.16 km
Radiation radius (1000 rem): 1.49 km 
Radiation radius (500 rem): 1.64 km 
Thermal radiation radius (100 cal/cm2): 0.93 km 
Thermal radiation radius (35 cal/cm2): 1.54 km 
Thermal radiation radius (3rd degree burns): 2.87 km
Thermal radiation radius (2nd degree burns (50%)): 3.79 km 
Thermal radiation radius (1st degree burns (50%)): 5.26 km 

100kt
Fireball radius: 500 m 
Air blast radius (200 psi): 370 m 
Air blast radius (20 psi): 1.01 km 
Air blast radius (10 psi): 1.45 km 
Air blast radius (5 psi): 2.12 km 
Air blast radius (1.5 psi): 4.54 km 
Radiation radius (5000 rem): 1.33 km 
Radiation radius (1000 rem): 1.67 km 
Radiation radius (500 rem): 1.82 km 
Thermal radiation radius (100 cal/cm2): 1.3 km 
Thermal radiation radius (35 cal/cm2): 2.14 km 
Thermal radiation radius (3rd degree burns): 3.9 km 
Thermal radiation radius (2nd degree burns (50%)): 5.14 km 
Thermal radiation radius (1st degree burns (50%)): 7.1 km

250kt
Fireball radius: 0.72 km 
Air blast radius (200 psi): 0.51 km
Air blast radius (20 psi): 1.37 km 
Air blast radius (10 psi): 1.97 km 
Air blast radius (5 psi): 2.88 km 
Air blast radius (1.5 psi): 6.16 km 
Radiation radius (5000 rem): 1.56 km 
Radiation radius (1000 rem): 1.93 km 
Radiation radius (500 rem): 2.09 km 
Thermal radiation radius (100 cal/cm2): 2.01 km 
Thermal radiation radius (35 cal/cm2): 3.31 km 
Thermal radiation radius (3rd degree burns): 5.84 km 
Thermal radiation radius (2nd degree burns (50%)): 7.68 km 
Thermal radiation radius (1st degree burns (50%)): 10.5 km

500kt
Fireball radius: 0.95 km 
Air blast radius (200 psi): 0.64 km 
Air blast radius (20 psi): 1.73 km 
Air blast radius (10 psi): 2.48 km 
Air blast radius (5 psi): 3.63 km 
Air blast radius (1.5 psi): 7.76 km 
Radiation radius (5000 rem): 1.75 km 
Radiation radius (1000 rem): 2.13 km 
Radiation radius (500 rem): 2.29 km 
Thermal radiation radius (100 cal/cm2): 2.8 km 
Thermal radiation radius (35 cal/cm2): 4.59 km 
Thermal radiation radius (3rd degree burns): 7.91 km 
Thermal radiation radius (2nd degree burns (50%)): 10.4 km 
Thermal radiation radius (1st degree burns (50%)): 14.1 km 

1mt
Fireball radius: 1.26 km 
Air blast radius (200 psi): 0.8 km 
Air blast radius (20 psi): 2.18 km 
Air blast radius (10 psi): 3.12 km 
Air blast radius (5 psi): 4.58 km 
Air blast radius (1.5 psi): 9.78 km 
Radiation radius (5000 rem): 1.94 km 
Radiation radius (1000 rem): 2.33 km 
Radiation radius (500 rem): 2.5 km 
Thermal radiation radius (100 cal/cm2): 3.88 km 
Thermal radiation radius (35 cal/cm2): 6.35 km 
Thermal radiation radius (3rd degree burns): 10.7 km 
Thermal radiation radius (2nd degree burns (50%)): 14 km 
Thermal radiation radius (1st degree burns (50%)): 19 km 

5mt
Fireball radius: 2.39 km 
Air blast radius (200 psi): 1.38 km 
Air blast radius (20 psi): 3.72 km 
Air blast radius (10 psi): 5.34 km 
Air blast radius (5 psi): 7.83 km 
Air blast radius (1.5 psi): 16.7 km 
Radiation radius (5000 rem): 2.46 km 
Radiation radius (1000 rem): 2.88 km 
Radiation radius (500 rem): 3.05 km 
Thermal radiation radius (100 cal/cm2): 8.23 km 
Thermal radiation radius (35 cal/cm2): 13.3 km 
Thermal radiation radius (3rd degree burns): 21.3 km 
Thermal radiation radius (2nd degree burns (50%)): 28 km 
Thermal radiation radius (1st degree burns (50%)): 37.5 km """

testdata = {}
exdata = {
    'fireball': 0,
    '200psi': 0,
    '20psi': 0,
    '10psi': 0,
    '5psi': 0,
    '1.5psi': 0,
    '5krem': 0,
    '1krem': 0,
    '500rem': 0,
    'burn5': 0,
    'burn4': 0,
    'burn3': 0,
    'burn2': 0,
    'burn1': 0
    }

#parse nukemap data
x=data.split('\n\n')
c=0
print()
print('Real data')
print('Ground burst')
for i in x:
    print()
    y = i.split('\n')
    power = y.pop(0)
    testdata[power] = {}
    print(power)
    for j in range(len(y)):
        try:
            d = float(y[j].split(': ')[1].split(' km')[0])*1000
        except ValueError:
            d = float(y[j].split(': ')[1].split(' m')[0])
        entry = list(exdata.keys())[j]
        print(entry,str(int(d))+'m')
        testdata[power][entry] = d

#convert 
scalefactor = 12
uconv = float(52.493)
scale = float(1)/scalefactor

print()
print()
print('Gmod conversion')
print('1:'+str(scalefactor),'scale')
print('Gmod standard units')
for power in testdata:
    print()
    print(power)
    for i in testdata[power]:
        print(i,roundup(testdata[power][i] * uconv * scale))
