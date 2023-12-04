f = open('input.txt', 'r')
data = f.readlines()
print(len(data))

for line in data:
    vals = [x for x in line.strip().split(':')[1].replace('|', '').split(' ') if x]
    print('\n'.join(vals))

