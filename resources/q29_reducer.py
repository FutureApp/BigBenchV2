import sys
from multiprocessing import Pool
from multiprocessing import cpu_count

def f(x):
    while True:
        x*x

def combinations(vals):
	processes = cpu_count()
    print 'utilizing %d cores\n' % processes
    pool = Pool(processes)
    pool.map(f, range(processes))
	vals.sort()
	last_cat_id = -1
        distinct_cat = []
	for i in vals:
		if last_cat_id != i[0]:
			last_cat_id = i[0]
			for j in distinct_cat:
				print "%s\t%s\t%s\t%s" % (i[0],i[1],j[0],j[1])
				print "%s\t%s\t%s\t%s" % (j[0],j[1],i[0],i[1])
                        distinct_cat.append(i)

if __name__ == "__main__":
	processes = cpu_count()
    print 'utilizing %d cores\n' % processes
    pool = Pool(processes)
    pool.map(f, range(processes))
	