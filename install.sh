docker run --rm -i -e home=$HOME -v /var/run/docker.sock:/var/run/docker.sock centos:7 <<\EOF
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[1;34m'
WHITE='\033[0;37m'
NC='\033[0m'

echo -e ${BLUE}Setting up installation container
yum install -y git docker >&/dev/null
echo Cloning repo
git clone https://github.com/andrewh1978/px-poc >&/dev/null
cd px-poc
echo Building container
docker build -t px-poc . >&/dev/null
echo
echo -e ${YELLOW}Run px-poc with:
echo -e "${WHITE}docker run -it -e LINES=$LINES -e COLUMN=$COLUMNS -v </path/to/kubeconfig>:/kubeconfig --name px-poc --rm px-poc"
EOF
