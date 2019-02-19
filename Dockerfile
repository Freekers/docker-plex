FROM linuxserver/plex:latest
# Install FMovies dependency
RUN apt-get update && apt-get install -y libfontconfig
# Get phantomjs for FMovies
RUN wget -qO- https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-2.1.1-linux-x86_64.tar.bz2 | tar -xj -C /opt
