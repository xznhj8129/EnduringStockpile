import random

"""
default
            dam = dose*float(0.001)
            if dam<1:
                ctd = dam*100
                draw = random.randrange(0,100)
                #print '\t',draw,ctd
                if draw<=ctd:
                    hp-=1
            else:
                hp-=dam
                """

print 'Instant dose damage simulation'
n_sim = 1000
print n_sim,'simulations/dose'

print 'Dose\tAvg HP\tTime\t\tMortality %'
for r in range(1,41):
    rad_dose = r*50
    dc = 0
    av = []
    avt = []
    for i in range(n_sim):
        dose = rad_dose
        hp = 100
        t=0
        dead = False
        
        while 1:
            if random.randrange(0,100)<=round((dose/float(1000))*20):
                hp -= random.randrange(1,10)
            
            dose -= random.randrange(0,11)
            if hp<=0:
                dead = True
                hp = 0
                break
            if dose<=0:
                break
            t+=1
        
        avt.append(t)
        av.append(hp)
        if dead: dc+=1

    avg_hp = int(round(sum(av)/float(n_sim)))
    avg_time = round(sum(avt)/float(n_sim))
    deathpercent = float(dc)/float(n_sim)
    print rad_dose,'\t', avg_hp,'\t', str(avg_time)+' sec','\t', str(deathpercent*100)+'%'
