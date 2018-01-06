import psycopg2
from tabulate import tabulate

# Hello, there. Welcome to the functions of the LookingGlass tool app.
# Here you will find Python code that connects to the agency's news data
# and automatically runs VIEWs created from the data that'll provide quick
# answers.

# I highly suggest connecting to the database itself and having a looksee at
# the tables and VIEWS in there if you want to change or add another function.

# The first is a helper function that will connect the queries to the Database.
# The following  3 Name-Right-on-the-Tin functions execute the query
# and print the results in an easy-to-read table.

# The final function sorts the tables and prints descriptions alongside.

DBNAME = "news"  # Name of the Database


def QueryResults(query):
    global results
    # Here we are connecting to the database.
    db = psycopg2.connect(dbname=DBNAME)
    c = db.cursor()
    # This is where we execute an SQL query.
    c.execute(query)
    # This gives the tuple data recieved an easy keyword.
    results = c.fetchall()
    db.close()
    return results


def Top3Articles():  # Articles with the most pageviews.
    QueryResults("select * from top_3_articles")
    # This prints the aforementioned tuples into a nice table.
    # Note: You will need to write the headers for each column in the table.
    # As python only returns the rows.
    print tabulate(results, headers=['Article', 'Author', 'Hits'])


def TopAuthors():  # Authors with the most pageviews across all articles.
    QueryResults("select * from most_popular_authors")
    print tabulate(results, headers=['Name', 'Hits'])


def Over1prcErrors():  # Days in which errors were >1%
    QueryResults("select * from over_1prc_error")
    print tabulate(results, headers=['Day', 'Requests',
                                     'Errors', 'Percentage'])


def report():
    print "The Top 3 Articles are:\n"
    Top3Articles()
    print "\nThe Top Authors are:\n"
    TopAuthors()
    print "\nDays in which Errors accounted for more than 1% of Requests\n"
    Over1prcErrors()
