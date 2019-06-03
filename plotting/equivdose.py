
for i in range(1,51):
    dose = i*100
    
    print dose,'\t',int(round(dose*float(0.75))),'\t',int(round(dose*float(0.25))),'\t',int(round((dose*float(0.25))*float(0.75)))
