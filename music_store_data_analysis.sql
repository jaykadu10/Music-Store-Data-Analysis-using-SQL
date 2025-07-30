create database  if not exists music_store_data_analysis;
use music_store_data_analysis;

-- 1. Genre and MediaType
CREATE TABLE Genre (
	genre_id INT PRIMARY KEY,
	name VARCHAR(120)
);

CREATE TABLE MediaType (
	media_type_id INT PRIMARY KEY,
	name VARCHAR(120)
);

-- 2. Employee

CREATE TABLE Employee (
	employee_id INT PRIMARY KEY,
	last_name VARCHAR(120),
	first_name VARCHAR(120),
	title VARCHAR(120),
	reports_to INT,
  levels VARCHAR(255),
	birthdate DATE,
	hire_date DATE,
	address VARCHAR(255),
	city VARCHAR(100),
	state VARCHAR(100),
	country VARCHAR(100),
	postal_code VARCHAR(20),
	phone VARCHAR(50),
	fax VARCHAR(50),
	email VARCHAR(100)
);

-- 3. Customer
CREATE TABLE Customer (
	customer_id INT PRIMARY KEY,
	first_name VARCHAR(120),
	last_name VARCHAR(120),
	company VARCHAR(120),
	address VARCHAR(255),
	city VARCHAR(100),
	state VARCHAR(100),
	country VARCHAR(100),
	postal_code VARCHAR(20),
	phone VARCHAR(50),
	fax VARCHAR(50),
	email VARCHAR(100),
	support_rep_id INT,
	FOREIGN KEY (support_rep_id) REFERENCES Employee(employee_id)
);

-- 4. Artist
CREATE TABLE Artist (
	artist_id INT PRIMARY KEY,
	name VARCHAR(120)
);

-- 5. Album
CREATE TABLE Album (
	album_id INT PRIMARY KEY,
	title VARCHAR(160),
	artist_id INT,
	FOREIGN KEY (artist_id) REFERENCES Artist(artist_id)
);

-- 6. Track
CREATE TABLE Track (
	track_id INT PRIMARY KEY,
	name VARCHAR(200),
	album_id INT,
	media_type_id INT,
	genre_id INT,
	composer VARCHAR(220),
	milliseconds INT,
	bytes INT,
	unit_price DECIMAL(10,2),
	FOREIGN KEY (album_id) REFERENCES Album(album_id),
	FOREIGN KEY (media_type_id) REFERENCES MediaType(media_type_id),
	FOREIGN KEY (genre_id) REFERENCES Genre(genre_id)
);

-- 7. Invoice
CREATE TABLE Invoice (
	invoice_id INT PRIMARY KEY,
	customer_id INT,
	invoice_date DATE,
	billing_address VARCHAR(255),
	billing_city VARCHAR(100),
	billing_state VARCHAR(100),
	billing_country VARCHAR(100),
	billing_postal_code VARCHAR(20),
	total DECIMAL(10,2),
	FOREIGN KEY (customer_id) REFERENCES Customer(customer_id)
);

-- 8. InvoiceLine
CREATE TABLE InvoiceLine (
	invoice_line_id INT PRIMARY KEY,
	invoice_id INT,
	track_id INT,
	unit_price DECIMAL(10,2),
	quantity INT,
	FOREIGN KEY (invoice_id) REFERENCES Invoice(invoice_id),
	FOREIGN KEY (track_id) REFERENCES Track(track_id)
);

-- 9. Playlist
CREATE TABLE Playlist (
 	playlist_id INT PRIMARY KEY,
	name VARCHAR(255)
);

-- 10. PlaylistTrack
CREATE TABLE PlaylistTrack (
	playlist_id INT,
	track_id INT,
	PRIMARY KEY (playlist_id, track_id),
	FOREIGN KEY (playlist_id) REFERENCES Playlist(playlist_id),
	FOREIGN KEY (track_id) REFERENCES Track(track_id)
);



SHOW VARIABLES LIKE 'secure_file_priv';

LOAD DATA INFILE  'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/track.csv'
INTO TABLE  track
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(track_id, name, album_id, media_type_id, genre_id, composer, milliseconds, bytes, unit_price);

-- tables 
select * from genre ;
select * from mediatype;
select * from employee;
select * from customer;
select * from artist;
select * from album;
select * from track ;
select * from invoice;
select * from invoiceline;
select * from playlist;
select * from playlisttrack;

