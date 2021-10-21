create database RicetteNonna

create table Ingrediente(
CodiceIngrediente int not null identity(1,1),
Nome nvarchar(30) not null,
Descrizione nvarchar(50) ,
UnitaMisura nvarchar (10) ,

constraint PK_INGREDIENTE primary key(CodiceIngrediente),
constraint CHK_unitamisura check (unitamisura = 'ml' or unitamisura = 'g'),

);




create table Libro(
CodiceLibro int not null identity(1,1) constraint PK_LIBRO primary key,
Titolo  nvarchar(20) not null,
Tipologia nvarchar (30),

);

create table Ricetta(
CodiceRicetta int not null identity(1,1) constraint PK_RICETTA primary key,
Nome nvarchar(50) not null,
PersoneServite int not null check (personeservite >0),
TempoPrep int not null check (tempoprep >0),
Preparazione nvarchar(1000) not null,
CodiceLibro int not null constraint FK_LIBRO foreign key references Libro(CodiceLibro),
);


create table RicettaIngrediente(
Quantita int not null,
CodiceIngrediente int not null constraint FK_INGREDIENTE foreign key references Ingrediente(CodiceIngrediente),
CodiceRicetta int not null constraint FK_RICETTA foreign key references Ricetta(CodiceRicetta),
constraint PK_RICETTA_INGREDIENTE primary key(CodiceIngrediente, CodiceRicetta)
);

select * from ricetta;
select * from libro;
select * from ricettaingrediente
select * from Ingrediente;


insert into Ingrediente values ( 'uova', 'temperatura ambiente', null);
insert into Ingrediente values ('farina', 'macinata a pietra', 'g'), ( 'latte', null, 'ml');
insert into Ingrediente values ( 'pangrattato',null, 'g')
insert into Ingrediente values ( 'carne',null, 'g')



insert into Libro values ('volume 3', 'dolci');
insert into Libro values ('volume 2', 'secondi');
insert into Libro values ('volume 1', 'primi');


insert into ricetta values ('crepes base', 4, 60, 'misurare il latte, unire uova e farina setacciata, mescolare e far riposare almeno mezz''ora', 1);
insert into ricetta values ('tiramisu', 4, 80, 'preparare caffè, poi iniziare montando i tuorli con lo zucchero...', 1);
insert into ricetta values ('budino', 4, 90, 'iniziare col fondere il burro, incorporare lo zucchero etc etc', 1);
insert into ricetta values ('crema', 8, 80, 'iniziare ricavando scorza limone...', 1);
insert into ricetta values ('polpette', 4, 90, 'prendere il macinato...', 2);



insert into ricettaingrediente values (3 , 1, 1), (250, 2, 1), (500, 3, 1)
insert into ricettaingrediente values (2 , 1, 3)
insert into ricettaingrediente values (6 , 1, 6)
insert into ricettaingrediente values (500 , 5, 7)
insert into ricettaingrediente values (1 , 1, 7)




--Esercitazione Ricette Nonna
--1.Visualizzare tutta la lista degli ingredienti distinti.
select distinct *
from ingrediente

--2.Visualizzare tutta la lista degli ingredienti distinti utilizzati in almeno una ricetta.
select distinct i.*
from ingrediente i join ricettaingrediente ri on i.CodiceIngrediente = ri.CodiceIngrediente

--3.Estrarre tutte le ricette che contengono l’ingrediente uova.
select r.*
from ricetta r join ricettaingrediente ri on r.codicericetta = ri.codicericetta
where ri.CodiceIngrediente = 1

--4.Mostrare il titolo delle ricette che contengono almeno 4 uova
select r.*
from ricetta r join ricettaingrediente ri on r.codicericetta = ri.codicericetta
where ri.codiceingrediente = 1 and ri.quantita > 3 

--5.Estrarre tutte le ricette dei libri di Tipologia=Secondi per 4 persone contenenti l’ingrediente carne
select r.*
from ricetta r join libro l on r.CodiceLibro = l.CodiceLibro
				join ricettaingrediente ri on r.CodiceRicetta = ri.CodiceRicetta	
				join ingrediente i on i.CodiceIngrediente = ri.CodiceIngrediente
where r.PersoneServite = 4 and l.tipologia = 'secondi' and i.nome = 'carne'

--6.Mostrare tutte le ricette che hanno un tempo di preparazione inferiore a 10 minuti.
select *
from ricetta r
where r.TempoPrep < 10

--7.Mostrare il titolo del libro che contiene più ricette

--per ora mostra il codice del libro
select nuovatab.*
from (select r.codicelibro, count(r.codicelibro) as ricetteperlibro from ricetta r group by r.CodiceLibro) as nuovatab
where ricetteperlibro = (select max(ricetteperlibro) from (select r.codicelibro, count(r.codicelibro) as ricetteperlibro from ricetta r group by r.CodiceLibro) as nuovatab)


select r.codicelibro, count(r.codicelibro) as ricetteperlibro
from ricetta r 
group by r.CodiceLibro 


--create NUOVA VISTA: per ricopiare meno nelle subquery
create view nuovatab(codiceLibro, ricettePerLibro) 
as (select r.codicelibro, count(r.codicelibro) as ricetteperlibro from ricetta r group by r.CodiceLibro)

select *
from nuovatab
where ricetteperlibro =(select max(ricetteperlibro) from nuovatab)

--far mostrare il titolo: subquery e query complessiva
select l.Tipologia as titololibro, count(l.tipologia) as ricetteperlibro
from ricetta r join libro l on r.codicelibro=l.codicelibro
group by l.Tipologia 

select *
from (select l.Tipologia as titololibro, count(l.tipologia) as ricetteperlibro
		from ricetta r join libro l on r.codicelibro=l.codicelibro
		group by l.Tipologia) 
									as libripernumeroricette
where ricetteperlibro = (select max(ricetteperlibro) 
						 from 
							   (select l.Tipologia as titololibro, count(l.tipologia) as ricetteperlibro
								from ricetta r join libro l on r.codicelibro=l.codicelibro
								group by l.Tipologia)
											as libripernumeroricette)


--8.Visualizzare i Titoli dei libri ordinati rispetto al numero di ricette che contengono (il libro che contiene più ricette deve essere visualizzato per primo, quello con meno ricette per ultimo) e, a parità di numero ricette in ordine alfabetico su Titolo del libro.

select l.titolo, count(r.codicelibro) as ricetteperlibro
from libro l join ricetta r on l.codicelibro = r.codicelibro
group by l.titolo
order by ricetteperlibro desc, l.titolo