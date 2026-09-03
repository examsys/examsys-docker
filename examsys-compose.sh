#!/usr/bin/env bash
set -e

# First find out if this was called from symlink,
# then find the real path of parent directory.
# This is needed because macOS does not have GNU realpath.
thisfile=$( readlink "${BASH_SOURCE[0]}" ) || thisfile="${BASH_SOURCE[0]}"
basedir="$( cd "$( dirname "$thisfile" )" && pwd -P )"

if [ ! -d "$EXAMSYS_DOCKER_WWWROOT" ]
then
    echo 'Error: $EXAMSYS_DOCKER_WWWROOT is not set or not an existing directory'
    exit 1
fi

if [ -z "$EXAMSYS_DOCKER_MYSQLROOT" ]
then
    echo 'Error: $EXAMSYS_DOCKER_MYSQLROOT is not set'
    exit 1
fi

if [ ! -z "$EXAMSYS_DOCKER_SELENIUM_DEBUG" ]
then
  echo 'Warning: $EXAMSYS_DOCKER_SELENIUM_DEBUG is no longer used, you should now define a port for VNC using EXAMSYS_DOCKER_SELENIUM_VNC_PORT'
fi

if [ -z "$EXAMSYS_DOCKER_NAME" ]
then
    export EXAMSYS_DOCKER_NAME=examsys-docker
fi

dockercompose="docker compose -p $EXAMSYS_DOCKER_NAME -f ${basedir}/docker-compose.yml"

if [ -z "$EXAMSYS_DOCKER_MYSQLTZ" ]
then
    export EXAMSYS_DOCKER_MYSQLTZ=UTC
fi

if [ -z "$EXAMSYS_DOCKER_CLUSTER" ]
then
    export EXAMSYS_DOCKER_CLUSTER=0
fi

if [ -z "$EXAMSYS_DOCKER_INNODB_CLUSTER" ]
then
    export EXAMSYS_DOCKER_INNODB_CLUSTER=0
fi

if [ -z "$EXAMSYS_DOCKER_PHP" ]
then
    export EXAMSYS_DOCKER_PHP=8.3
fi

if [ -z "$EXAMSYS_DOCKER_MEMCACHED" ]
then
    export EXAMSYS_DOCKER_MEMCACHED=0
fi

if [ -z "$EXAMSYS_RSERVE" ]
then
    export EXAMSYS_RSERVE=1
fi

if [ -z "$EXAMSYS_DOCKER_MAIL_PORT" ]
then
    export EXAMSYS_DOCKER_MAIL_PORT=1080
fi

if [ "$EXAMSYS_DOCKER_CLUSTER" == 1 ]
then
    if [ -z "$EXAMSYS_DOCKER_CLUSTERVERSION" ]
    then
        export EXAMSYS_DOCKER_CLUSTERVERSION=8.4
    fi
    if [ -z "$EXAMSYS_DOCKER_MYSQL_PORT" ];
    then
        export EXAMSYS_DOCKER_MYSQL_PORT=3306
    fi
    dockercompose="${dockercompose} -f ${basedir}/cluster.yml"
else
    if [ -z "$EXAMSYS_DOCKER_MYSQLVERSION" ]
    then
        export EXAMSYS_DOCKER_MYSQLVERSION=8.4
    fi
    if [ -z "$EXAMSYS_DOCKER_MYSQL_PORT" ];
    then
        export EXAMSYS_DOCKER_MYSQL_PORT=3306
    fi
    dockercompose="${dockercompose} -f ${basedir}/db.yml"
fi

if [ -n "$EXAMSYS_DOCKER_EXPOSE" ]
then
    if [ -z "$EXAMSYS_DOCKER_WEB_HTTP_PORT" ]
    then
        export EXAMSYS_DOCKER_WEB_HTTP_PORT=80
    fi

    if [ -z "$EXAMSYS_DOCKER_WEB_HTTPS_PORT" ]
    then
        export EXAMSYS_DOCKER_WEB_HTTPS_PORT=443
    fi
fi

if [ -z "$EXAMSYS_DOCKER_WORKBENCH" ]
then
    export EXAMSYS_DOCKER_WORKBENCH=0
fi

if [ -z "$EXAMSYS_DOCKER_SELENIUM" ]
then
    export EXAMSYS_DOCKER_SELENIUM=0
fi

if [ -z "$EXAMSYS_DOCKER_BROWSERSTACK" ]
then
    export EXAMSYS_DOCKER_BROWSERSTACK=0
fi

if [ "$EXAMSYS_DOCKER_EXPOSE" == 1 ]
then
    dockercompose="${dockercompose} -f ${basedir}/expose.yml"
fi

if [ "$EXAMSYS_DOCKER_MEMCACHED" == 1 ]
then
    dockercompose="${dockercompose} -f ${basedir}/memcache.yml"

    if [ "$EXAMSYS_DOCKER_CLUSTER" == 1 ]
    then
      dockercompose="${dockercompose} -f ${basedir}/memcache-cluster.yml"
    fi
fi

if [ "$EXAMSYS_DOCKER_RSERVE" == 1 ]
then
    dockercompose="${dockercompose} -f ${basedir}/rserve.yml"

    if [ "$EXAMSYS_DOCKER_CLUSTER" == 1 ]
    then
      dockercompose="${dockercompose} -f ${basedir}/rserve-cluster.yml"
    fi
fi

if [ "$EXAMSYS_DOCKER_WORKBENCH" == 1 ]
then
    dockercompose="${dockercompose} -f ${basedir}/workbench.yml"
fi

if [ "$EXAMSYS_DOCKER_SELENIUM" == 1 ]
then
    if [ -z "$SELENIUM_VERSION" ];
    then
        export SELENIUM_VERSION=3.141.59
    fi
    if [ -z "$EXAMSYS_DOCKER_SELENIUM_VNC_PORT" ]
    then
        dockercompose="${dockercompose} -f ${basedir}/selenium.yml"
    else
        dockercompose="${dockercompose} -f ${basedir}/selenium-debug.yml"
    fi

    if [ "$EXAMSYS_DOCKER_CLUSTER" == 1 ]
    then
      dockercompose="${dockercompose} -f ${basedir}/selenium-cluster.yml"
    fi
fi

if [ "$EXAMSYS_DOCKER_BROWSERSTACK" == 1 ]
then
    dockercompose="${dockercompose} -f ${basedir}/browserstack.yml"
fi

if [ -d "$EXAMSYS_DOCKER_FAILDUMP" ]
then
  dockercompose="${dockercompose} -f ${basedir}/faildump.yml"
fi

$dockercompose $@
