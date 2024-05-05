
## Настройка сервисов

### Docker Compose
Подключение к сервисам происходит по названию контейнера при условии сетевой доступности (указываем порты, по которым будут доступны сервисы). Например, myapp:3000
Для изменения портов на которых запускается сервис редактировать пункт **ports**:

*./compose.yaml*
```yaml
  myapp:
...
    ports:
      - 3000:3000
...
```
Для монитрования файлов или директорий сервисам добавить пункт **volumes**:
```yaml
  myapp:
...
    volumes:
      - /path/to/file_or_directory_on_host:/path/to/file_or_directory_in_container
      - ./relative_path_on_host:/path/to/file_or_directory_in_container
```

Для добавления или изменеия переменного окружения пункт **environment**:
```yaml
  myapp:
...
    environment:
      - DB_HOST=db
      - DB_PORT=5432
      - DB_USER=myuser
      - DB_PASSWORD=mypassword
...
```

Для того, чтобы запустить сервис с командой или параметрами используется **command**:
```yaml
  myapp:
...
    command:
      - '--config.file=my.config'
...
```

### Prometheus
В файле **prometheus.yml** указаны настройки прометеус

*./prometheus.yml*
```yaml
global: # Глобальные настройки сервиса, которые применяются, если не указать других
  scrape_interval:     5s # Интервал сбора данных

  external_labels:      # Метки, которые будут добавляться для всех данных из Prometheus
    monitor: 'otus:def'


remote_write: # Куда Prometheus будет отправлять данные для хранения
  - url: http://victoriametrics:8428/api/v1/write

rule_files: # Путь до файла с правилами алертинга самого Prometheus
  - 'alert.rules'

alerting: # Пункт где указывается сервис алертинга, в нашем случае alertmanager
  alertmanagers:
  - scheme: http
    static_configs:
    - targets:
      - "alertmanager:9093"

scrape_configs: # Настройки сбора данных, откуда и как часто Prometheus будет их брать
  # The job name is added as a label `job=<job_name>` to any timeseries scraped from this config.
  - job_name: 'prometheus' # job для сбора внутренних метрик Prometheus

    # Override the global default and scrape targets from this job every 5 seconds.
    scrape_interval: 5s # В данном случае эта настройка перезаписывает глобальную для job=prometheus

    static_configs:
      - targets: ['localhost:9090'] # Адрес откуда Prometheus берет данные для данной job

  - job_name: sql_db # job для MySQL exporter
    static_configs:
      - targets: ['mysqld-exporter:9104'] # Адрес откуда Prometheus берет данные для данной job
        labels:
          alias: wordpress_sql # метка для данных из этого экспортера

```
### Экспортеры Prometheus:
***MySQL exporter***

*./sql_exporter.cnf*
```yaml
[client]
host=db # адрес, где находится БД, в нашем случае имя контейнера из compose.yaml
port=3306 # Порт на котором находится БД, так же указан в compose.yaml
user=root # Пользователь под которым экспортер будет собирать данные, подробнее на https://hub.docker.com/r/prom/mysqld-exporter
password=rootpass # Пароль для пользователя
```
***Node Exporter***

Используем стандартные настройки, отдельный файл конфигурации не требуется.

### Alertmanager
*./alertmanager/alertmanager.yml*
```yaml
route: # указываем куда будем отправлять алерты
  receiver: 'telegram' # имя получателя алерта
  group_by: [ alertname ] # группируем по имени алерта 

  routes: # Задаем получателей в зависимости от свойств алерта
    - matchers:
      - severity="critical" # Отправляем алерт в телеграм, если его важност "Critical"
      receiver: 'telegram' 
      
    - matchers:
      - severity="warning" # Отправляем алерт на почту, если его важност "Warning"
      receiver: 'mail'

receivers: # Задаем получатлей
- name: 'telegram' # настройки для отправления алертов в телеграм
  telegram_configs:
    - api_url: https://api.telegram.org # адрес API telegram
      bot_token: '***********' # токен бота, дает BotFather
      send_resolved: true 
      chat_id: ****** # ID чата, можно посмотреть на https://api.telegram.org/bot{our_bot_token}/getUpdates # Перед этим надо отправить сообщения в бота

- name: 'mail' # Задаем получателя почты
  email_configs:
  - to: 'mmnt1337@otus.alert' # кому
    from: 'alert@otus.alert' # от кого
    smarthost: 'mailhog:1025' # SMTP сервер почты
    require_tls: false # если настроен tls, то убрать

```

