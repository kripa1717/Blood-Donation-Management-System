create database blooddonation;

create table donor(
donor_id int primary key,
name varchar(50),
age int,
blood_group varchar(25),
contact varchar(10),
last_donation_date int,
);
alter table donor
drop column last_donation_date;

alter table donor
add last_donation_date DATE;

create table blood_bank(
bank_id int primary key,
bank_name varchar(50),
location varchar(100),
contact varchar(10),
);

create table blood(
blood_id int primary key,
donor_id int,
bank_id int,
blood_group varchar(25),
quantity_in_ml int,
donation_date date,
foreign key (donor_id) references donor(donor_id),
foreign key (bank_id) references blood_bank(bank_id),
);

create table patient(
patient_id int primary key,
name varchar(50),
blood_group varchar(25),
hospital_name varchar(50),
contact varchar(10),
);

create table request(
request_id int primary key,
patient_id int,
bank_id int,
requested_blood_group varchar(25),
quantity_in_ml int,
request_date date,
status varchar(15),
foreign key (bank_id) references blood_bank(bank_id),
foreign key (patient_id) references patient(patient_id),
);

INSERT INTO donor (donor_id,name, age, blood_group, contact, last_donation_date)
VALUES 
(1,'Kripa Shrestha', 20, 'O+', '9800000000', '2026-01-10'),
(2,'Shreeti Shrestha', 28, 'B+', '9800000001', '2025-12-20'),
(3,'Rujana Dangol', 30, 'O+', '9800000002', '2026-02-01'),
(4,'Anil Gurung', 35, 'AB+', '9800000003', '2026-01-25'),
(5,'Mina Rai', 25, 'A-', '9800000004', '2025-11-30');

INSERT INTO blood_bank (bank_id,bank_name, location, contact)
VALUES
(1,'Kathmandu Blood Bank', 'Kathmandu', '9810000001'),
(2,'Patan Blood Bank', 'Lalitpur', '9810000002'),
(3,'Bhaktapur Blood Bank', 'Bhaktapur', '9810000003'),
(4,'Red-Cross Blood Bank','Kathmandu','9810000004'),
(5,'Hamro-Life Blood Bank','Lalitpur','9810000005');


INSERT INTO blood (blood_id,donor_id, bank_id, blood_group, quantity_in_ml, donation_date)
VALUES
(1,1, 1, 'A+', 450, '2026-01-10'),
(2,2, 2, 'B+', 500, '2025-12-20'),
(3,3, 1, 'O+', 350, '2026-02-01'),
(4,4, 3, 'AB+', 400, '2026-01-25'),
(5,5, 2, 'A-', 450, '2025-11-30');


INSERT INTO patient (patient_id,name, blood_group, hospital_name, contact)
VALUES
(1,'Hari Shrestha', 'A+', 'Norvic Hospital', '9801000001'),
(2,'Suman Koirala', 'O+', 'Patan Hospital', '9801000002'),
(3,'Gita Tamang', 'B+', 'KMC Hospital', '9801000003'),
(4,'Anita Rai', 'AB+', 'Grande Hospital', '9801000004'),
(5,'Bikash Lama', 'A-', 'Civil Hospital', '9801000005');


INSERT INTO request (request_id,patient_id, bank_id, requested_blood_group, quantity_in_ml, request_date, status)
VALUES
(1,1, 1, 'A+', 450, '2026-02-15', 'Pending'),
(2,2, 2, 'O+', 350, '2026-02-16', 'Approved'),
(3,3, 3, 'B+', 400, '2026-02-17', 'Rejected'),
(4,4, 1, 'AB+', 400, '2026-02-18', 'Pending'),
(5,5, 2, 'A-', 450, '2026-02-19', 'Approved');

select * from donor;
select * from blood_bank;
select * from blood;
select * from patient;
select * from request;

select d.name as donor_name,b.quantity_in_ml ,bb.bank_name,b.blood_group
from blood as b
join donor as d
on b.donor_id=d.donor_id
join blood_bank as bb
on b.bank_id=bb.bank_id;

