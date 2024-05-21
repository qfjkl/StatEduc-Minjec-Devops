# Alpine Linux is a small, security-oriented, lightweight Linux distribution that is ideal for Docker containers due to its small size and simplicity.
FROM alpine:3.11

# Provides information about the maintainer of this Docker image, making it easier for users to contact the maintainer if they have any issues or questions.
LABEL maintainer="cedric gaelo <cedricgaelo@gmail.com>"

# Informs Docker that the container will listen on port 9000 at runtime. This is typically the port on which PHP-FPM listens for incoming requests.
EXPOSE 9000

# Updates the package list, installs essential packages like PHP and its extensions, curl for downloading files, gnupg for verifying signatures, and ca-certificates for handling SSL/TLS certificates. These packages are necessary for running PHP and interacting with MSSQL.
RUN apk update && \
    apk add --no-cache \
        curl \
        gnupg \
        php7 \
        php7-pdo \
        php7-fpm \
        unixodbc \
        ca-certificates && \
    update-ca-certificates

# Downloads Microsoft ODBC Driver and MSSQL tools necessary for the PHP container to connect to and interact with a Microsoft SQL Server database.
RUN cd /tmp && \
    curl -O https://download.microsoft.com/download/e/4/e/e4e67866-dffd-428c-aac7-8d28ddafb39b/msodbcsql17_17.5.2.2-1_amd64.apk && \
    curl -O https://download.microsoft.com/download/e/4/e/e4e67866-dffd-428c-aac7-8d28ddafb39b/mssql-tools_17.5.2.1-1_amd64.apk && \
    curl -O https://download.microsoft.com/download/e/4/e/e4e67866-dffd-428c-aac7-8d28ddafb39b/msodbcsql17_17.5.2.2-1_amd64.sig && \
    curl -O https://download.microsoft.com/download/e/4/e/e4e67866-dffd-428c-aac7-8d28ddafb39b/mssql-tools_17.5.2.1-1_amd64.sig && \
    curl https://packages.microsoft.com/keys/microsoft.asc | gpg --import -

# Verifies the downloaded ODBC and MSSQL tools using GPG signatures to ensure they are authentic and have not been tampered with. Installs the verified packages.
RUN cd /tmp && \
    gpg --verify msodbcsql17_17.5.2.2-1_amd64.sig msodbcsql17_17.5.2.2-1_amd64.apk && \
    gpg --verify mssql-tools_17.5.2.1-1_amd64.sig mssql-tools_17.5.2.1-1_amd64.apk && \
    apk add --allow-untrusted msodbcsql17_17.5.2.2-1_amd64.apk && \
    apk add --allow-untrusted mssql-tools_17.5.2.1-1_amd64.apk

# Downloads the PHP SQL Server (SQLSRV) driver, which enables PHP to communicate with Microsoft SQL Server. Installs the driver in the PHP modules directory.
RUN cd /tmp && \
    curl -L https://github.com/microsoft/msphpsql/releases/download/v5.8.1/Alpine-7.3.tar | tar xv && \
    cp /tmp/Alpine-7.3/php_pdo_sqlsrv_73_nts.so /usr/lib/php7/modules/php_pdo_sqlsrv.so && \
    cp /tmp/Alpine-7.3/php_sqlsrv_73_nts.so /usr/lib/php7/modules/php_sqlsrv.so && \
    rm -r /tmp/*

# Configures PHP to load the SQLSRV extensions and adjusts PHP-FPM settings to listen on port 9000 and to allow connections from any client. 
# These configurations are necessary for PHP to use the SQL Server driver and for PHP-FPM to accept incoming connections.
RUN cd /tmp && \
    echo extension=php_pdo_sqlsrv > /etc/php7/conf.d/10_pdo_sqlsrv.ini && \
    echo extension=php_sqlsrv > /etc/php7/conf.d/00_sqlsrv.ini && \
    sed -i '/^listen = /c\listen = 9000' /etc/php7/php-fpm.d/www.conf && \
    sed -i '/^listen.allowed_clients/c\;listen.allowed_clients' /etc/php7/php-fpm.d/www.conf

# Installs additional packages such as FreeTDS (for supporting TDS protocol) and additional PHP extensions needed for web application functionality.
RUN apk add --no-cache \
    freetds \
    php-curl \
    php7-session \
    php7-json \
    php7-openssl \
    php7-ctype \
    php7-xml \
    php7-zip \
    php7-gd \
    php7-intl

# Adds the MSSQL tools to the system PATH, making the tools accessible from the command line within the container.
ENV PATH $PATH:/opt/mssql-tools/bin

# Specifies the command to start PHP-FPM when the container runs. The flags "--allow-to-run-as-root" and "--nodaemonize" allow PHP-FPM to run as the root user and in the foreground, respectively.
CMD ["php-fpm7", "--allow-to-run-as-root", "--nodaemonize"]
