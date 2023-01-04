#!/bin/sh

# Set log file path
LOG_FILE="/var/log/self-upgrade.log"

# Update package repository
apk update | tee -a "$LOG_FILE"

# Upgrade installed packages
apk upgrade | tee -a "$LOG_FILE"

# Check for updated packages
if [ $(apk info --installed | grep -vF "$(apk info --installed)" | wc -l) -gt 0 ]; then
  # Write log entry
  echo "Upgraded packages: $(apk info --installed | grep -vF "$(apk info --installed)")" | tee -a "$LOG_FILE"
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
      service $pkg restart | tee -a "$LOG_FILE"
      # Write log entry
      echo "Restarted service: $pkg" | tee -a "$LOG_FILE"
    fi
  fi
done