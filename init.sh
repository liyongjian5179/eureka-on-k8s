#!/bin/bash
# liyongjian5179

# JVM启动参数
#JAVA_OPTIONS="-server -Xms256m -Xmx512m -Duser.timezone=Asia/Shanghai -Djava.security.egd=file:/dev/./urandom"
JAVA_OPTIONS="-server -Duser.timezone=Asia/Shanghai -Djava.security.egd=file:/dev/./urandom"

# 创建日志目录，及配置记录日志
LOG_DIR=/usr/local/logs
START_LOG=${LOG_DIR}/startup.log
mkdir -pv $LOG_DIR
touch $START_LOG

echo "********************************************" |  tee -a $START_LOG
echo "********$(date)********" |  tee -a $START_LOG
echo "********************************************" |  tee -a $START_LOG

# kubernetes 集群中使用的集群 dns 域名
postFix="svc.cluster.local"
# 默认初始用户名密码
preFix="${USERNAME:=admin}:${PASSWORD:=admin}@"
echo $preFix | tee -a $START_LOG

# 注册 EUREKA 时的主机名
export EUREKA_HOST_NAME="$MY_POD_NAME.$MY_IN_SERVICE_NAME.$MY_POD_NAMESPACE.$postFix"
# false表示不向注册中心注册自己,默认为 true
BOOL_REGISTER="true"
# false表示自己端就是注册中心，我的职责就是维护服务实例，并不需要去检索服务,默认为 true
BOOL_FETCH="true"

# 判断副本数是否为空，如果为空设初值为 1
if [ ! -n "$EUREKA_REPLICAS" ]; then
  EUREKA_REPLICAS=1
fi

# 根据副本数进行相关设置
if [ $EUREKA_REPLICAS -eq 1 ]; then
    echo "The replicas of eureka pod is 1."
    export  BOOL_REGISTER="false"
    export BOOL_FETCH="false"
    # 不带认证
    # export EUREKA_URL_LIST="http://$EUREKA_HOST_NAME:8761/eureka/,"
    # 带认证
    export EUREKA_URL_LIST="http://$preFix$EUREKA_HOST_NAME:8761/eureka/,"
    echo " Set the EUREKA_URL_LIST is $EUREKA_URL_LIST" | tee -a $START_LOG
else
    echo "The replicas of the eureka pod is $EUREKA_REPLICAS"  | tee -a $START_LOG
    export BOOL_REGISTE="true"
    export BOOL_FETCH="true"
    tmp=`expr $EUREKA_REPLICAS - 1`
    for i in `seq 0 $tmp `;do
        # 注册的时候去除自己
        if [ "$EUREKA_HOST_NAME" = "$EUREKA_APPLICATION_NAME-$i.$MY_IN_SERVICE_NAME.$MY_POD_NAMESPACE.$postFix" ];then
            continue
        else
            # 不带认证
            # temp="http://$EUREKA_APPLICATION_NAME-$i.$MY_IN_SERVICE_NAME.$MY_POD_NAMESPACE.$postFix:8761/eureka/,"
            # 带认证
            temp="http://$preFix$EUREKA_APPLICATION_NAME-$i.$MY_IN_SERVICE_NAME.$MY_POD_NAMESPACE.$postFix:8761/eureka/,"
            EUREKA_URL_LIST="$EUREKA_URL_LIST$temp"
            #echo $EUREKA_URL_LIST | tee -a $START_LOG
        fi
    done
    echo "Set the EUREKA_URL_LIST is ${EUREKA_URL_LIST%?}"  | tee -a $START_LOG
fi

#去除结尾的逗号
export EUREKA_URL_LIST=${EUREKA_URL_LIST%?}
export BOOL_FETCH=$BOOL_FETCH
export BOOL_REGISTER=$BOOL_REGISTER

echo "The registerWithEureka is $BOOL_REGISTER " | tee -a $START_LOG
echo "The fetchRegistry is $BOOL_FETCH "  | tee -a $START_LOG

echo "MY_NODE_NAME=$MY_NODE_NAME" >> $START_LOG
echo "MY_POD_NAME=$MY_POD_NAME" >> $START_LOG
echo "MY_POD_NAMESPACE=$MY_POD_NAMESPACE" >> $START_LOG
echo "MY_POD_IP=$MY_POD_IP" >> $START_LOG
echo "MY_IN_SERVICE_NAME=$MY_IN_SERVICE_NAME" >> $START_LOG
echo "EUREKA_APPLICATION_NAME=$EUREKA_APPLICATION_NAME" >> $START_LOG
echo "EUREKA_REPLICAS=$EUREKA_REPLICAS" >> $START_LOG
echo "EUREKA_HOST_NAME=$EUREKA_HOST_NAME" >> $START_LOG

echo "Start jar...."

cd /usr/local
# mkdir -p /logs/log-collection-demo/$HOSTNAME/logs
# ln -s /logs/log-collection-demo/$HOSTNAME/logs /usr/local/logs
echo 'JAVA_OPTIONS:'$JAVA_OPTIONS
# 执行jar文件
java $JAVA_OPTIONS -jar /usr/local/eureka.jar