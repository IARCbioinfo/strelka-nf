# Set the base image to Debian
FROM debian:latest

# File Author / Maintainer
MAINTAINER cahaisv <cahaisv@iarc.fr>

RUN mkdir -p /var/cache/apt/archives/partial && \
	touch /var/cache/apt/archives/lock && \
	chmod 640 /var/cache/apt/archives/lock && \
	apt-key adv --keyserver keyserver.ubuntu.com --recv-keys F76221572C52609D && \
	apt-get clean && \
	apt-get update -y && \

  # Install dependences
  DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y git
  # add other dependences necessary
  DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y wget && gcc && g++ && make && zlib1g-dev && bzip2 && python && rsync 
  
  # HERE INSTALL NECESSARY SOFTWARE
  # Example
  # wget **AddressToRepository** && \
  # tar **Archive** && \
  # cd **Directory** && \
  # make && \
  # make install && \
  wget ftp://strelka:%27%27@ftp.illumina.com/v1-branch/v1.0.15/strelka_workflow-1.0.15.tar.gz && \
  tar xzf strelka_workflow-1.0.15.tar.gz && \
  cd strelka_workflow-1.0.15 && \
  ./configure --prefix=/usr/local/ && \
  make
  
  # Remove unnecessary dependences
  DEBIAN_FRONTEND=noninteractive apt-get remove -y \
  git && \

  # Clean
  DEBIAN_FRONTEND=noninteractive apt-get autoremove -y && \
apt-get clean
