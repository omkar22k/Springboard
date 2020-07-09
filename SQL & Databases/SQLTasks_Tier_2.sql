/* Welcome to the SQL mini project. You will carry out this project partly in
the PHPMyAdmin interface, and partly in Jupyter via a Python connection.

This is Tier 2 of the case study, which means that there'll be less guidance for you about how to setup
your local SQLite connection in PART 2 of the case study. This will make the case study more challenging for you: 
you might need to do some digging, aand revise the Working with Relational Databases in Python chapter in the previous resource.

Otherwise, the questions in the case study are exactly the same as with Tier 1. 

PART 1: PHPMyAdmin
You will complete questions 1-9 below in the PHPMyAdmin interface. 
Log in by pasting the following URL into your browser, and
using the following Username and Password:

URL: https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

In this case study, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */

/* QUESTIONS 
/* Q1: Some of the facilities charge a fee to members, but some do not.
Write a SQL query to produce a list of the names of the facilities that do. */
/* A1: SELECT name
FROM Facilities
WHERE membercost =0 */

/* Q2: How many facilities do not charge a fee to members? */
/* A2: 
SELECT COUNT( facid ) AS facilities
FROM Facilities
WHERE membercost =0 */

/* Q3: Write an SQL query to show a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost.
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */
/* A3. 
SELECT name
FROM Facilities
WHERE membercost < 0.20 * monthlymaintenance */


/* Q4: Write an SQL query to retrieve the details of facilities with ID 1 and 5.
Try writing the query without using the OR operator. */
/* A4:
SELECT *
FROM Facilities
WHERE facid IN ( 1, 5 )
*/


/* Q5: Produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100. Return the name and monthly maintenance of the facilities
in question. */
/* A5:
SELECT name, monthlymaintenance,
CASE WHEN monthlymaintenance >100
THEN 'expensive'
ELSE 'cheap'
END AS maintenance_group
FROM Facilities;
*/


/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Try not to use the LIMIT clause for your solution. */
/* A6:
SELECT firstname, surname
FROM Members
WHERE joindate = (SELECT max(joindate) FROM Members);
*/


/* Q7: Produce a list of all members who have used a tennis court.
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */
/*
SELECT f.name as facility, CONCAT(m.firstname,' ',m.surname) as member_name
FROM Bookings AS b
JOIN Facilities AS f
USING ( facid )
JOIN Members AS m
USING ( memid )
WHERE f.name LIKE 'Tennis Court%'
AND firstname NOT IN 'GUEST'
GROUP BY 1,2
*/


/* Q8: Produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30. Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */
/* A8:
SELECT f.name AS facility, CONCAT( m.firstname, ' ', m.surname ) AS member_name,
CASE WHEN m.firstname = 'GUEST'
THEN f.guestcost * b.slots
ELSE f.membercost * b.slots
END AS cost
FROM Bookings AS b
JOIN Facilities AS f
USING ( facid )
JOIN Members AS m
USING ( memid )
WHERE DATE( starttime ) = '2012-09-14'
HAVING cost > 30
*/

/* Q9: This time, produce the same result as in Q8, but using a subquery. */
/* A9:
SELECT * FROM (
SELECT f.name AS facility, CONCAT( m.firstname, ' ', m.surname ) AS member_name,
CASE WHEN m.firstname = 'GUEST'
THEN f.guestcost * b.slots
ELSE f.membercost * b.slots
END AS cost
FROM Bookings AS b
JOIN Facilities AS f
USING ( facid )
JOIN Members AS m
USING ( memid )
WHERE DATE( starttime ) = '2012-09-14'
 ) AS final
WHERE cost > 30
*/

/* PART 2: SQLite

Export the country club data from PHPMyAdmin, and connect to a local SQLite instance from Jupyter notebook 
for the following questions.  

/* Creating connection in Python
# Import packages
from sqlalchemy import create_engine
import pandas as pd

# Create engine: engine
engine  = create_engine('sqlite:///sqlite_db_pythonsqlite.db')

conn = engine.connect()

# Save the table names to a list: table_names
table_names = engine.table_names()

# Print the table names to the shell
print(table_names)
*/

QUESTIONS:
/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

/* A10:
query = """
        SELECT facility, sum(revenue) AS total_revenue
        FROM (
        SELECT f.name AS facility,
        CASE WHEN m.firstname = 'GUEST'
        THEN f.guestcost * b.slots
        ELSE f.membercost * b.slots
        END AS revenue
        FROM Bookings AS b
        JOIN Facilities AS f
        USING ( facid )
        JOIN Members AS m
        USING ( memid )
        )
        GROUP BY facility
        HAVING total_revenue < 1000
        ORDER BY revenue DESC
        """

q = pd.read_sql_query(query, conn)    
print(q.shape)
q
*/

/* Q11: Produce a report of members and who recommended them in alphabetic surname,firstname order */

/* A11:
query = """
        SELECT m.surname || ' ' || m.firstname as member,
        r.surname || ' ' || r.firstname AS recommender
        FROM Members AS m
        JOIN Members AS r
        ON m.recommendedby = r.memid
        WHERE m.recommendedby NOT IN ('')
        """

q = pd.read_sql_query(query, conn)    
print(q.shape)
q
*/

/* Q12: Find the facilities with their usage by member, but not guests */

/* A12:
query = """
        SELECT b.facid,f.name as facility, b.unique_members
        FROM
        (SELECT facid,count(distinct memid) AS unique_members
        FROM Bookings
        WHERE memid!=0
        GROUP BY 1
        ) AS b
        LEFT JOIN
        (
        SELECT facid, name
        FROM Facilities
        ) AS f
        USING(facid)
        """

q = pd.read_sql_query(query, conn)    
print(q.shape)
q
*/

/* Q13: Find the facilities usage by month, but not guests */
/* A13:
query = """
        SELECT b.facid,f.name as facility,b.month,b.hours_booked
        FROM
        (SELECT facid,strftime('%m',starttime) as month,sum(slots)/2 AS hours_booked
        FROM Bookings
        WHERE memid!=0
        GROUP BY 1,2
        ) AS b
        LEFT JOIN
        (
        SELECT facid, name
        FROM Facilities
        ) AS f
        USING(facid)
        """

q = pd.read_sql_query(query, conn)    
print(q.shape)
q
*/

