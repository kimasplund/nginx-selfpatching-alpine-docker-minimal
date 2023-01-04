FROM alpine:latest

# Install Nginx and required packages
RUN apk add --no-cache nginx

# Add Nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Copy update script and make it executable
COPY update.sh /usr/local/bin/update.sh
RUN chmod +x /usr/local/bin/update.sh

# Schedule update script to run every 4 hours using cron
RUN crontab -l | { cat; echo "0 */4 * * * /usr/local/bin/update.sh"; } | crontab -

# Set update.sh as the entrypoint
#ENTRYPOINT ["/usr/local/bin/update.sh"]

# Expose Nginx port
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]