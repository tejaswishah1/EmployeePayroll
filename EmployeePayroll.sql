--creates new database
create database payroll_service;
--gives the names of all the databases
SELECT name FROM sys.databases;
--selects the payroll_service database for use
use payroll_service;
--gives the name of database in use (now payroll_service)
select DB_NAME();

--creates table named employee_payroll in payroll_service database
create table employee_payroll
(
id int identity(1,1),
name varchar(150) not null,
salary money not null,
start date not null
);
--sets id as primary key
ALTER TABLE employee_payroll
ADD CONSTRAINT PK_ID PRIMARY KEY (id);
--gives the info about the table named employee_payroll
select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'employee_payroll';
exec sp_columns employee_payroll; 

--Insert datas in table employee_payroll
insert into employee_payroll values
('Bill',100000.00,'2018-01-03'),
('Terissa',200000.00,'2019-11-13'),
('Charlie',300000.00,'2020-05-21');

--retrives all datas in employee_payroll
select * from employee_payroll;

--to retrieve data of Bill's salary
select salary from employee_payroll where name = 'Bill';
--to retrieve datas of employees in between 2018-01-01 and today
select * from employee_payroll where start between '2018-01-01' and GETDATE();

--adds new column named 'gender'
alter table employee_payroll
add gender char;
--gives the info about the table named employee_payroll
select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'employee_payroll';
--set values of gender for Bill, Terissa and Charlie
update employee_payroll set gender = 'M' where name = 'Bill' or name = 'Charlie';
update employee_payroll set gender = 'F' where name = 'Terissa';
--retrives all datas in employee_payroll
select * from employee_payroll;

--retrives Sum, Average, Minimun, Maximum salaries and count for male and female 
select gender,SUM(salary) as 'Sum of Salaries', AVG(salary) as 'Average Salary', MIN(salary) as 'Minimum Salary', MAX(salary) as 'Maximum Salary', COUNT(gender) as 'Count' from employee_payroll
group by gender;

--adds column named 'phone' 
alter table employee_payroll add phone varchar(15);
--adds not nullable column named 'department' with default value ''
alter table employee_payroll add department varchar(50) not null default('');
--adds column named 'address' with default value 'India'
alter table employee_payroll add address varchar(150) default('India');

--renames salary column to basic_pay
EXEC sp_RENAME 'employee_payroll.salary', 'basic_pay', 'COLUMN';
--adds deductions column
alter table employee_payroll add deductions float;
--adds taxable_pay column
alter table employee_payroll add taxable_pay float;
--adds net_pay column
alter table employee_payroll add net_pay float;
--adds tax column
alter table employee_payroll add tax float;

--inserted terissa once more
insert into employee_payroll 
values('Terissa',200000,'2018-10-13','F',null,'Marketing','Mumbai',12000,1880,120000,12000);
select * from employee_payroll where name = 'Terissa';

--created table company
create table company
(
company_id int identity(1,1) not null primary key,
company_name varchar(150) not null
);
--created table employee
create table employee
(
employee_id int identity(1,1) primary key,
company_id int not null foreign key references company(company_id),
name varchar(150) not null,
gender varchar(1),
phone_no varchar(15),
address varchar(150) not null default('India')
);
--created table department
create table department
(
dept_id int identity(100,1) primary key,
dept_name varchar(50) not null,
);
--created table employee_department for many to many relationship
create table employee_department
(
employee_id int not null foreign key references employee(employee_id),
dept_id int not null foreign key references department(dept_id) 
);
--created table payroll. Here taxable_pay and net_pay are derived attributes
create table payroll
(
employee_id int not null foreign key references employee(employee_id),
Start date not null,
basic_pay money not null,
deduction money,
taxable_pay as basic_pay-deduction,
income_tax money,
net_pay as basic_pay-(income_tax+deduction)
);
--described all tables
exec sp_columns company;
exec sp_columns employee;
exec sp_columns department; 
exec sp_columns employee_department;
exec sp_columns payroll; 
--inserted values in company table
insert into company values
('Company1'),
('Company2'),
('Company3');
--inserted values in employee table
insert into employee values
(1,'Bill','M','9999999999','Nagar colony'),
(1,'Terissa', 'F', '8888888888',default),
(1,'Charlie', 'M', '8888888888', 'Dalal Street'),
(2,'Clinton','M','4545454545','Andheri road');
--inserted values in department table
insert into department values
('Marketing'),
('Sales'),
('Engineering'),
('HR');
--inserted values in employee_department table
insert into employee_department values
(1,100),
(2,100),
(2,101),
(3,103),
(4,102);
--inserted values in payroll table. Only employee_id,start_date,basic_pay,deductions,income_tax inserted. Others are derived
insert into payroll values
(1,'01-20-1998',200000,12000,10000),
(2,'12-06-1995',300000,15000,20000),
(3,'11-02-2020',100000,5000,2000),
(4,'10-01-2020',30000,2000,0);

--for viewing inserted values
select * from company;
select * from employee;
select * from department;
select * from employee_department;
select * from payroll;
--retrives data for all employee
select e.employee_id,name,c.company_id,company_name,d.dept_id,d.dept_name,gender,phone_no,address,start,basic_pay,deduction,taxable_pay,income_tax,net_pay 
from company c 
inner join employee e on c.company_id=e.company_id 
inner join employee_department ed on ed.employee_id = e.employee_id
inner join department d on d.dept_id= ed.dept_id
inner join payroll p on p.employee_id = e.employee_id;
--retrives data for any employee
select e.employee_id,name,c.company_id,company_name,d.dept_id,d.dept_name,gender,phone_no,address,start,basic_pay,deduction,taxable_pay,income_tax,net_pay 
from company c 
inner join employee e on c.company_id=e.company_id 
inner join employee_department ed on ed.employee_id = e.employee_id
inner join department d on d.dept_id= ed.dept_id
inner join payroll p on p.employee_id = e.employee_id
where name = 'Bill';
--retrives employees that started in between 2018-01-01 and today 
select e.employee_id,name,c.company_id,company_name,d.dept_id,d.dept_name,gender,phone_no,address,start,basic_pay,deduction,taxable_pay,income_tax,net_pay 
from company c 
inner join employee e on c.company_id=e.company_id 
inner join employee_department ed on ed.employee_id = e.employee_id
inner join department d on d.dept_id= ed.dept_id
inner join payroll p on p.employee_id = e.employee_id
where start between '2018-01-01' and GETDATE();
--use of aggregates functions  
select gender,sum(basic_pay) as 'Sum', avg(basic_pay) as 'Average', min(basic_pay) as 'Min' , max(basic_pay) as 'Max', count(basic_pay) as 'Count' 
from employee e
inner join payroll p on p.employee_id = e.employee_id
group by gender;