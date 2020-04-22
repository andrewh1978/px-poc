Run on your master node.

Install with:
```
curl https://raw.githubusercontent.com/andrewh1978/px-poc/master/install.sh | bash
```

Run with:
```
docker run -it -e LINES=$LINES -e COLUMNS=$COLUMNS -v </path/to/kubeconfig>:/kubeconfig --name px-poc --rm px-poc
```
