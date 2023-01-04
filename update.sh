#!/bin/sh

# Update package repository
apk update

# Upgrade installed packages
apk upgrade

# Check for updated packages
if [ $(apk info --installed | grep -vF "$(apk info --installed)" | wc -l) -gt 0 ]; then
  # Write log entry
  echo "Upgraded packages: $(apk info --installed | grep -vF "$(apk info --installed)")" | tee -a /var/log/self-upgrade.log
fi

# Check for updated services and restart them
for pkg in $(apk info --installed); do
  # Check if package is a service
  if [ -d "/etc/init.d/$pkg" ]; then
    # Get current version of service
    current_version=$(apk info --installed $pkg | grep '^$pkg-' | awk -F '-' '{print $2}')
    # Get updated version of service
    updated_version=$(apk info $pkg | grep '^$pkg-' | awk -F '-' '{print $2}')
    # Restart service if it is updated
    if [ "$current_version" != "$updated_version" ]; then
      service $pkg restart
      # Write log entry
      echo "Restarted service: $pkg" | tee -a /var/log/self-upgrade.log
    fi
  fi
done
# Check if Nginx is running
if ! pgrep -x "nginx" > /dev/null; then
  # Start Nginx
  nginx
fi
