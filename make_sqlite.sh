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

#   rm -rf ml-latest-small
fi
