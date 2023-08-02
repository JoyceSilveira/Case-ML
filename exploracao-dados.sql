---------------------------------------BASE AIRBNB

--Verificar duplicidade de dados
--Dados duplicados representam aproximadamente 0% (541 linhas)
SELECT count(*), count(DISTINCT id)
FROM `case-mercado-livre.fontes_teste.airbnb`;

--Verificar consistencia de informações nas linhas duplicadas
--Informações são consistentes, podendo escolher qualquer linha entre as duplicadas
SELECT count(*), count(DISTINCT id)
FROM (SELECT airbnb.*
FROM `case-mercado-livre.fontes_teste.airbnb` as airbnb
GROUP BY id, host_id, host_identity_verified, neighbourhood_group, neighbourhood, lat, long, room_type, Construction_year, price, service_fee, reviews_per_month, review_rate_number) as b;

--Descobrir range de notas de avaliação
--Notas de 1 a 5
SELECT max(review_rate_number), min(review_rate_number)
FROM `case-mercado-livre.fontes_teste.airbnb`;

--Porcentagem de vagas por bairros
--Granularidade muito grande dos bairros, se não houver uma necessidade especifica, a melhor opção pode ser utilizar o grupo de bairros
SELECT neighbourhood, (count(DISTINCT id) / (SELECT count(DISTINCT id) 
FROM `case-mercado-livre.fontes_teste.airbnb`)) * 100 as porc_imoveis
FROM `case-mercado-livre.fontes_teste.airbnb`
GROUP BY neighbourhood
ORDER BY neighbourhood;

--Porcentagem de vagas por grupo de bairro
--Porcentagem de null baixa porem alguns nomes de bairros estão escritos de formas diferentes
--Brooklyn e Manhattan lideram disponibilidade de imoveis representando 82% dos anuncios
SELECT CASE WHEN neighbourhood_group = "Manhattan" OR neighbourhood_group = "manhatan" Then "Manhattan"
WHEN neighbourhood_group = "Brooklyn" OR neighbourhood_group = "brookln" THEN "Brooklyn"
ELSE neighbourhood_group END AS neighbourhood_group,
(count(DISTINCT id) / (SELECT count(DISTINCT id) 
FROM `case-mercado-livre.fontes_teste.airbnb`)) * 100 as porc_imoveis
FROM `case-mercado-livre.fontes_teste.airbnb`
GROUP BY neighbourhood_group;

--Media de avaliação por grupo de bairro
--Media equilibrada entre bairros
SELECT CASE WHEN neighbourhood_group = "Manhattan" OR neighbourhood_group = "manhatan" Then "Manhattan"
WHEN neighbourhood_group = "Brooklyn" OR neighbourhood_group = "brookln" THEN "Brooklyn"
ELSE neighbourhood_group END AS neighbourhood_group,
avg(review_rate_number) as media_avaliacao
FROM `case-mercado-livre.fontes_teste.airbnb`
GROUP BY neighbourhood_group
ORDER BY media_avaliacao DESC;

--Vericação de preços zerados
--Não há
SELECT count(DISTINCT id) as qtd_nulls, (count(DISTINCT id) / (SELECT count(DISTINCT id) 
FROM `case-mercado-livre.fontes_teste.airbnb`))
FROM `case-mercado-livre.fontes_teste.airbnb`
WHERE price = 0.0;

--Verificação de preços null
--Há aproximadamente 0% (247 linhas)
SELECT count(DISTINCT id) as qtd_nulls, (count(DISTINCT id) / (SELECT count(DISTINCT id) 
FROM `case-mercado-livre.fontes_teste.airbnb`))
FROM `case-mercado-livre.fontes_teste.airbnb`
WHERE price IS NULL;

--Preço de imoveis por grupo de bairro
--Preços semelhantes entre grupo de bairro
SELECT CASE WHEN neighbourhood_group = "Manhattan" OR neighbourhood_group = "manhatan" Then "Manhattan"
WHEN neighbourhood_group = "Brooklyn" OR neighbourhood_group = "brookln" THEN "Brooklyn"
ELSE neighbourhood_group END AS neighbourhood_group,
 avg(price), max(price), min(price)
FROM `case-mercado-livre.fontes_teste.airbnb`
GROUP BY neighbourhood_group;

--Média de avaliação por validação de identidade do host
--Validação do host não parece interferir na satisfação pelo imovel
SELECT host_identity_verified, avg(review_rate_number) as media_avaliacao
FROM `case-mercado-livre.fontes_teste.airbnb`
GROUP BY host_identity_verified;

--Porcentagem dos tipos de imovel
--Casa/apto inteiros e quartos privados representam maioria com 97% de representatividade
SELECT room_type, (count(DISTINCT id) / (SELECT count(DISTINCT id) 
FROM `case-mercado-livre.fontes_teste.airbnb`)) * 100 as porc_imoveis
FROM `case-mercado-livre.fontes_teste.airbnb`
GROUP BY room_type;

--Preço por tipo de imóvel
--Apesar de alguns tipo de imóveis poderem vir a oferecer mais conforto ou segurança, os valores são bem semelhantes entre as categorias. Não é possível se aprofundar mais na visão de preço do imovel uma vez que não temos a informação de m²
SELECT room_type, avg(price) as media_valor, max(price) as valor_maximo, min(price) as valor_minimo
FROM `case-mercado-livre.fontes_teste.airbnb`
GROUP BY room_type;