### Logstash
*./logstash.conf*
```yaml
input { # Пункт для указания вводов данных для logstash
  beats { # Инпут для сервисов beats
    port => 5044 # порт, откуда logstash берет данные (в данном случае стандартный порт Beats)
  } 
}

output { # Пункт для указания адреса вывода данных
  elasticsearch { # вывод в elasticsearch
    hosts => ["elasticsearch:9200"]
  }
}
```

### Heartbeat
*./heartbeat.yml*
```yaml
heartbeat.monitors: # Указываем мониторы heartbeat и их настройки
- type: http # Тип монитора
  name: "Google" # Название монитора
  enabled: true # Включаем данный монитор
  schedule: '@every 10s' # указываем период опрашивания 
  urls: ["https://www.google.com"] # указываем адрес сайта для опрашивания
...
output.elasticsearch: # указываем выводы, куда heartbeat будет класть данные
  hosts: ["elasticsearch:9200"] # В нашем случае elasticsearch
```

### Metricbeat
*./metricbeat.yml*
```yaml
metricbeat.modules: # Указываем модули по которым будем собирать метрики 
- module: system # В данном случае модуль системы для сбора 'системных' метрик хоста
  period: 10s # период сбора метрик
  metricsets: # Указываем метрики, которые будем собирать
    - cpu
    - load
    - memory
output.elasticsearch: # указываем выводы, куда heartbeat будет класть данные
  hosts: ["elasticsearch:9200"] # В нашем случае elasticsearch
  ```
### Vector

Использую вектор для выгрузки логов WordPress из Docker так как сам WP автоматически логи не генерирует
Пришлось отсечь все поля, кроме message из логов из-за бага в elasticsearch из-за которого он не может обработать поля с глубиной 
https://github.com/vectordotdev/vector/issues/5881

*./vector.yaml*
```yaml
sources: # задаем источники логов или метрик
  docker_logs: # в нашем случае источник docker, симантически называем :)
    type: docker_logs # Тип получаемых логов, подробнее https://vector.dev/docs/reference/configuration/sources/
    auto_partial_merge: true # свойство для автоматического объединения неполных данных, на всякий случай
    host_key: host # указываем название поля, в котором хранится название хоста
    include_images: # логи с каких образов будем собирать
      - wordpress


transforms: # задаем преобразования для полученных логов
  parse_logs: # название transform, по нему будут выводится измененные данные
    type: "remap" # Типа трансформа, подробнее https://vector.dev/docs/reference/configuration/transforms/
    inputs: ["docker_logs"] # Откуда берем данные для трансформа
    source: . = parse_key_value!(.message) # выражение для трансформа, в данном случае достаем только поле message


sinks: # синки, куда будем отравлять данные 
  elastic: # Синк для эластика
    type: elasticsearch # Тип синка, подробнее https://vector.dev/docs/reference/configuration/sinks/
    inputs: # Какие данные будем туда передавать, в нашем случае измененные логи докера
      - parse_logs 
    endpoints: # адреса синка
      - http://elasticsearch:9200

  file: # файлы для выгрузки данных
    type: file # тип - файл :)
    inputs: # В этот раз передаем полные логи докера
      - docker_logs
    path: "/etc/vector/file.log" # Путь к файлу, в который грузим данные. (Надо указать в volumes в compose.yaml)
    encoding: # обязательное поле, указываем в каком формате будем выгружать данные
      codec: json
```

**Остальные настройки производятся непосредственно в приложениях**
