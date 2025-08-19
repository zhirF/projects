-- testing if the tables work with the queries and ordering them by Location & Date
select * 
from death
order by 3,4

select * 
from vaccination 
order by 3,4

-- preparing for our first query which is total cases first total deaths
select 
location,date,total_cases,new_cases,total_deaths,population, (total_deaths/total_cases)*100 as Death_Percentage 
from death 
order by 1,2

-- preparing for our first query which is total cases first total deaths IN IRAQ
select 
location,date,total_cases,new_cases,total_deaths,population, (total_deaths/total_cases)*100 as Death_Percentage 
from death 
where location like 'Iraq' 
order by 1,2
--according to the data, after 2020 the death percentage stayed on %1


-- showing total cases accourding to Population
select 
location,date,total_cases,population, (total_cases/population)*100 as Infected_Percentage 
from death 
order by 1,2

-- this will show us that until 2023, nearly 5% of Iraqis got infected by covid. this shows us in a country like Iraq, the recorded data is poor. lets run the same query for more developed country like Austria and see the result
select 
location,date,total_cases,population, (total_cases/population)*100 as Infected_Percentage 
from death where location like 'Austria' 
order by 1,2
-- in 2023 the percentage became %64. this shows the difference between the accuracy of recorded cases between Iraq and Austria 


--the bellow query shows us infected percentage of each country
select 
Location,Population, max(total_cases) as Highest_infection_count, max((total_cases/Population))*100 as infected_percentage 
from death 
group by location,population 
order by 1,2

--showing countries with highest death count
-- and i will be adding (where continent is not null) to only keep the countries
select 
Location, max(cast(total_deaths as int)) as Total_death_count 
from death 
where continent is not null group by location,population 
order by 1,2

--finding the death count for each continent
select 
Location, max(cast(total_deaths as int)) as Total_death_count 
from death 
where continent is null 
group by location,population 
order by Total_death_count desc


--global numbers

--total death across the world
select 
sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as deaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as death_percentage 
from death 
where continent is not null 
order by 1,2


--this will show the death count grouped by date
select 
date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as deaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as death_percentage 
from death where continent is not null 
group by date 
order by 1,2


--join

--what is the total people in the global level who got vaccinated?
Select
death.continent, death.location, death.date, death.population, vaccination.new_vaccinations
,SUM(CONVERT(bigint,vaccination.new_vaccinations)) OVER (Partition by death.Location Order by death.location, death.Date) as RollingPeopleVaccinated
From death
Join vaccination
On death.location = vaccination.location
and death.date = vaccination.date
where death.continent is not null 
order by 2,3


-- using cte for virtual table 
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select death.continent, death.location, death.date, death.population, vaccination.new_vaccinations
, SUM(CONVERT(bigint,vaccination.new_vaccinations)) OVER (Partition by death.Location Order by death.location, death.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From death
Join vaccination
	On death.location = vaccination.location
	and death.date = vaccination.date
where death.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


 -- temporarly table
 DROP Table if exists #PercentVaccinated
Create Table #PercentVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
 Select death.continent, death.location, death.date, death.population, vaccination.new_vaccinations
, SUM(CONVERT(bigint,vaccination.new_vaccinations)) OVER (Partition by death.Location Order by death.location, death.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From death
Join vaccination
	On death.location = vaccination.location
	and death.date = vaccination.date

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentVaccinated


--creating view 
create view  Percentage_vaccinated as
Select death.continent, death.location, death.date, death.population, vaccination.new_vaccinations
, SUM(CONVERT(bigint,vaccination.new_vaccinations)) OVER (Partition by death.Location Order by death.location, death.Date) as RollingPeopleVaccinated
From death
Join vaccination
	On death.location = vaccination.location
	and death.date = vaccination.date
where death.continent is not null 
--order by 2,3


--showing the result of the view
select * from Percentage_vaccinated