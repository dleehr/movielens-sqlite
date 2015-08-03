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

cat <<EOF > fix.sql
create table movies_fix as select movieId, title, substr(trim(title),-5,4) as year, genres from movies;
update movies_fix set year = null where year not like '1%' and year not like '2%';
update movies_fix set title = substr(trim(title),0,length(trim(title))-6) where year is not null;
drop table movies;
create table movies as select cast(movieId as integer) as movieId, title, cast(year as integer) as year, genres from movies_fix;
drop table movies_fix;
create table ratings_fix as select cast(userId as integer) as userId, cast(movieId as integer) as movieId, cast(rating as real) as rating, cast(timestamp as integer) as timestamp from ratings;
drop table ratings;
create table ratings as select * from ratings_fix;
drop table ratings_fix;
create table links_fix as select cast(movieId as integer) as movieId, imdbId, tmdbId from links;
drop table links;
create table links as select * from links_fix;
drop table links_fix;
create table tags_fix as select cast(userId as integer) as userId, cast(movieId as integer) as movieId, tag, cast(timestamp as timestamp) as timestamp from tags;
drop table tags;
create table tags as select * from tags_fix;
drop table tags_fix;
EOF
  echo ".read fix.sql" | sqlite3 movielens-small.db
  rm fix.sql
fi
