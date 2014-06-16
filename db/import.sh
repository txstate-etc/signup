#!/bin/bash
set +e

from_db='registerme_development'
to_db='signup_development'
dump_opts='--default-character-set=utf8 --skip-set-charset --no-create-info --complete-insert'

tables=$( cat <<EOF
topics
departments
sites
sessions
sessions_users
occurrences
permissions
reservations
survey_responses
users
EOF
)

rake db:reset

mysql -u root $to_db -e"ALTER TABLE users ADD active tinyint"

for table in $tables; do
  echo "Importing $table ......"
  mysqldump -u root $dump_opts $from_db ${table} > ${table}.sql
  mysql -u root --default-character-set=utf8 $to_db < ${table}.sql
done

mysql -u root $to_db -e"ALTER TABLE users DROP active"

rails r 'Reservation.counter_culture_fix_counts'
