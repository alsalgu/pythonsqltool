# LookingGlass: News Database Reporting Tool
---
---
    LookingGlass is a Python script that automatically runs PSQL queries for the agency's NEWS database. The queries are written to support data changing overtime to eliminate the hassle of having to go through it every time there's new traffic added to the logs.
    
    The following questions are answered and appeare in a easy-to-read table:
    (o) The top 3 articles of all time, listed by title and pageviews.
    (o) The top Authors of all time, listed by name and pageviews.
    (o) Days in which errors accounted for more than 1% of requests, listed by 
        total number of requests, errors, and the calculated percentage. 
---
## Requirements

- [**PostgreSQL**](https://www.postgresql.org/): A powerful, open source object-relational database system for UNIX-based systems. 
- [**Tabulate**](https://pypi.python.org/pypi/tabulate): A Python library and command utility that allows to print data in easy to read tables. 
- [**Python 3.6.2**](https://www.python.org/): The programming language used to make the tool. 
- [**Psycopg**](http://initd.org/psycopg/docs/install.html): A PSQL adapter for Python. 
- **NEWS Database**: All the information you're lifting comes from the 'newsdata' SQL file, so make sure you have access to that; Either you have it in your tool's folder or access to it from the agency's server. It comes with the .zip, regardless.
- **Specific VIEWS**: New views were created from the database's tables to turn long queries into a single one. You can find the commands in the 'Creating the VIEWs' section of this file.
- **UNIX Based System**
---
### What's In in the Folder

- \__init__.Py
    - The \__init\__ .py files are required to make Python treat the directories as containing packages; this is done to prevent directories with a common name, such as string, from unintentionally hiding valid modules that occur later on the module search path. In the simplest case, \__init\__.py can just be an empty file, but it can also execute initialization code for the package or set the \__all\__ variable, described later. [(Source)](https://docs.python.org/3/tutorial/modules.html#packages)

- toolapp .py
    - This file is the actual tool you'll be calling in the terminal. It simply imports the tool's functions from the other file and runs it. 

- toolfunctions .py
    - This file contains the code which defines the functions that will connect to the database and request the informatoin.

- newsdata .sql 
    - This file contains sample data from the news agency. It contains SQL code used to create the NEWs database.

- views.sql
    - This file contains the queries used to create views from the aforementioned data.
---
### Setting Up
    For thoroughness sake, here are the links to the libraries/utilities needed to run the program and the codes for installing them. If the terminal command line listed here doesn't work, visit the link and follow their instructions for your OS.

- Install Python: [Download and Run their Installer](https://www.python.org/downloads/)
- Install PostgreSQL: [Download and Run their Installer](https://www.postgresql.org/download/)
- Install Psycopg: [Full Instructions Here](http://initd.org/psycopg/docs/install.html)
    `$ pip install psycopg2`
- Install Tabulate: [Full Instructions Here](https://pypi.python.org/pypi/tabulate)
    `$ pip install tabulate`
- Import the newsdata.SQL file to the "news" Database
    `psql -d news -f newsdata.sql`
- Import the views.SQL file to the "news" Database
    `psql -d news -f views.sql`
- Unzip folder into an easy to access, and easy to remember directory.
- Creating the 
---
### Creating the Views
    Here are the queries used to create useful VIEWs that will allow for more complex data to be retrieved with a single query. They have been categorized as to allow flexibility for future reporting additions.

**If you already imported them in using the code the Setting Up Steps, you do not need to do this! This is for reference!**

**Connecting to the Database**
    In your terminal, after connecting to your Host with SSH, punch in:
    `psql -d [databasename]`

**Create View Query**
    `CREATE VIEW [viewname] AS [query]`
- getrequests_by_date
     ```
    CREATE VIEW getrequests_by_date AS
    SELECT date_trunc('day'::text, log."time") AS day,
        count(log.method) AS requests
    FROM log
    WHERE log.method = 'GET'::text
    GROUP BY (date_trunc('day'::text, log."time"));
- errors_by_date
    ```
    CREATE VIEW errors_by_date AS
    SELECT date_trunc('day'::text, log."time") AS day,
        count(log.status) AS errors
    FROM log
    WHERE log.status <> '200 OK'::text
    GROUP BY (date_trunc('day'::text, log."time"))
    ORDER BY (count(log.status)) DESC;
- requests_and_errors
    ```
    CREATE VIEW requests_and_errors AS
     SELECT getrequests_by_date.day,
        errors_by_date.errors,
        getrequests_by_date.requests
     FROM getrequests_by_date,
        errors_by_date
    WHERE getrequests_by_date.day = errors_by_date.day
    GROUP BY getrequests_by_date.day, errors_by_date.errors, getrequests_by_date.requests;
- error_percentages
    ```
    CREATE VIEW error_percentages AS
    SELECT requests_and_errors.day,
        requests_and_errors.requests,
        requests_and_errors.errors,
        round(requests_and_errors.errors::numeric / requests_and_errors.requests::numeric * 100::numeric, 2) AS percentage

   FROM requests_and_errors
  GROUP BY requests_and_errors.day, requests_and_errors.requests, requests_and_errors.errors
  ORDER BY (round(requests_and_errors.errors::numeric / requests_and_errors.requests::numeric * 100::numeric, 2)) DESC;
- over_1prc_error
    ```
    CREATE VIEW over_1prc_error AS
    SELECT error_percentages.day,
        error_percentages.requests,
        error_percentages.errors,
        error_percentages.percentage
   FROM error_percentages
  WHERE error_percentages.percentage > 1::numeric;
- most_popular_authors
    ```
    CREATE VIEW most_popular_authors AS
    SELECT authors.name,
        count(log.path) AS hits
    FROM authors
        JOIN articles ON articles.author = authors.id
        JOIN log ON log.path ~~ ('%'::text || articles.slug)
  GROUP BY authors.name
  ORDER BY (count(log.path)) DESC;
- top_3_articles
    ```
    CREATE VIEW top_3_articles AS
    SELECT articles.title,
        authors.name,
        count(log.path) AS hits
   FROM articles
     JOIN authors ON articles.author = authors.id
     JOIN log ON log.path ~~ ('%'::text || articles.slug)
  GROUP BY articles.title, authors.name
  ORDER BY (count(log.path)) DESC
  LIMIT 3;
---
### Using the Tool App

- Open up your Terminal and change into the directory containing the files.
    `$ CD C:\\\Users\WhereverYouUnzipped\News`
- Run the program by using the command line:
    `$ python toolapp.py`
    *OR*
    `./toolapp.py`
- The app should execute the code and print it out in your terminal!
---

### F.A.Q.
    None as of yet, but you can contact me at [Whatever] At [Whatever] Dot Com for help.

---
### Known Bugs
    None as of yet but you can contact me at [Whatever] At [Whatever] Dot Com and let me know.
---

 
