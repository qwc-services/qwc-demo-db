# QWC Services DB with demo data
#
# self contained container:
# - includes postgres server with postgis
# - config-db is set up
# - demo data are in the DB
#
FROM sourcepole/qwc-base-db:v2022.09.03


# copy demo connection service for migrations
COPY pg_service_demo-data.conf /tmp/.pg_service.conf

# add demo data to container
RUN curl -o /tmp/demo_geodata.gpkg -L https://github.com/pka/mvt-benchmark/raw/master/data/mvtbench.gpkg

# script to insert demo data into DB
COPY setup-demo-data.sh /docker-entrypoint-initdb.d/2_setup-demo-data.sh


# After running all the /docker-entrypoint-initdb.d scripts we just
# want to terminate at build time and *not* to run postgres.
# Thus we patch the docker-entrypoint.sh script to comment the exec out.
RUN sed --in-place 's/^\t*exec "$@"//' /tmp/docker-entrypoint.sh

# the following will start postgres and run the above added scripts
# under /docker-entrypoint-initdb.d
RUN gosu postgres bash /tmp/docker-entrypoint.sh postgres
