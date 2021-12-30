FROM amazonlinux:2 as jekyll
LABEL org.opencontainers.image.authors="jester@dltj.org"
LABEL org.opencontainers.image.url="https://github.com/dltj/jekyll-serve-amplify"
LABEL org.opencontainers.image.title="Jekyll Docker Container for AWS Amplify"

# Versions
ENV VERSION_RUBY=2.7.5
ENV VERSION_BUNDLER=2.2.33
ENV VERSION_AMPLIFY=6.3.1

# UTF-8 Environment
ENV LANGUAGE en_US:en
ENV LANG=en_US.UTF-8
ENV LC_ALL en_US.UTF-8

## Install OS packages
RUN touch ~/.bashrc
RUN yum -y update && \
  yum -y install \
  # alsa-lib-devel \
  # autoconf \
  # automake \
  bzip2 \
  bison \
  bzr \
  # cmake \
  # expect \
  # fontconfig \
  git \
  gcc-c++ \
  # GConf2-devel \
  # gtk2-devel \
  # gtk3-devel \
  # libnotify-devel \
  # libpng \
  # libpng-devel \
  libffi-devel \
  libtool \
  # libX11 \
  # libXext \
  # libxml2 \
  # libxml2-devel \
  # libXScrnSaver \
  # libxslt \
  # libxslt-devel \
  # libyaml \
  libyaml-devel \
  make \
  # nss-devel \
  openssl-devel \
  openssh-clients \
  patch \
  procps \
  # python3 \
  # python3-devel \
  readline-devel \
  sqlite-devel \
  tar \
  # tree \
  unzip \
  wget \
  which \
  # xorg-x11-server-Xvfb \
  zip \
  zlib \
  zlib-devel \
  yum clean all && \
  rm -rf /var/cache/yum

## Install Ruby
RUN curl -sSL https://rvm.io/mpapis.asc | gpg --import - && curl -sSL https://rvm.io/pkuczynski.asc | gpg --import - && 	curl -sL https://get.rvm.io | bash -s -- --with-gems="bundler"

ENV PATH /usr/local/rvm/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
RUN /bin/bash --login -c "\
  rvm install $VERSION_RUBY && rvm use $VERSION_RUBY && gem install bundler -v $VERSION_BUNDLER && gem install -N jekyll && \
  rvm cleanup all"

## Environment Setup
RUN echo export PATH="/usr/local/rvm/gems/ruby-${VERSION_RUBY}/bin:/usr/local/rvm/gems/ruby-${VERSION_RUBY}@global/bin:/usr/local/rvm/rubies/ruby-${VERSION_RUBY}/bin:/usr/local/rvm/bin:$PATH" >> ~/.bashrc && \
  echo export GEM_PATH="/usr/local/rvm/gems/ruby-${VERSION_RUBY}" >> ~/.bashrc

EXPOSE 4000

WORKDIR /site

ENTRYPOINT [ "jekyll" ]

CMD [ "--help" ]


FROM jekyll as jekyll-serve

COPY docker-entrypoint.sh /usr/local/bin/

# on every container start, check if Gemfile exists and warn if it's missing
ENTRYPOINT [ "docker-entrypoint.sh" ]

CMD [ "bundle", "exec", "jekyll", "serve", "--force_polling", "-H", "0.0.0.0", "-P", "4000" ]
