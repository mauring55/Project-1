def load_cows(filename):
    """
    Read the contents of the given file.  Assumes the file contents contain
    data in the form of comma-separated cow name, weight pairs, and return a
    dictionary containing cow names as keys and corresponding weights as values.

    Parameters:
    filename - the name of the data file as a string

    Returns:
    a dictionary of cow name (string), weight (int) pairs
    """
    # open file and save the contents to data
    filhand = open(filename)
    data = filhand.read()
    filhand.close()

    # turn the data into a list
    pairs = data.split('\n')
    
    cowsData = {}
    for pair in pairs:
        cow = pair.split(',')
        cowsData[cow[0]] = int(cow[1])
    
    return cowsData

def greedy_cow_transport(cows,limit=10):
    """
    Uses a greedy heuristic to determine an allocation of cows that attempts to
    minimize the number of spaceship trips needed to transport all the cows. The
    returned allocation of cows may or may not be optimal.
    The greedy heuristic should follow the following method:

    1. As long as the current trip can fit another cow, add the largest cow that will fit
        to the trip
    2. Once the trip is full, begin a new trip to transport the remaining cows

    Does not mutate the given dictionary of cows.

    Parameters:
    cows - a dictionary of name (string), weight (int) pairs
    limit - weight limit of the spaceship (an int)
    
    Returns:
    A list of lists, with each inner list containing the names of cows
    transported on a particular trip and the overall list containing all the
    trips
    """
    # copy cows dict and initialize empty list of trips and cows that have already been taken
    cows = cows.copy()
    trips = []
    takenCows = []
    
    # sort the cows; heaviest first
    cowsName = sorted(cows.keys(), key=cows.get, reverse=True)
    
    # iterate through all of the cows
    for i in range(len(cowsName)):
        currentWeight = 0
        currentTrip =[]

        # if the cow fits into the spaceship, take it
        if (not cowsName[i] in takenCows) and cows[cowsName[i]] <= limit:
            takenCows.append(cowsName[i])
            currentTrip.append(cowsName[i])
            currentWeight += cows[cowsName[i]]

            # iterate through the remaining cows to see if other fits with the other
            for j in range(i+1, len(cowsName)):
                if (not cowsName[j] in takenCows) and currentWeight + cows[cowsName[j]] <= limit:
                    takenCows.append(cowsName[j])
                    currentTrip.append(cowsName[j])
                    currentWeight += cows[cowsName[j]]
        
        # if nothing fits skip over
        if currentTrip != []:
            trips.append(currentTrip)

    return trips


cows = load_cows('ps1_cow_data.txt')
trips = greedy_cow_transport(cows,limit=10)
print(trips)