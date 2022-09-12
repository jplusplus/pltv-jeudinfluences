Jeu d'influences
================

_September 2022_ - Archive: [pltv-jeudinfluences.herokuapp.com](https://pltv-jeudinfluences.herokuapp.com/)


## Production

This project is shipped with a Dockerfile. To run this app in production, the easiest solution is to use Docker as described bellow.

Build the app:

```
docker build -t jeudinfluences .
```

Start the docker container:

```
docker run -p 4444:4444 -e PORT=4444 -e DATABASE_DSN="sqlite:../tmp/db.sqlite" -it --rm jeudinfluences
```

The app is now available on port 4444. Please note this example uses sqlite to store progressions directly in the Docker container. It means the data is not persisted.

## Development

This part of the manuel explains how to install this project from the master branch and **is not suitable for production**.

### Requirements

In development, this application uses the following requirements:

* node 10+
* php7
* php7-sqlite

**On Ubuntu**, enter this to install the packages:

```bash 
sudo apt-get install nodejs npm php7 php7-sqlite
``` 

### Set up the application

This command will install (in this order): npm's packages, composer and his packages.

	make install

### Run the development Server

	make run
	
## Options

These options are defined into [app/config/config.production.php](app/config/config.production.php).

| Option name                     | Default value                                   | Definition
| ------------------------------- | ----------------------------------------------- | -------------------
| **cache**                       | false                                           | Disable or enable server side cache
| **debug**                       | true                                            | Display debug message
| **email_saving_subject**        | Jeu d'influences : Votre partie est sauvegardée | Subject of the mail to save a game
| **log.enabled**                 | true                                            | Disable or enable server logs
| **media_url**                   | https://df59amfngxauf.cloudfront.net            | Repository of the video sounds and large files
| **opening_dates**               | array()                                         | Opening dates of each chapter (disabled feature)
| **static_url**                  | /                                               | Assets URL (if you  want to move static files)
| **summary_aggregation_expired** | 0.2                                             | Time after which we should re-aggregate summary (in hours)

