[cheveretourl]: https://chevereto.com/
[cheveretogithub]: https://github.com/Chevereto/Chevereto-Free

[![chevereto](http://chevereto.com/app/themes/v3/img/chevereto-blue.svg)][cheveretourl]

# tanmng/chevereto - Chevereto Free Docker

[Chevereto][cheveretourl] is a powerful and fast image hosting script that allows you to create your very own full featured image hosting website in just minutes.

This docker image was created from the [Chevereto-Free github repository][cheveretogithub].

## Connection to database

[Chevereto][cheveretourl] requires an Mysql database to store its information.
You can use a [Mysql](https://hub.docker.com/_/mysql/) or [MariaDB](https://hub.docker.com/_/mariadb/) container to host this.

Information on connection to database is provided to container via environment
variables.

These variables are

* `CHEVERETO_DB_HOST` - hostname of the Database machine that you wish to
  connect, default to `db`
* `CHEVERETO_DB_USERNAME` - Username to authenticate to MySQL database, default
  to `chevereto`
* `CHEVERETO_DB_PASSWORD` - Password of the user when connect to MySQL database, default to `chevereto`
* `CHEVERETO_DB_NAME` - Name of the database in MySQL server, default to `chevereto`
* `CHEVERETO_DB_PREFIX` - Table prefix (use this to run multiple instance of
  Chevereto using the same Database ), default to `chv_`

## Permanent storage

[Chevereto][cheveretourl] stores images uploaded by users in `/var/www/html/images` directory within the container.

You can mount a [data volume](https://docs.docker.com/engine/tutorials/dockervolumes/#data-volumes) at this location to ensure that you don't lose your
images if you relaunch/remove container

## Example Usage

I recommend you to use [Docker-compose](https://docs.docker.com/compose/) / [Docker swarm](https://docs.docker.com/engine/swarm/) to launch Chevereto in
conjunction with a MySQL database. A sample of docker-compose.yaml can be found
below

### Docker compose

Note: Thanks to backward compatibility of docker-compose, you can change the `version` to `2` and it will still works

```yaml
version: '3'

services:
  db:
    image: mariadb:10.1.22
    volumes:
      - './mariadb:/var/lib/mysql:rw'
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: chevereto_root
      MYSQL_DATABASE: chevereto
      MYSQL_USER: chevereto
      MYSQL_PASSWORD: chevereto

  chevereto:
    depends_on:
      - db
    image: nmtan/chevereto:1.0.7
    restart: always
    environment:
      CHEVERETO_DB_HOST: db
      CHEVERETO_DB_USERNAME: chevereto
      CHEVERETO_DB_PASSWORD: chevereto
      CHEVERETO_DB_NAME: chevereto
      CHEVERETO_DB_PREFIX: chv_
    volumes:
      - './images:/var/www/html/images:rw'
    ports:
      - 80:80
```

Once `docker-compose.yaml` is ready, you can run

```bash
docker-compose up
```

To run the service

### Standalone

```bash
docker run -it --name chevereto -d \
    --link mysql:mysql \
    -p 80:80 \
    -v "$PWD/images":/var/www/html/images \
    -e "CHEVERETO_DB_HOST=db" \
    -e "CHEVERETO_DB_USERNAME=chevereto" \
    -e "CHEVERETO_DB_PASSWORD=chevereto" \
    -e "CHEVERETO_DB_NAME=chevereto" \
    -e "CHEVERETO_DB_PREFIX=chv_" \
    tanmng/chevereto
```

