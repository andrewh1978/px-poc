FROM centos:7
COPY kubernetes.repo /etc/yum.repos.d/kubernetes.repo
RUN curl -s https://mirror.go-repo.io/centos/go-repo.repo >/etc/yum.repos.d/go-repo.repo
RUN yum install -y tmux openssh-clients gcc make golang git kubectl dialog
RUN echo 'tar xzf <(curl -sL https://github.com/derailed/k9s/releases/download/v0.19.1/k9s_Linux_x86_64.tar.gz) -C /usr/local/bin -T <(echo k9s)' | bash
#RUN go get -u github.com/onsi/ginkgo/ginkgo
#RUN go get -u github.com/onsi/gomega/...
#RUN ln -s /root/go/bin/golint /usr/bin/golint
#RUN ln -s /root/go/bin/ginkgo /usr/bin/ginkgo
#RUN (cd /root && git clone https://github.com/portworx/torpedo.git)
#RUN (cd /root/torpedo && make)
RUN mkdir /px-poc
COPY assets /assets
COPY go.sh /go.sh
COPY menu.sh /menu.sh
RUN chmod 755 /*.sh
CMD /go.sh
