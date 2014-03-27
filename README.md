Jeu d'influences
================

_March 2014_

## Production

This part of the manuel explains how to install this project from the production branch.

* PHP 5.3 is prerequired
* Your Apache configuration must support **URL Rewritting**
* Setup your Apache Webserver DocumentRoot to `public/`
* Change the mysql and others settings in [app/config/config.production.php](app/config/config.production.php) to your needs
* Install the composer dependancies:  
    ```
    curl -sS https://getcomposer.org/installer | php && php composer.phar install
    ```

## Development

### Requirements

In development, this application uses the following requirements:

* node 
    * npm
    * grunt
* php5-sqlite

**On Ubuntu**, enter this to install the packages:

```bash 
sudo apt-get install nodejs npm php5-sqlite
sudo npm install -g grunt-cli
``` 

### Set up the application

This command will install (in this order): npm's packages, composer and his packages, and bower's packages.

	make install

### Run the development Server

	make run

