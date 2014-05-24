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
reservations
survey_responses
EOF
)

rake db:reset

for table in $tables; do
  echo "Importing $table ......"
  mysqldump -u root $dump_opts $from_db $table > ${table}.sql
  mysql -u root --default-character-set=utf8 $to_db < ${table}.sql
done
