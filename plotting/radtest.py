

dist = float(1000)
for i in range(0,21):
    d = i*100
    m = (dist-d)/dist
    
    if m<=0.1:
        m2 = (dist-d)/dist
    else:
        print d, m
