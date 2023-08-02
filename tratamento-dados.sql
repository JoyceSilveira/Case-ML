------------------------PREPARAÇÃO BASE AIRBNB
CREATE TABLE `case-mercado-livre.fontes_teste.airbnb_tratado` AS SELECT DISTINCT id, neighbourhood,
CASE WHEN neighbourhood_group = "Manhattan" OR neighbourhood_group = "manhatan" Then "Manhattan"
WHEN neighbourhood_group = "Brooklyn" OR neighbourhood_group = "brookln" THEN "Brooklyn"
WHEN neighbourhood_group IS NULL THEN ""
ELSE neighbourhood_group END AS neighbourhood_group, 
room_type, price, reviews_per_month
FROM `case-mercado-livre.fontes_teste.airbnb`;

-------------------------PREPARAÇÃO BASE JOBS
CREATE TABLE `case-mercado-livre.fontes_teste.jobs_tratado` AS SELECT job_id, 
CASE WHEN job_category IS NULL THEN ""
ELSE job_category END AS job_category,
CASE WHEN salary_range_to IS NULL THEN 0.0
ELSE salary_range_to END AS salary_range_to, 
CASE WHEN neighbourhood IS NULL THEN ""
ELSE neighbourhood END AS neighbourhood
FROM `case-mercado-livre.fontes_teste.jobs`;

--Para a visualização das categorias de trabalho foi aberto para as 10 maiores que representam cerca de 70% de todas as vagas de emprego
CREATE TABLE `case-mercado-livre.fontes_teste.jobs_tratado_agrupado` AS SELECT count((CASE WHEN job_category = "Engineering, Architecture, & Planning" then job_id end)) as engineering_architecture_planning,
count((CASE WHEN job_category = "Technology, Data & Innovation" then job_id end)) as tech_data_innovation, 
count((CASE WHEN job_category = "Legal Affairs" then job_id end)) as legal_affairs,
count((CASE WHEN job_category = "Administration & Human Resources" then job_id end)) as adm_human_resources,
count((CASE WHEN job_category = "Finance, Accounting, & Procurement" then job_id end)) as finance_accounting_procurement,
count((CASE WHEN job_category = "Constituent Services & Community Programs" then job_id end)) as constituent_serv_community_prog,
count((CASE WHEN job_category = "Health" then job_id end)) as health,
count((CASE WHEN job_category = "Building Operations & Maintenance" then job_id end)) as building_operations_maintenance,
count((CASE WHEN job_category = "Finance, Accounting, & Procurement Policy, Research & Analysis" then job_id end)) as finance_acc_proc_policy_research_analysis,
count((CASE WHEN job_category = "Public Safety, Inspections, & Enforcement" then job_id end)) as pub_safety_insp_enforcement,
count((CASE WHEN job_category NOT IN ("Public Safety, Inspections, & Enforcement","Finance, Accounting, & Procurement Policy, Research & Analysis","Building Operations & Maintenance","Health","Constituent Services & Community Programs","Finance, Accounting, & Procurement","Administration & Human Resources","Legal Affairs","Technology, Data & Innovation","Engineering, Architecture, & Planning") then job_id end)) as outros,
neighbourhood, avg(salary_range_to) as media_salario
FROM `case-mercado-livre.fontes_teste.jobs_tratado`
GROUP BY neighbourhood;

-------------------------PREPARAÇÃO BASE PARA DASHBOARD
CREATE TABLE `case-mercado-livre.fontes_teste.dash_airbnb_jobs` AS SELECT neighbourhood_group, count(DISTINCT id) as qtd_imoveis, avg(price) as media_preco_imovel, avg(reviews_per_month) as media_avaliacoes_imovel, sum(engineering_architecture_planning) as engineering_architecture_planning, sum(tech_data_innovation) as tech_data_innovation, sum(legal_affairs) as legal_affairs, sum(adm_human_resources) as adm_human_resources, sum(finance_accounting_procurement) as finance_accounting_procurement, sum(constituent_serv_community_prog) as constituent_serv_community_prog, sum(health) as health, sum(building_operations_maintenance) as building_operations_maintenance, sum(finance_acc_proc_policy_research_analysis) as finance_acc_proc_policy_research_analysis, sum(pub_safety_insp_enforcement) as pub_safety_insp_enforcement,sum(outros) as outros, avg(media_salario) as media_salario
FROM `case-mercado-livre.fontes_teste.airbnb_tratado` as airbnb
LEFT JOIN `case-mercado-livre.fontes_teste.jobs_tratado_agrupado` as jobs
ON lower(airbnb.neighbourhood) = lower(jobs.neighbourhood)
GROUP BY neighbourhood_group;
