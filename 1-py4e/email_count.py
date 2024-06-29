#Open the file mbox-short.txt and read it line by line. When you find a line that starts with 'From ' like the following line:
#From stephen.marquard@uct.ac.za Sat Jan  5 09:14:16 2008
#You will parse the From line using split() and print out the second word in the line (i.e. the entire address of the person who sent the message). Then print out a count at the end.
#Hint: make sure not to include the lines that start with 'From:'. Also look at the last line of the sample output to see how to print the count.

#You can download the sample data at http://www.py4e.com/code3/mbox-short.txt

filhandle = open(input('Enter filename: '))

def email_count(file):
  count = 0
  
  for line in file:
    line_list = list()
    
    if not line.startswith('From '):
      continue

    else:
      count += 1
      line_list = line.split()
      email = line_list[1]
      print(email)

  return count
  
print('There were', email_count(filhandle), 'lines in the file with From as the first word')


      
  