-- adding the missing rows from employee table 

INSERT INTO employee (
  employee_id, last_name, first_name, title, `levels`, birthdate, hire_date,
  address, city, state, country, postal_code, phone, fax, email
)
VALUES (
  9, 'Madan', 'Mohan', 'Senior General Manager', 'L7', '1961-01-26', '2016-01-14',
  '1008 Vrinda Ave MT', 'Edmonton', 'AB', 'Canada', 'T5K 2N1',
  '+1 (780) 428-9482', '+1 (780) 428-3457', 'madan.mohan@chinookcorp.com'
);


-- 1. Who is the senior most employee based on job title? 

select first_name ,last_name ,title ,levels from employee 
order by levels desc
limit 1 ;

-- 2. Which countries have the most Invoices?

select billing_country as country_name, count(*) no_of_invoices from invoice
group by billing_country 
order by no_of_invoices desc;

-- 3. What are the top 3 values of total invoice?

select * from
(select * ,dense_rank() over(order by total desc) as ranks from invoice) as p
where ranks < 4;

/* 4. Which city has the best customers? 
  - We would like to throw a promotional Music Festival in the city we made the most money.
  Write a query that returns one city that has the highest sum of invoice totals. 
  Return both the city name & sum of all invoice totals */
  
  
  select billing_city, sum(total) as total_sum from invoice 
  group by billing_city
  order by total_sum desc
  limit 1 ;
  
  /* 5. Who is the best customer? 
- The customer who has spent the most money will be declared the best customer. 
   Write a query that returns the person who has spent the most money */
  
select customer.first_name ,customer.last_name,customer.customer_id ,sum(invoice.total) as total_spend
from customer join invoice
on customer.customer_id = invoice.customer_id 
group by invoice.customer_id 
order by total_spend desc
limit 1 ;

/* 6. Write a query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A */

select 
distinct email ,customer.first_name , customer.last_name , genre.name from customer 
join invoice on customer.customer_id = invoice.customer_id
join invoiceline on invoice.invoice_id = invoiceline.invoice_id
join track on invoiceline.track_id = track.track_id
join genre on track.genre_id = genre.genre_id
where genre.name ='rock'
order by email ;

/* 7. Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands  */

select artist.name,count(track.track_id) as track_count from artist
join  album on artist.artist_id = album.artist_id 
join track on album.album_id = track.album_id 
where track.genre_id = 1
group by artist.name
order by track_count desc
limit 10 ;


/* 8. Return all the track names that have a song length longer than the average song length.
- Return the Name and Milliseconds for each track. Order by the song length, with the longest songs listed first */


select name ,milliseconds from track 
where milliseconds > (select avg(milliseconds) as avg_of_milliseconds from track)
order by milliseconds desc;


/* 9. Find how much amount is spent by each customer on artists?
 Write a query to return customer name, artist name and total spent */
 
 select invoice.customer_id,customer.first_name,customer.last_name,artist.name as artist_name ,sum(track.unit_price) as total_spend from customer
 join invoice on customer.customer_id=invoice.customer_id
 join invoiceline on invoiceline.invoice_id = invoice.invoice_id
 join track on invoiceline.track_id=track.track_id
 join album on album.album_id=track.album_id
 join artist on album.artist_id =artist.artist_id
 group by invoice.customer_id,artist.name
 order by total_spend desc;


/* 10. We want to find out the most popular music Genre for each country. 
We determine the most popular genre as the genre with the highest amount of purchases.
Write a query that returns each country along with the top Genre. 
For countries where the maximum number of purchases is shared, return all Genres */






/* 11. Write a query that determines the customer that has spent the most on music for each country.
 Write a query that returns the country along with the top customer and how much they spent. 
 For countries where the top amount spent is shared, provide all customers who spent this amount */
 
 
SELECT 
    *
FROM (
    SELECT c.first_name,c.last_name,c.country,SUM(i.total) AS spent_amount,
        RANK() OVER (PARTITION BY c.country ORDER BY SUM(i.total) DESC) AS rnk
    FROM customer c
    JOIN invoice i ON c.customer_id = i.customer_id
    GROUP BY c.country, c.customer_id, c.first_name, c.last_name
) AS ranked
WHERE rnk = 1
ORDER BY spent_amount desc;


 


