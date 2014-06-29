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

echo 'Updating active user count...'
mysql -u root $from_db -e'update users set active=0;'
mysql -u root $from_db <<END
  update users
    join (select user_id from reservations union 
           select user_id from permissions union 
           select user_id from sessions_users union 
           select id as user_id from users where admin=1
         ) list on
   users.id = list.user_id
  set
    active = 1
END

mysql -u root $to_db -e'ALTER TABLE users ADD active tinyint'

for table in $tables; do
  echo "Importing $table ......"

  if [ "$table" == 'users' ]; then
    where='--where active=1'
  else
    where=''
  fi
  mysqldump -u root $dump_opts $where $from_db ${table} > ${table}.sql
  mysql -u root --default-character-set=utf8 $to_db < ${table}.sql
done

mysql -u root $to_db -e'ALTER TABLE users DROP active'

rails r 'Reservation.counter_culture_fix_counts'
