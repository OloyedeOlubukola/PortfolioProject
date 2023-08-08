Select *
  From [Project Portfolio].dbo.CovidDeaths
  where continent is not null
  Order by 3,4 


Select *
  From [Project Portfolio].dbo.CovidVaccinations
   where continent is not null
  Order by 3,4 

 
  Select Location, date, total_cases, new_cases, total_deaths, population
  from [Project Portfolio].dbo.CovidDeaths
   where continent is not null
  order by 1,2

   --TOTAL CASES VS TOTAL DEATH
    --Shows likelihood of dying if contracted covid China 

    Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
    from [Project Portfolio].dbo.CovidDeaths
     where location like '%Nigeria%'
	   order by 1,2 
	


     --TOTAL CASES VS POPULATION IN NIGERIA
	 -- Shows percentage of the population that contracted Covid 

   Select Location, date, population, total_cases, (total_cases/population)*100 as InfectedPopulationPercentage 
   from [Project Portfolio].dbo.CovidDeaths
    where location like '%Nigeria%'
	order by 1,2 

     
	--COUNTRIES WITH THE HIGHEST INFECTION RATE COMPARED TO POPULATION
	   
    Select Location, population, MAX(total_cases) as HighestInfectionCount,  MAX((total_cases/population))*100 as InfectedPopulationPercentage 
    from [Project Portfolio].dbo.CovidDeaths
     Group by Location, population
	 order by InfectedPopulationPercentage desc


	 --COUNTRIES WITH THE HIGHEST DEATH COUNT PER POPULATION

	 Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
     from [Project Portfolio].dbo.CovidDeaths
	  where continent is not null
     Group by Location 
     order by TotalDeathCount desc


       --CCONTINENT WITH HIGHEST DEATH COUNT PER POPULATION 

	Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
     from [Project Portfolio].dbo.CovidDeaths
	  where continent is not null
     Group by continent 
     order by TotalDeathCount desc

	 -- GLOBAL CASES DAILY 

    Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/
   SUM(new_cases)*100 as DeathPercentage
    from [Project Portfolio].dbo.CovidDeaths
	Where continent is not null
	Group by date
	   order by 1,2 
	
       --TOTAL GLOBAL CASES & DEATHS

   SelecT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/
   SUM(new_cases)*100 as DeathPercentage
    from [Project Portfolio].dbo.CovidDeaths
	Where continent is not null
	--Group by date
	   order by 1,2 


	   --CUMULATIVE SUM OF NEW VACCINATIONS

Select dea.continent, dea.location, dea.population, dea.date, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as INT)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
From [Project Portfolio]..CovidDeaths dea
Join [Project Portfolio]..CovidVaccinations vac
    On dea.location = vac.location
	and dea.date = vac.date
	Where dea.continent is not null
	Order by 2,3 


	--USE CTE
	With Popvsvac (Continent, location, date, population, New_Vaccinatons, RollingPeopleVaccinated)
	as
	(
	Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as INT)) OVER (Partition by dea.Location Order by dea.location,
dea.date) as RollingPeopleVaccinated
From [Project Portfolio]..CovidDeaths dea
Join [Project Portfolio]..CovidVaccinations vac
    On dea.location = vac.location
	and dea.date = vac.date
	Where dea.continent is not null
	) 
	select * ,(RollingPeopleVaccinated/population)*100
	From PopVsVac	
	

	--TEMP TABLE 

   DROP Table if exists #PercentPopulationVaccinated
    Create Table #PercentPopulationVaccinated
     (
     Continent nvarchar (255),
     Location nvarchar (255),
     Date datetime,
     Population numeric,
     New_vaccinations numeric,
     RollingPeopleVaccinated numeric 
      )

	Insert into #PercentPopulationVaccinated
	Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as INT)) OVER (Partition by dea.Location Order by dea.location,
dea.date) as RollingPeopleVaccinated
From [Project Portfolio]..CovidDeaths dea
Join [Project Portfolio]..CovidVaccinations vac
    On dea.location = vac.location
	and dea.date = vac.date

	
	select * ,(RollingPeopleVaccinated/population)*100
	From #PercentPopulationVaccinated	



	--VISUALIZATION VIEW
	
	Create view PercentPopulationVaccinated as

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as INT)) OVER (Partition by dea.Location Order by dea.location,
dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From [Project Portfolio]..CovidDeaths dea
Join [Project Portfolio]..CovidVaccinations vac
    On dea.location = vac.location
	and dea.date = vac.date
	Where dea.continent is not null

Select *
From PercentPopulationVaccinated
order by continent

