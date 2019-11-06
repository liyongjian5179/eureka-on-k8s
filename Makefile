# liyongjian5179@163.com

all: build push
.PHONY: build push test

# config

DOCKER_REGISTRY = registry.cn-beijing.aliyuncs.com/liyongjian5179
IMAGE = eureka
TAG = test-security
CONTAINER_NAME = test-security

java:
	@# mvn clean package 
	@echo "\033[32;1mBuilding jar by MAVEN ......\033[0m";
	mvn -U clean package -Dsonar.skip=true -Dmaven.test.skip=true

build:
	@# build image
	@echo "\033[32;1mBuilding image: $(IMAGE):$(TAG)  .....\033[0m";
	docker build -t $(DOCKER_REGISTRY)/$(IMAGE):$(TAG) .

push:
	@# push image to docker-registry
	@echo "\033[32;1mPushing image to $(DOCKER_REGISTRY)/$(IMAGE):$(TAG) \033[0m"
	docker push $(DOCKER_REGISTRY)/$(IMAGE):$(TAG)

clean:
	@# clean image & container
	@echo "\033[32;1mCleaning congtainer -> $(CONTAINER_NAME) & \
	image -> $(DOCKER_REGISTRY)/$(IMAGE):$(TAG) .....\033[0m"
	docker rmi -f $(DOCKER_REGISTRY)/$(IMAGE):$(TAG)
	docker rm -f $(CONTAINER_NAME)

test:
	@# use image to test
	@echo "\033[32;1mTesting image: $(DOCKER_REGISTRY)/$(IMAGE):$(TAG) .....\033[0m"
	docker run  -d --name $(CONTAINER_NAME) $(DOCKER_REGISTRY)/$(IMAGE):$(TAG)
	docker ps -a|grep $(CONTAINER_NAME)
	docker logs $(CONTAINER_NAME)