#!/bin/bash
# custom-entrypoint.sh
# A custom entrypoint to help print out some warning to users

case "${CHEVERETO_VERSION}" in
    1.6.*|latest)
        # Display message to tell user to upgrade to latest env-var structure if needed
        if [ -z "${CHEVERETO_DB_USER}" ] && [ ! -z "${CHEVERETO_DB_USERNAME}" ]; then
            echo "From version 1.6.1 Chevereto free use env-var CHEVERETO_DB_USER to specify the database username instead of CHEVERETO_DB_USERNAME, please consider updating your Docker container config to user the correct env-var"
            export CHEVERETO_DB_USER="${CHEVERETO_DB_USERNAME}"
        fi
        if [ -z "${CHEVERETO_DB_PASS}" ] && [ ! -z "${CHEVERETO_DB_PASSWORD}" ]; then
            echo "From version 1.6.1 Chevereto free use env-var CHEVERETO_DB_PASS to specify the database password instead of CHEVERETO_DB_PASSWORD, please consider updating your Docker container config to user the correct env-var"
            export CHEVERETO_DB_PASS="${CHEVERETO_DB_PASSWORD}"
        fi
        ;;
esac

# For older version, we fix them using PHP code in settings.php
    
# Start the actual entrypoint of the image
docker-php-entrypoint apache2-foreground