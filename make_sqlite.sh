#!/bin/bash

if [ ! -f "movielens-small.db" ]; then
  # Download the file
  curl -SOL http://files.grouplens.org/datasets/movielens/ml-latest-small.zip
  # Unzip it
  unzip ml-latest-small.zip # creates ml-latest-small dir
  rm -f ml-latest-small.zip

cat <<EOF > import.sql
.mode csv
.import ml-latest-small/movies.csv movies
.import ml-latest-small/tags.csv tags
.import ml-latest-small/links.csv links
.import ml-latest-small/ratings.csv ratings
EOF
  echo ".read import.sql" | sqlite3 movielens-small.db
  rm import.sql

  rm -rf ml-latest-small

cat <<EOF > addyear.sql
create table movies_years as select movieId, title, substr(trim(title),-5,4) as year, genres from movies;
update movies_years set year = null where year not like '1%' and year not like '2%';
drop table movies;
create table movies as select * from movies_years;
drop table movies_years;
EOF
  echo ".read addyear.sql" | sqlite3 movielens-small.db
  rm addyear.sql
fi
