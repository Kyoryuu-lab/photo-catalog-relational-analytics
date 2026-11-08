<h1>photo-catalog-relational-analytics</h1>
<p>Relational 3NF database schema, multi-table M:N entity relationships, and complex analytical SQL queries</p>

<h2>Project description</h2>
<p>This project implements a normalized relational database model (Third Normal Form) for media asset cataloging and evaluates advanced SQL query techniques:</p>
<ol>
  <li>
    <dl>
      <dt><b>Relational Architecture (3NF):</b></dt>
      <dd>Eliminates redundancy by decomposing entity records into independent tables: <code>photo</code>, <code>author</code>, and <code>genre</code>.</dd>
      <dd>Handles Many-to-Many (M:N) associations using junction mapping tables: <code>photo_author</code> and <code>photo_genre</code> with composite primary keys.</dd>
    </dl>
  </li>
  <li>
    <dl>
      <dt><b>Advanced Analytical SQL Querying:</b></dt>
      <dd><b>Multi-Table Joins:</b> Joins up to 5 entities simultaneously to produce comprehensive catalog projections.</dd>
      <dd><b>Grouping &amp; Aggregate Filtering:</b> Evaluates <code>GROUP BY</code> and <code>HAVING</code> filters on partitioned subsets.</dd>
      <dd><b>Correlated Subqueries &amp; Temporal Logic:</b> Uses <code>EXTRACT</code> / date parsing to track collaborations, identify lowest-frequency genres, and compare release timelines.</dd>
    </dl>
  </li>
  <li>Features an automated Python orchestration runner (<code>main.py</code>) enabling in-memory schema build, seeding, and execution in 1 click.</li>
</ol>

<h2>Project files</h2>
<table>
  <tr>
    <th colspan="2">photo-catalog-relational-analytics</th>
  </tr>
  <tr>
    <td>main.py</td>
    <td>Automated orchestrator creating an in-memory database, seeding records, and rendering query outputs</td>
  </tr>
  <tr>
    <td>sql/schema.sql</td>
    <td>DDL table definitions with constraints, foreign keys, and complete sample dataset dump</td>
  </tr>
  <tr>
    <td>sql/queries.sql</td>
    <td>Set of 5 optimized analytical SQL statements with detailed analytical explanations</td>
  </tr>
  <tr>
    <td>README.md</td>
    <td>Project documentation and relational schema specifications</td>
  </tr>
  <tr>
    <td>.gitignore</td>
    <td>Exclusion rules for bytecode, temporary SQLite dumps, and editor configs</td>
  </tr>
</table>

<h2>Database Schema Diagram (ER Model)</h2>
<pre>
   +-------------------+          +----------------------+          +-------------------+
   |      AUTHOR       |          |     PHOTO_AUTHOR     |          |       PHOTO       |
   +-------------------+          +----------------------+          +-------------------+
   | id_author (PK)    |&lt;---1:N---| id_author (PK, FK)   |          | id_photo (PK)     |
   | name              |          | id_photo  (PK, FK)   |---N:1---&gt;| name              |
   +-------------------+          +----------------------+          | date              |
                                                                    +-------------------+
   +-------------------+          +----------------------+                    |
   |       GENRE       |          |     PHOTO_GENRE      |                    |
   +-------------------+          +----------------------+                    |
   | id_genre (PK)     |&lt;---1:N---| id_genre  (PK, FK)   |                    |
   | name              |          | id_photo  (PK, FK)   |&lt;-------1:N---------+
   +-------------------+          +----------------------+
</pre>

<h2>Installation and launch</h2>
<ol>
  <b>
    <li>
      <dl>
        <dt>Clone repository</dt>
        <dd>
          <code>git clone https://github.com/Kyoryuu-lab/photo-catalog-relational-analytics.git</code>
        </dd>
        <dd>
          <code>cd photo-catalog-relational-analytics</code>
        </dd>
      </dl>
    </li>
  </b>
  <b>
    <li>
      <dl>
        <dt>Execute automated query runner</dt>
        <dd>Runs entirely on the standard Python runtime without external dependencies:</dd>
        <dd>
          <code>python main.py</code>
        </dd>
      </dl>
    </li>
  </b>
</ol>

<h2>Example of console output (python main.py)</h2>
<samp>
  <p>
    ===========================================================================<br />
    &nbsp;&nbsp;PHOTO CATALOG RELATIONAL ANALYTICS ENGINE<br />
    ===========================================================================<br />
    [*] Initializing in-memory relational SQLite engine...<br />
    [*] Creating 3NF schema and populating Seed Data...<br />
    [+] Database initialized successfully.<br />
    <br />
    ===========================================================================<br />
    &nbsp;&nbsp;QUERY 1: EARLIEST &amp; LATEST DATE FOR MULTI-AUTHOR COLLABORATIONS<br />
    ===========================================================================<br />
    +------------+------------+<br />
    | min_date&nbsp;&nbsp;&nbsp;| max_date&nbsp;&nbsp;&nbsp;|<br />
    +------------+------------+<br />
    | 2009-10-10 | 2022-05-05 |<br />
    +------------+------------+<br />
    <br />
    ===========================================================================<br />
    &nbsp;&nbsp;QUERY 2: POPULAR GENRES PER RELEASE YEAR (GENRE FREQUENCY &gt; 1)<br />
    ===========================================================================<br />
    +------------+-----------+------------+<br />
    | genre_name | cnt_genre | photo_year |<br />
    +------------+-----------+------------+<br />
    | genre2&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;| 2&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;| 2020&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|<br />
    +------------+-----------+------------+<br />
    <br />
    ===========================================================================<br />
    &nbsp;&nbsp;ALL ANALYTICAL QUERIES EXECUTED SUCCESSFULLY.<br />
    ===========================================================================<br />
  </p>
</samp>
