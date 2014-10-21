#!/usr/bin/env python
import csv
import operator

'''
Quick and dirty code to figure out which NHL teams
are blacked out ONLY because they are playing a team
more favored by the network.
'''

def get_affected(team,games):
    affected = {}
    for g in games:
        t1 = g[0]
        t2 = g[1]
        if (team == t1 or team == t2) and g[2]:
            if team == t1 :
                other_team = t2
            else:
                other_team = t1
            if other_team not in affected:
                affected[other_team]=0
            affected[other_team] +=1
            games.remove(g)
    return games,affected



blackout={}
games=[]
with open("schedule-2015.tsv") as tsv:
    tsv.next()
    for line in csv.reader(tsv, delimiter='\t'):
        home=line[1]
        away=line[2]
        if home not in blackout:
            blackout[home]=0
        if away not in blackout:
            blackout[away]=0

        network=line[4]

        if network.find('NHL') >=0  or network.find('NBC')>=0 :
            blackout[home] += 1
            blackout[away] += 1

        games.append((home,away,network.find('NHL') >=0  or network.find('NBC')>=0))


sorted = sorted(blackout.items(), key=operator.itemgetter(1))[::-1]
print sorted
lookup= {}
for i in range(30):
    lookup[sorted[i][0]]=i

for i in range(30):
    team = sorted[i][0]
    count = sorted[i][1]
    if count > 0:
        games,affected=get_affected(team,games)
        for ateam in affected:
            index=lookup[ateam]
            n=affected[ateam]
            original= sorted[index][1]
            sorted[index]= (ateam,original-n)


losers=[]
for i in sorted:
    if i[1]==0:
        losers.append(i[0])

print losers

