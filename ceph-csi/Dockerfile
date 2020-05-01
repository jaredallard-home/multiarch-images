# I originally tried the go image, but could not for the life of me, get 
# librdb-dev to be able to be found for some reason.
FROM ceph/ceph:v15 as build

ARG VERSION

ENV GOPATH=/go \
 GOROOT=/usr/local/go \
 GO111MODULE=on

# I hate this too.
RUN if [[ "$(uname -m)" == "x86_64" ]]; then architecture="amd64"; else architecture="arm64"; fi \
&&  mkdir -p /usr/local/go \
&&  curl https://storage.googleapis.com/golang/go1.13.10.linux-"$architecture".tar.gz | tar xzf - -C /usr/local/go --strip-components=1

ENV PATH="$GOROOT/bin:$GOPATH/bin:$PATH"

RUN yum -y install \
	git \
	make \
	gcc \
	librados-devel \
	librbd-devel \
    && yum -y update \
    && true

WORKDIR /src

# run go mod download
COPY go.mod go.sum ./
RUN go mod download

# Now copy the rest
COPY . ./

RUN GOOS=linux go build -a -ldflags "-X github.com/ceph/ceph-csi/pkg/util.DriverVersion=$VERSION" -o ./bin/cephcsi ./cmd/ 

FROM ceph/ceph:v15
LABEL maintainers="Ceph-CSI Authors"
LABEL description="Ceph-CSI Plugin"

# To support cross building, do NOT RUN native binaries here.
# If we have to run native binaries, qemu-user-static must be installed on
# build host and mounted to container.

# Removing ceph-iscsi repo to workaround the repo issue while upgrading
#RUN rm -f /etc/yum.repos.d/ceph-iscsi.repo && yum -y update && yum clean all
ENV CSIBIN=/usr/local/bin/cephcsi

COPY --from=build /src/bin/cephcsi $CSIBIN

ENTRYPOINT ["/usr/local/bin/cephcsi"]
