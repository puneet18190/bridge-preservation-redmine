#!/bin/bash

function install {
    echo installing $1
    shift
    apt-get -y install "$@" >/dev/null 2>&1
}

function append {
  echo appending $1 to $2 ...
  grep -qF "$1" $2 || echo "$1" >> $2
}

export DEBIAN_FRONTEND=noninteractive

# Needed for docs generation.
update-locale LANG=en_US.UTF-8 LANGUAGE=en_US.UTF-8 LC_ALL=en_US.UTF-8

echo set timezone to America/New_York
timedatectl set-timezone America/New_York

echo add brightbox repos for Ruby packages
apt-add-repository -y ppa:brightbox/ruby-ng >/dev/null 2>&1

apt-get -y update >/dev/null 2>&1

install 'development tools' build-essential patch zlib1g-dev liblzma-dev make 
install ImageMagick imagemagick libmagickcore-dev libmagickwand-dev

install Ruby2.3 ruby2.3 ruby2.3-dev
update-alternatives --set ruby /usr/bin/ruby2.3 >/dev/null 2>&1
update-alternatives --set gem /usr/bin/gem2.3 >/dev/null 2>&1

install 'Nokogiri dependencies' libxml2 libxml2-dev libxslt1-dev
install 'ExecJS runtime' nodejs

install 'Vim' vim-nox

echo Generating self signed certificates
make-ssl-cert generate-default-snakeoil

echo installing Bundler
gem install bundler -N >/dev/null 3>&1

install Git git
install Redis redis-server

echo installing PostgreSQL, user, and creating database
install PostgreSQL postgresql postgresql-contrib libpq-dev
sudo -u postgres createuser --superuser vagrant
sudo -u postgres createdb -O vagrant redmine
sudo -u postgres createdb -O vagrant redmine_test

echo "Allow your machine to access this Postgres outside of virtualbox"
sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" /etc/postgresql/9.5/main/postgresql.conf
sed -i "s#host    all             all             127.0.0.1/32            md5#host  all  all  0.0.0.0/0  trust#" /etc/postgresql/9.5/main/pg_hba.conf

echo "Creating database.yml"
sudo -u vagrant tee /home/vagrant/app/config/database.yml <<EOF
default: &default
  adapter: postgresql
  encoding: unicode
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
development:
  <<: *default
  database: redmine
test:
  <<: *default
  database: redmine_test
EOF

echo Restarting Postgresql
systemctl restart postgresql
