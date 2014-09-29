EII
==
EII is an sqlite wrapper that turns basic sql queries into bash arguments.

Usage
--
Select
```sql
SELECT id,name FROM master WHERE author like '%hideaki%'
```
```sh
eii -s -t master -c id name -f author -v hideaki
```

Multiple table support
```sql
SELECT id FROM titles WHERE id = '2'
SELECT id FROM authors WHERE id = '2'
SELECT id FROM books WHERE id = '2'
```
```sh
eii -s -t titles authors books -f id -v 2
```

Insert
```sql
INSERT INTO master (id,name,age,date) VALUES (45, 'hideaki', 54, '20090101')
```
```sh
eii -i -t master -v 45 'hideaki' 54 '20090101'
```

Update
```sql
UPDATE master SET town = 'ube' WHERE name = 'hideaki'
```
```sh
eii -u -x -t master -c town -f name -v 'hideaki' -n 'ube'
```

Delete
```sql
DELETE FROM master WHERE name = 'hideaki'
DELETE FROM books WHERE author = 'hideaki'
DELETE FROM author WHERE name = 'hideaki'
```
```sh
#if DB contains only 3 tables: master,books,author
eii -d -x -f name author -v 'hideaki'
#otherwise
eii -d -x -t master books author -f name author -v 'hideaki'
```
