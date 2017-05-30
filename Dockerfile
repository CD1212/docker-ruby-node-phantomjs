FROM ubuntu:14.04
MAINTAINER Edwin van der Graaf <edwin@digitpaint.nl>

RUN apt-get update
RUN apt-get -y upgrade

RUN apt-get -y install build-essential zlib1g-dev libssl-dev \
               libreadline6-dev libyaml-dev git python-software-properties \
               fontconfig libjpeg8 libjpeg-turbo8 libicu52 imagemagick \
               libmagickwand-dev libmagickcore-dev ghostscript libgs-dev libpq-dev

ENV RUBY_DOWNLOAD_SHA256 98e18f17c933318d0e32fed3aea67e304f174d03170a38fd920c4fbe49fec0c3
ADD https://cache.ruby-lang.org/pub/ruby/2.3/ruby-2.3.4.tar.gz /tmp/

# Install ruby
RUN \
  cd /tmp && \
  echo "$RUBY_DOWNLOAD_SHA256 *ruby-2.3.4.tar.gz" | sha256sum -c - && \
  tar -xzf ruby-2.3.4.tar.gz && \
  cd ruby-2.3.4 && \
  ./configure && \
  make && \
  make install && \
  cd .. && \
  rm -rf ruby-2.3.4 && \
  rm -f ruby-2.3.4.tar.gz

RUN gem install bundler --no-ri --no-rdoc

# Install node
ENV NODEJS_DOWNLOAD_SHA256 d7742558bb3331e41510d6e6f1f7b13c0527aecc00a63c3e05fcfd44427ff778
ADD https://nodejs.org/dist/v6.5.0/node-v6.5.0.tar.gz /tmp/

RUN \
  cd /tmp && \
  echo "$NODEJS_DOWNLOAD_SHA256 *node-v6.5.0.tar.gz" | sha256sum -c - && \
  tar xvzf node-v6.5.0.tar.gz && \
  rm -f node-v6.5.0.tar.gz && \
  cd node-v* && \
  ./configure && \
  CXX="g++ -Wno-unused-local-typedefs" make && \
  CXX="g++ -Wno-unused-local-typedefs" make install && \
  cd /tmp && \
  rm -rf /tmp/node-v* && \
  echo -e '\n# Node.js\nexport PATH="node_modules/.bin:$PATH"' >> /root/.bashrc

RUN npm install yarn -g

# Download phantomjs build (see README)
RUN \
  cd /tmp && \
  git clone https://github.com/edwinvdgraaf/phantomjs-build.git && \
  cd phantomjs-build && \
  cp bin/phantomjs /usr/local/bin/ && \
  cd /tmp && \
  rm -rf /tmp/phantomjs-build

# Install extra dependencies
# separated from the compile dependencies for node and ruby
# to make use of docker build layers
RUN apt-get -y install zip yui-compressor curl
