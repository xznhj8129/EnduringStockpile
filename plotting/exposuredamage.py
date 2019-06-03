import random

print 'Constant dose damage simulation'
n_sim = 1000
print 'Rads/min','\t','Time to death'
for r in range(1,51):
    rad_dose = r*100
    dc = 0
    avt=[]
    for i in range(n_sim):
        hp = 100
        dose = 0
        t=0
        dead = False
        
        while 1:
            dose += round(((rad_dose/float(60))))
        
            if random.randrange(0,100)<=round((dose/float(1000))*20):
                hp -= random.randrange(1,10)
            
            if hp<=0:
                dead = True
                hp = 0
                avt.append(t)
                break

            t+=1
    avgt = int(round(sum(avt)/float(n_sim)))
    print rad_dose,'\t',avgt
        
