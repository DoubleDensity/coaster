FROM centos:latest

MAINTAINER Buttetsu Batou <doubledense@gmail.com>

# Install deps
RUN yum -y clean expire-cache
RUN yum -y install deltarpm epel-release && yum clean all && rm -fr /var/cache/yum
RUN yum -y update && rm -fr /var/cache/yum
RUN yum repolist
RUN yum -y install gcc gnutls-devel mkisofs isomd5sum rpm-build yum-utils createrepo \
	curl bsdtar && yum clean all && rm -fr /var/cache/yum

# Manually build and install recent version of wget
WORKDIR /tmp
RUN curl https://ftp.gnu.org/gnu/wget/wget-1.19.5.tar.gz --output /tmp/wget.tar.gz \
	&& tar zxvf wget.tar.gz && rm -v wget.tar.gz && mv wget* wget && pushd /tmp/wget \
	&& ./configure && make install && rm -fr /tmp/wget

VOLUME /cache
VOLUME /output

COPY app /app
RUN chmod +x /app/*.sh
COPY configs /configs
COPY keys /keys

WORKDIR /cache

CMD ["/app/build.sh"]