------------------------------------------BASE JOBS

--Verificar duplicidade de dados
--Dados duplicados representam aproximadamente 45% (1700 linhas)
SELECT count(*), count(DISTINCT job_id)
FROM `case-mercado-livre.fontes_teste.jobs`;

--Verificar consistencia de informações nas linhas duplicadas
--Informações são consistentes, podendo escolher qualquer linha entre as duplicadas
SELECT count(*), count(DISTINCT job_id)
FROM (SELECT jobs.*
FROM `case-mercado-livre.fontes_teste.jobs` as jobs
GROUP BY job_id, business_title, title_classification, level, job_category, full_time_part_time_indicator, career_level, salary_range_from, salary_range_to, work_location, neighbourhood) as b;

--Distribuição de vagas por bairro
--Alta porcentagem de null, representando cerca de 56% da base
--Poderia ser solicitado a informação do zip code para que as linhas com bairros faltantes pudessem ser atualizadas com a inserção desses dados
SELECT neighbourhood, (count(DISTINCT job_id) / (SELECT count(DISTINCT job_id) 
FROM `case-mercado-livre.fontes_teste.jobs`)) * 100 as porc_vagas
FROM (SELECT DISTINCT *
FROM `case-mercado-livre.fontes_teste.jobs`)
GROUP BY neighbourhood
ORDER BY porc_vagas DESC;

--Distribuição da categoria de trabalho por bairros
SELECT neighbourhood, job_category, count(job_id) as qtd_vagas
FROM (SELECT DISTINCT *
FROM `case-mercado-livre.fontes_teste.jobs`)
GROUP BY neighbourhood, job_category
ORDER BY neighbourhood, qtd_vagas DESC;

--Salario por categoria de trabalho
--Apesar da variabilidade de salarios já esperada, algumas categorias possuem salarios muito menores do que a média geral
SELECT job_category, avg(salary_range_to) as media,max(salary_range_to) as salario_maximo, 
min(salary_range_to) as salario_minimo
FROM (SELECT DISTINCT *
FROM `case-mercado-livre.fontes_teste.jobs`)
GROUP BY job_category;

--Salario medio x max x min
--A variação de salário é muito grande, necessitando que fosse entendido com negócio se estão todos na mesma distribuição no tempo (mensal, anual, por hr)
SELECT avg(salary_range_to) as media,max(salary_range_to) as salario_maximo, 
min(salary_range_to) as salario_minimo
FROM (SELECT DISTINCT *
FROM `case-mercado-livre.fontes_teste.jobs`);

--Verificação de salarios zerados
--Não há
SELECT count(DISTINCT job_id)
FROM (SELECT DISTINCT *
FROM `case-mercado-livre.fontes_teste.jobs`)
WHERE salary_range_to = 0.0;

--Verificação de salarios null
--Não há
SELECT count(DISTINCT job_id)
FROM (SELECT DISTINCT *
FROM `case-mercado-livre.fontes_teste.jobs`)
WHERE salary_range_to IS NULL;

--Porcentagem de vagas por categoria
SELECT job_category, (count(DISTINCT job_id) / (SELECT count(DISTINCT job_id) 
FROM `case-mercado-livre.fontes_teste.jobs`)) * 100 as porc_vagas
FROM (SELECT DISTINCT *
FROM `case-mercado-livre.fontes_teste.jobs`)
GROUP BY job_category
ORDER BY porc_vagas DESC;

--------------------------------AIRBNB X JOBS

--Quantidade de vagas por imoveis disponiveis nos bairros
--Há mais oferta de vagas do que imóveis disponíveis, podendo ser indicio que ainda tem mercado para oferecer imoveis para os trabalhadores recidirem perto do seu trabalho
SELECT neighbourhood_group, count(DISTINCT job_id)/count(DISTINCT id) as vagas_por_imovel_disponivel
FROM `case-mercado-livre.fontes_teste.airbnb_tratado` as airbnb
LEFT JOIN `case-mercado-livre.fontes_teste.jobs_tratado` as jobs
ON lower(airbnb.neighbourhood) = lower(jobs.neighbourhood)
GROUP BY neighbourhood_group
ORDER BY vagas_por_imovel_disponivel;

--Comprometimento do salário medio com o aluguel médio
--A renda média de Staten Island não é compativel com a média cobrada de aluguel dos imóveis, nos demais grupos de bairro ainda que o aluguel não ultrapasse a renda, o comprometimento é muito alto, uma vez que ao menos no Brasil o IBGE recomenda que o aluguel comprometa até 30% apenas
SELECT neighbourhood_group, (avg(price)/avg(salary_range_to)) * 100 as porc_renda_comprometida
FROM `case-mercado-livre.fontes_teste.airbnb_tratado` as airbnb
LEFT JOIN `case-mercado-livre.fontes_teste.jobs_tratado` as jobs
ON lower(airbnb.neighbourhood) = lower(jobs.neighbourhood)
GROUP BY neighbourhood_group
ORDER BY porc_renda_comprometida DESC;