select p.name as patient_name,p.hospital_name, r.requested_blood_group,r.status
from patient as p
left join request as r
on p.patient_id=r.patient_id;

select bb.bank_name, r.requested_blood_group,p.name as patient_name, r.quantity_in_ml 
from blood_bank as bb
right join request as r
on bb.bank_id = r.bank_id
left join patient as p
on r.patient_id = p.patient_id;

select d.blood_group,count(d.blood_group) as total
from donor as d
group by d.blood_group;

select bb.bank_name,sum(b.quantity_in_ml) as total
from blood as b
join blood_bank as bb
on b.bank_id=bb.bank_id
group by bb.bank_name;

select bb.bank_name,avg(b.quantity_in_ml) as average
from blood as b
join blood_bank as bb
on b.bank_id=bb.bank_id
group by bb.bank_name;

select top 1 d.name
from donor as d
join blood as b
on b.donor_id=d.donor_id
group by d.name
order by avg(b.quantity_in_ml) desc;

select  d.name,sum(b.quantity_in_ml) as toal_donated
from donor as d
join blood as b
on b.donor_id=d.donor_id
group by d.name
having avg(b.quantity_in_ml)>(select avg(quantity_in_ml) from blood );

create view bloodstock as
select bb.bank_name,b.blood_group,sum(b.quantity_in_ml) as total_quantity
from blood as b
join blood_bank as bb
   on b.bank_id = bb.bank_id
group by bb.bank_name, b.blood_group;

select *from bloodstock;

select bb.bank_name
from blood_bank as bb
left join blood as b
   on bb.bank_id = b.bank_id
where b.blood_group is null or b.blood_group <> 'o+';

select p.name as patient_name, r.requested_blood_group,r.status
from patient as p
join request as r
   on p.patient_id = r.patient_id
where r.status <> 'approved';

select name, last_donation_date
from donor
order by last_donation_date desc;


select d.name,sum(b.quantity_in_ml) as total_donated
from donor as d
join blood as b
   on d.donor_id = b.donor_id
group by d.name
order by total_donated desc;

select bb.bank_name,count(r.request_id) as total_requests
from blood_bank as bb
left join request as r
on bb.bank_id = r.bank_id
group by bb.bank_name;



--Transaction

begin transaction;

declare @bank_id int = 1;
declare @blood_group varchar(5) = 'a+';
declare @quantity_needed int = 450;
declare @request_id int = 1;

declare @available int;

-- check available quantity in the blood bank
select @available = sum(quantity_in_ml)
from blood
where bank_id = @bank_id
  and blood_group = @blood_group;

if @available >= @quantity_needed
begin
    -- deduct blood from the blood table
    update blood
    set quantity_in_ml = quantity_in_ml - @quantity_needed
    where bank_id = @bank_id
      and blood_group = @blood_group
      and quantity_in_ml >= @quantity_needed;

    -- update request status to approved
    update request
    set status = 'approved'
    where request_id = @request_id;

    commit transaction;
    print 'transaction committed: request approved';
end
else
begin
    rollback transaction;
    print 'transaction rolled back: not enough blood available';
end


-- check request status
select * from request where request_id = 1;

-- check blood quantity in that bank
select * from blood where bank_id = 1 and blood_group = 'a+';



begin transaction;

declare @bank_id int = 2;
declare @blood_group varchar(5) = 'o+';
declare @quantity_needed int = 1000;
declare @request_id int = 1;

declare @available int;

-- check available quantity in the blood bank
select @available = sum(quantity_in_ml)
from blood
where bank_id = @bank_id
  and blood_group = @blood_group;

if @available >= @quantity_needed
begin
    -- deduct blood from the blood table
    update blood
    set quantity_in_ml = quantity_in_ml - @quantity_needed
    where bank_id = @bank_id
      and blood_group = @blood_group
      and quantity_in_ml >= @quantity_needed;

    -- update request status to approved
    update request
    set status = 'approved'
    where request_id = @request_id;

    commit transaction;
    print 'transaction committed: request approved';
end
else
begin
    rollback transaction;
    print 'transaction rolled back: not enough blood available';
end