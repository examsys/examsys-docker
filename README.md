# examsys-docker: Docker Containers for ExamSys Developers

This repository contains Docker configuration aimed at ExamSys developers to easily deploy a testing environment for ExamSys.

This should not be used on a production environment.

## Prerequisites
* [Docker](https://docs.docker.com) installed

## Quick start

```bash
# Set up path to ExamSys code
export EXAMSYS_DOCKER_WWWROOT=/path/to/examsys/code
# Set up mysql root password
export EXAMSYS_DOCKER_MYSQLROOT=password
# Expose web server ports
export EXAMSYS_DOCKER_EXPOSE=1
# Web server http port on host
export EXAMSYS_DOCKER_WEB_HTTP_PORT=80
# Web server https port on host
export EXAMSYS_DOCKER_WEB_HTTPS_PORT=443
# Expose db port for remote access
export EXAMSYS_DOCKER_WORKBENCH=0
# Build Selenium for behat testing
export EXAMSYS_DOCKER_SELENIUM=1
# Set the database timezone to be the same as the main ExamSys timezone.
export EXAMSYS_DOCKER_MYSQLTZ=Europe\London

# Start up containers
./examsys-compose.sh up -d

# Shut down and destroy containers
./examsys-compose.sh down
```

## Stop and restart containers

If you want to use your containers continuously for manual testing or development without starting them up from scratch everytime you use them, you can also just stop without destroying them. With this approach, you can restart your containers sometime later, they will keep their data and won't be destroyed completely until you run `docker-compose down`.

```bash
# Stop containers
./examsys-compose.sh stop

# Restart containers
./examsys-compose.sh start
```

## Environment variables

You can change the configuration of the docker images by setting various environment variables before calling `docker-compose up`.

| Environment Variable                 | Mandatory      | Allowed values                    | Default value  | Notes                                            |
|--------------------------------------|----------------|-----------------------------------|----------------|--------------------------------------------------|
| `EXAMSYS_DOCKER_WWWROOT`             | yes            | path on your file system          | none           | The path to the Rogo codebase you intend to test |
| `EXAMSYS_DOCKER_FAILDUMP`            | no             | path on your file system          | none           | The path you want faildumps to be stored locally |
| `EXAMSYS_DOCKER_MYSQLROOT`           | yes            | string                            | none           | The root password for your mysql database        |
| `EXAMSYS_DOCKER_PHP`                 | no             | latest, 7.4, 8.0, 8.1             | 8.3            | The version of PHP that should be used           |
| `EXAMSYS_DOCKER_EXPOSE`              | no             | 0/1                               | 0              | 1 enables webserver port exposure                |
| `EXAMSYS_DOCKER_WORKBENCH`           | no             | 0/1                               | 0              | 1 enables database port exposure                 |
| `EXAMSYS_DOCKER_WEB_HTTP_PORT`       | yes            | integer                           | 80             | Host http port for web server                    |
| `EXAMSYS_DOCKER_WEB_HTTPS_PORT`      | yes            | integer                           | 443            | Host https port for web server                   |
| `EXAMSYS_DOCKER_SELENIUM`            | no             | 0/1                               | 0              | 1 setup selenium                                 |
| `EXAMSYS_DOCKER_SELENIUM_VNC_PORT`   | no             | integer                           | 0              | Port number for VNC                              |
| `EXAMSYS_DOCKER_BROWSERSTACK`        | no             | 0/1                               | 0              | 1 setup browserstack                             |
| `BROWSERSTACK_LOCAL_KEY`             | no             | string                            | none           | Your browserstack API key                        |
| `EXAMSYS_DOCKER_CLUSTER`             | ndb cluster    | 0/1                               | 0              | 1 load cluster database configuration            |
| `EXAMSYS_DOCKER_MYSQLVERSION`        | yes            | version of mysql to deploy        | latest         | Required by mysql database                       |
| `EXAMSYS_DOCKER_MYSQLTZ`             | yes            | default timezone of db            | UTC            | This to be set to the same as the web service    |
| `EXAMSYS_DOCKER_CLUSTERVERSION`      | ndb cluster    | version of cluster to deploy      | 8.4            | Required by cluster database                     |
| `SELENIUM_VERSION`                   | no             | version of selenium               | 3.14           | Version of selenium                              |
| `EXAMSYS_DOCKER_MYSQL_PORT`          | no             | integer                           | 3306           | port that mysql workbench can use to connect     |
| `EXAMSYS_DOCKER_MYSQL_USER`          | innodb cluster | string                            | root           | user used to connect to servers                  |
| `EXAMSYS_DOCKER_MEMCACHED`           | no             | 0/1                               | 0              | Enables memcached sessions in PHP                |
| `EXAMSYS_DOCKER_RSERVE`              | no             | 0/1                               | 1              | Starts rserve                                    |
| `EXAMSYS_DOCKER_MAIL_PORT`           | no             | integer                           | 1080           | The port that the mail server will be exposed on |
| `EXAMSYS_DOCKER_NAME`                | no             | string                            | examsys-docker | The name of the container set                    |

## Installing ExamSys

Create a settings.xml file in the config directory of ExamSys, you can use an example file from this repository, for example settings-innodb.xml.

To ensure that there are no database connection errors when the hosts are started and stopped the settings/server/host value can be set as % this will ensure that the ExamSys database users can connect to the database from any server (you should not do this on a production server).

If installing from the git repository you will need to run the following commands:

```bash
./examsys-compose.sh exec -T web npm install
./examsys-compose.sh exec -T web grunt
```

Now you can install ExamSys using the following command:

```bash
./examsys-compose.sh exec -T web php cli/init.php -u root -p $EXAMSYS_DOCKER_MYSQLROOT -s db -t 3306 -n examsys
```

You may also need to either manually run composer or initialise Behat to finish making ExamSys usable if you downloaded it directly from the repository. 

If you wish to do automatic testing of ExamSys you must install it directly from the git repository, since the community releases do not include the testing code.

### Phpunit

To initialise phpunit you will need to create a phpunit.xml file in the config directory, you can use an example file from this repository as a base for this phpunit-innodb.xml (The database password in it will need modifying)

After installing ExamSys you will now be able to initialise the phpunit database using:

```bash
./examsys-compose.sh exec -T web php testing/unittest/cli/init.php --clean
```

You should then be able to run the tests using:

```bash
./examsys-compose.sh exec -T web vendor/bin/phpunit -c testing/unittest/config/phpunit.xml
```

For a complete list of PHPUnit command line options, see the [PHPUnit documentation](https://docs.phpunit.de/en/9.6/textui.html).

### Behat

To initialise phpunit you will need to create a behat.xml file in the config directory, you can use an example file from this repository as a base for this behat-innodb.xml (The database password in it will need modifying)

After installing ExamSys you will be able to initialise the phpunit database using:

```bash
./examsys-compose.sh exec -T web php testing/behat/cli/init.php --clean
```

You should then be able to run the tests using:

```bash
./examsys-compose.sh exec -T web vendor/bin/behat --config testing/behat/config/behat.yml
```

#### Viewing running behat tests

It is possible to view any @javascript behat tests that are running using VNC. To do this you need to configure a port for VNC, for example:
```bash
export EXAMSYS_DOCKER_SELENIUM_VNC_PORT=5900
```
Then after you bring up examsys-docker you will be able to connect to localhost:5900 using the password *secret* using a VNC client. 

### Code style checks

To run the coding standards tests to the same level as our automatic tests use:
```bash
./examsys-compose.sh exec -T web vendor/squizlabs/php_codesniffer/bin/phpcs --standard=testing/codesniffer/Rogo/ruleset.xml -n .
```

It only reports back errors (this is the minimum level of code style checking you should do when preparing a patch for ExamSys) 

### Rector

We use Rector for automatically refactoring parts of ExamSys when moving between version of PHP. When you add code to ExamSys it must be written in a way that does not cause Rector to make changes.

To see if Rector will make changes run:
```bash
./examsys-compose.sh exec -T web vendor/bin/rector process --dry-run
```

### Rserve

If you wish to use Rserve as your maths engine you will need to change the following in the ExamSys configuration screen:

| setting                     | value                        |
|-----------------------------|------------------------------|
| cfg_calc_settings : host    | calc                         |
| cfg_calc_settings : port    | 6311                         |
| cfg_calc_settings : timeout | choose a time out in seconds |
| cfg_calc_type               | Rrserve                      |

### Email

Emails are not enabled by default in the docker image. However, you can set ExamSys up to use Mail Catcher as its SMTP server.

You will need to change the following in the ExamSys configuration screen:

| setting     | value |
|-------------|-------|
| mailer_host | mail  |
| mailer_port | 1025  |

The web interface to inspect the emails sent by ExamSys is exposed on port 1080

## Updating ExamSys

You can run in updates via the command line using:

```bash
./examsys-compose.sh exec -T web php cli/upd.php -u root -p $EXAMSYS_DOCKER_MYSQLROOT -o1 -q1
```

## XDebug

The web server is configured with XDebug you should be able to access it to do debugging using your favorite IDE
if you are running the instance on your local machine.

* IDE key: examsys

## Also see

* [examsys-php-apache](https://github.com/examsys/examsys-php-apache)
* [examsys-rserve](https://github.com/examsys/examsys-rserve)
