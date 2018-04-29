#!/usr/bin/bash

trap "{ ${BITBUCKET_INSTALL_DIR}/bin/stop-bitbucket.sh; exit $?; }" SIGTERM SIGINT

# Run config for Bitbucket
/bitbucket-cfg.sh

# Set JVM limits to Out-of-Box limits unless overridden
export JVM_MINIMUM_MEMORY="${JVM_MIN_MEM:=512m}"
export JVM_MAXIMUM_MEMORY="${JVM_MAX_MEM:=1g}"

#check for image version and execute appropriate option
if [ ${BITBUCKET_VERSION} != "5.1.2" ]
then 
	export ES_MIN_MEM_LEGACY="${JVM_ES_MIN_MEM:=256m}"
	export ES_MAX_MEM_LEGACY="${JVM_ES_MAX_MEM:=1g}"
	sed -i '/^\-Xms/c\-Xms${ES_MIN_MEM_LEGACY}' ${BITBUCKET_HOME}/shared/search/jvm.options
	sed -i '/^\-Xmx/c\-Xmx${ES_MAX_MEM_LEGACY}' ${BITBUCKET_HOME}/shared/search/jvm.options
	cat ${BITBUCKET_HOME}/shared/search/jvm.options | envsubst > ${BITBUCKET_HOME}/shared/search/jvm.options1
	mv -f ${BITBUCKET_HOME}/shared/search/jvm.options1 ${BITBUCKET_HOME}/shared/search/jvm.options
else 
	export ES_MIN_MEM="${JVM_ES_MIN_MEM:=256m}"
	export ES_MAX_MEM="${JVM_ES_MAX_MEM:=1g}"
	export ES_JAVA_OPTS="-Xms${ES_MIN_MEM} -Xmx${ES_MAX_MEM}"
fi

# Setup Catalina Opts
: ${CATALINA_CONNECTOR_PROXYNAME:=}
: ${CATALINA_CONNECTOR_PROXYPORT:=}
: ${CATALINA_CONNECTOR_SCHEME:=http}
: ${CATALINA_CONNECTOR_SECURE:=false}

: ${CATALINA_OPTS:=}

: ${JAVA_OPTS:=}

: ${ELASTICSEARCH_ENABLED:=true}
: ${APPLICATION_MODE:=}

CATALINA_OPTS="${CATALINA_OPTS} -DcatalinaConnectorProxyName=${CATALINA_CONNECTOR_PROXYNAME}"
CATALINA_OPTS="${CATALINA_OPTS} -DcatalinaConnectorProxyPort=${CATALINA_CONNECTOR_PROXYPORT}"
CATALINA_OPTS="${CATALINA_OPTS} -DcatalinaConnectorScheme=${CATALINA_CONNECTOR_SCHEME}"
CATALINA_OPTS="${CATALINA_OPTS} -DcatalinaConnectorSecure=${CATALINA_CONNECTOR_SECURE}"

JAVA_OPTS="${JAVA_OPTS} ${CATALINA_OPTS}"

ARGS="$@"

# Start Bitbucket without Elasticsearch
if [ "${ELASTICSEARCH_ENABLED}" == "false" ] || [ "${APPLICATION_MODE}" == "mirror" ]; then
    ARGS="--no-search ${ARGS}"
fi

# Start Bitbucket
su -s /usr/bin/bash "${RUN_USER}" -c "${BITBUCKET_INSTALL_DIR}/bin/start-bitbucket.sh -fg ${ARGS}" &

# Loop until signal
while :
do
    sleep 4
done
