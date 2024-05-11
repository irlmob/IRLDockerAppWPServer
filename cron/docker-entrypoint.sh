#!/bin/sh
if [ "$1" == "cron" ]; then
  echo $(date) "🚀  Installing ⏰ CRONs... from /usr/cbin/cron.txt"
  crontab -l -u root | cat /usr/cbin/cron.txt | crontab -u root -

  echo ""
  echo "\$ crontab -l -u root"
  echo "$(crontab -l -u root)"
  echo ""
  echo "$(date) ⏰ Waiting for CRON to execute..."
  exec /usr/sbin/crond -f
fi

if [ "$1" == "bash" ]; then
  exec sleep 99999999999;
fi

################################################################################
# Anything else
################################################################################
exec "$@"
