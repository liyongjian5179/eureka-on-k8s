FROM openjdk:8
LABEL maintainer="liyongjian5179@163.com"
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
COPY init.sh /init.sh
COPY target/eureka-0.0.1-SNAPSHOT.jar /usr/local/eureka.jar
EXPOSE 8761
ENTRYPOINT ["/bin/sh", "/init.sh"]