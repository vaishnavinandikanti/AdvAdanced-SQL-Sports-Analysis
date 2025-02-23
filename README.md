# **Baseball Data Analysis Using Advanced SQL**

## **Project Overview**
This project focuses on analyzing baseball player data using MySQL. It includes insights into schools producing players, salary trends, player career statistics, and player comparisons. The dataset consists of four tables: `players`, `salaries`, `school_details`, and `schools`.

---

## **Database Schema**
### **1. Schools Table**
| Column   | Type         | Description                        |
|----------|-------------|------------------------------------|
| `schoolID` | Primary Key | Unique identifier for schools     |
| `name_full` | VARCHAR     | Full name of the school           |
| `city`   | VARCHAR     | City where the school is located  |
| `state`  | VARCHAR     | State where the school is located |
| `country` | VARCHAR     | Country where the school is located |

### **2. School Details Table**
| Column   | Type         | Description                                      |
|----------|-------------|--------------------------------------------------|
| `schoolID` | Foreign Key | References `schoolID` from the `schools` table |
| `yearID` | INT         | Year the player attended the school            |
| `playerID` | INT         | Unique identifier for the player               |

### **3. Salaries Table**
| Column   | Type         | Description                         |
|----------|-------------|-------------------------------------|
| `yearID` | INT         | Year of the salary record          |
| `teamID` | VARCHAR     | Team identifier                     |
| `playerID` | INT         | Player identifier                  |
| `salary` | DECIMAL     | Player salary for the given year   |

### **4. Players Table**
| Column   | Type         | Description                                      |
|----------|-------------|--------------------------------------------------|
| `playerID` | Primary Key | Unique identifier for each player              |
| `nameGiven` | VARCHAR     | Player's full name                             |
| `birthYear` | INT         | Year of birth                                 |
| `birthMonth` | INT         | Month of birth                               |
| `birthDay` | INT         | Day of birth                                 |
| `debut` | DATE        | Date of the player's first game                |
| `finalGame` | DATE        | Date of the player's last game                |
| `bats` | VARCHAR     | Batting preference (`R`, `L`, `B`)              |
| `height` | INT         | Height in inches                              |
| `weight` | INT         | Weight in pounds                              |

---

## **Analysis Sections**

### **1. School Analysis**
- Displayed all schools and their details.
- Analyzed the number of schools producing players per decade.
- Identified the top 5 schools with the most players.
- Extracted the top 3 schools per decade that produced the most players.

### **2. Salary Analysis**
- Displayed all salaries data.
- Identified the top 20% of teams based on average annual spending.
- Computed cumulative salary spending per team over the years.
- Found the first year each team’s total spending surpassed $1 billion.

### **3. Player Career Analysis**
- Displayed player details and counted the total players.
- Calculated the starting and ending age of each player along with career length.
- Determined the teams where each player started and ended their career.
- Found players who started and ended on the same team and played for over a decade.

### **4. Player Comparison Analysis**
- Displayed all players data.
- Identified players with the same birthday.
- Created a summary table showing the percentage of players batting right, left, and both for each team.
- Analyzed changes in player height and weight over decades and their differences.

---

## **Conclusion**
This project provides in-depth insights into baseball player trends, team salary expenditures, and school contributions to professional baseball. Using MySQL queries, various patterns were identified to better understand player statistics and team performance over the years.

---

## **Technologies Used**
- **MySQL Workbench**
- **SQL Queries** (Joins, CTEs, Aggregations, Window Functions)

---

