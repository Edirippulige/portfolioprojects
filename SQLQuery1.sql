select * from coviddeths

select total_cases, total_deaths,(total_deaths/total_cases) from coviddeths

Alter table coviddeths
Alter column total_deaths float

Alter table coviddeths
Alter column total_cases float


--looking the total cases vs Total deaths
--shows liklihood of dying if you contract covid in your country

select Location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as Deathpercentage from coviddeths
where Location like '%Canada'	
order by 1,2

--Looking at the total cases vs population
--Shows what percentage of population got covid

select Location,date,population,total_cases,(total_cases/population)*100 as Deathpercentage from coviddeths
where Location like '%Canada'	
order by 1,2

--Looking at the highest infection rate compared to population

select Location,population,MAX(total_cases) as HighestInfectioncount,Max((total_cases/population))*100 as percentpopulationinfected from coviddeths
--where Location like '%Canada'	
group by Location,population
order by percentpopulationinfected desc

--Showing countries with Hiest Death count per population 


	select Location,MAX(total_deaths) as Totaldeathcount from coviddeths
	--where Location like '%Canada'	
	where continent is not null
	group by Location 
	order by Totaldeathcount desc

-- Breaking down by continent  


select Location,MAX(cast(total_deaths as int)) as Totaldeathcount from coviddeths
	--where Location like '%Canada'	
	where continent is null
	group by location 
	order by Totaldeathcount desc


	
--Showing the continent with the hiest deathcount per population

select continent,MAX(cast(total_deaths as int)) as Totaldeathcount from coviddeths
	--where Location like '%Canada'	
	where continent is not null
	group by continent 
	order by Totaldeathcount desc


--Global numbers

	select date,SUM(cast(new_cases as int)) as totalnew_cases ,SUM(cast(new_deaths as int)) as total_deaths
	from coviddeths
	--where Location like '%Canada'	
	where continent is not null
	and new_cases is not null
	and new_deaths is not null
	group by date
	order by 1,2

--Looking at Total population vs vaccination

select dea.continent,dea.location, dea.date, dea.population ,vac.new_vaccinations from  coviddeths dea join vaccination vac on 
dea.location =vac.location
and dea.date =vac.date
order by 1,2

select dea.continent,dea.location, dea.date, dea.population ,vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location,dea.date ) as Rollingpeoplevaccinated
from  coviddeths dea join vaccination vac on 
dea.location =vac.location
and dea.date =vac.date 
order by 1,2

--use CTE

with popvsvacc (continent,location,date,population,new_vaccinations,Rollingpeoplevaccinated)
as
(
select dea.continent,dea.location, dea.date, dea.population ,vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location,dea.date ) as Rollingpeoplevaccinated
from  coviddeths dea join vaccination vac on 
dea.location =vac.location
and dea.date =vac.date 
--order by 1,2	
)

select *, (Rollingpeoplevaccinated/population) *100 as vaccinedensity

from popvsvacc 

--TEMP TABLE

drop table if exists #percentpopulationvaccinated 

create table #percentpopulationvaccinated
(
 continent nvarchar(255),
 location nvarchar(255),
 Date datetime,
 population numeric,
 new_vaccinations numeric,
 Rollingpeoplevaccinated numeric
 )

insert into  #percentpopulationvaccinated
select dea.continent,dea.location, dea.date, dea.population ,vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location,dea.date ) as Rollingpeoplevaccinated
from  coviddeths dea join vaccination vac on 
dea.location =vac.location
and dea.date =vac.date 
--order by 1,2	

select *, (Rollingpeoplevaccinated/population) *100 from #percentpopulationvaccinated

--creating views for data visualization later

create view percentpopulationvaccinated
as
select dea.continent,dea.location, dea.date, dea.population ,vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location,dea.date ) as Rollingpeoplevaccinated
from  coviddeths dea join vaccination vac on 
dea.location =vac.location
and dea.date =vac.date 
--order by 1,2	

select * from percentpopulationvaccinated