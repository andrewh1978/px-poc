FROM centos:7
COPY kubernetes.repo /etc/yum.repos.d/kubernetes.repo
RUN yum install -y tmux openssh-clients
RUN echo 'tar xzf <(curl -sL https://github.com/derailed/k9s/releases/download/v0.19.1/k9s_Linux_x86_64.tar.gz) -C /usr/local/bin -T <(echo k9s)' | bash
