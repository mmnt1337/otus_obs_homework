# otus_obs_homework
Домашние задания по курсу Observability OTUS

# **GAP-1**
1. Установил Ubuntu 22.04 LTS на HyperV.
2. Произвел первичную настройку системы, пользователя и ПО.
3. Установил docker, docker-compose.
4. С помощью docker-compose установил и настроил CMS WordPress с БД MySQL.
_(Далее все устанавливается с помощью docker-compose)_
5. Учстановил и настроил sql_exporter.
   Так же установил prometheus, black_box_exporter и node_exporter.
7. Настроил сбор метрик посредствам prometheus, файл кофигурации **prometheus.yml**

P.S. Файл конфигурации docker-compose приложил.

# **GAP-2**
1. Установил и настроил grafana.
2. Через UI графаны создал папки и дашборды.
3. Добавил Prometheus в качестве datasource. 
4. Настроил и подогнал дашборд node exporter для infra.
5. Так же настроил дашборды ДБ и Blackbox exporter в качестве мониторинга app.
