# kafka-cluster
Dockerfile for java kafka zookeeper alpine

to create docker image use following command

```bash
docker build -t <image-name>:<tag> .
```

Note: replace `<image-name>` with name of image you want to create and `<tag>` with the the tag you want to provide to this image

to create and run a container using above image use following command

```bash
docker run -d -p 2181:2181 -p 9092:9092 --name <container-name> <image-name>:<tag>
```

Note: replace `<container-name>` with name of container you with to keep for your container/pod
