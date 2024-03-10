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

# **ДЗ 5**
1. Установил zabbix-agent и настроил - добавил юзер параметры, лежат в файле _zabbix_agentd.conf_
2. Написал скрипты metrics.sh и discovery.sh, первый генерирует рандомные метрики от 1 до 100, второй выводит эти метрики в JSON.
3. Настроил Discovery rule в zabbix, внутри которого настроил item и trigger prototype.
4. Создал бота в тг: @otus_obs_homework_alert_bot
5. В заббиксе настроил и включил Media type - telegram - добавил токен бота. Так же настроил пользователя Admin - включил оповещения и добавил id чата в поле Send To.

Скриншоты приложил.
