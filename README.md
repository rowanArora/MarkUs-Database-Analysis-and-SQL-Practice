# MarkUs Database Analysis Project

## Overview
The MarkUs Database Analysis Project is an academic endeavor aimed at analyzing and querying a database related to MarkUs, an open-source tool designed for grading assignments within a web application environment. The project involves extracting specific information from the MarkUs database using complex SQL queries and implementing Python methods to interact with the database.

## Project Goals
- Analyze grade distributions across assignments.
- Investigate grader performance over time.
- Compare the performance of students who work alone versus in groups.
- Ensure consistent grading by graders.
- Monitor workload distribution among graders.
- Analyze submission patterns of student groups.
- Identify graders with broad experience in the course.
- Evaluate the performance of students who prefer to work in groups.
- Identify pairs of students who consistently work together.
- Generate a comprehensive report on assignment grades per group and categorize them based on averages.

## Technologies Used
- **SQL**: Complex SQL queries are utilized to extract data from the MarkUs database.
- **Python**: Python scripts are written to interact with the database using the psycopg2 library.
- **psycopg2**: A PostgreSQL adapter for Python, enabling database interaction from Python scripts.
- **PostgreSQL**: The relational database management system used to store the MarkUs database.

## Project Structure
The project consists of two main parts:

1. **SQL Queries**: Complex SQL queries are written to extract specific information from the MarkUs database. Each query addresses a specific aspect of the analysis goals, such as grade distributions, grader performance, student group comparisons, etc.

2. **Embedded SQL in Python**: Python methods are implemented to interact with the MarkUs database using embedded SQL queries. These methods perform tasks such as assigning graders to groups, removing students from groups, creating student groups for assignments, and more.

## Usage
- Clone the project repository to your local machine.
- Ensure you have PostgreSQL installed and running.
- Import the MarkUs database schema into your PostgreSQL instance.
- Run the provided SQL queries against the MarkUs database to extract desired information.
- Execute the Python scripts to interact with the database and perform specific tasks outlined in the project requirements.

## Contributors
- Rowan Arora
- Codi Lee
