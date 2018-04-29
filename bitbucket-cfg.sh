# Prepare bitbucket home directory
#####
## NOTE: It is either required or best practice that Bitbucket Home be owned
##  by the app user and accessible only by the same. It takes too long to run
##  chown and chmod on the entire Bitbucket Home if this is a large installation.
##  Therefore it is up to you to ensure that the Bitbucket Home directory is 
##  properly conditioned, by either shelling into the container prior to startup,
##  and running the following:
#
#      chmod -R 700 ${BITBUCKET_HOME}
#      chown -R ${RUN_USER}:${RUN_GROUP} ${BITBUCKET_HOME}
#
##  Or you can prep the Bitbucket Home by running the same commands from outside
##  the container on the host file system you plan on mounting for the Bitbucket Home.
##  To do this however, you must use the UID and GID that was created during the 
##  image build: 1000:1000. Use the UID and GID instead of the actual username and
##  group name called out by the Dockerfile because more than likely those names won't
##  exist on the host file system...and even if they did, it is even less likely that
##  they share the same UID:GID. The commands would look like the following:
#
#      chmod -R 700 ${BITBUCKET_HOME}
#      chown -R 1000:1000 ${BITBUCKET_HOME}
#
##  Further, you will want to verify before using 1000:1000 because different
##  iterations of designing this container may alter the UID and GID created during
##  the build. You can do so by running the following:
#
#      docker run --rm -it kadimasolutions/bitbucket bash     # to shell into the container
#      id ${RUN_USER}                # Will show you the UID and the GID of the ${RUN_USER} user
#      grep ${RUN_GROUP} /etc/group  # Will show the GID of the ${RUN_GROUP} group
#
##  Although this setup is not ideal as a universal image, it is the lesser of two evils.
##  If all we did with this image is stand up fresh installs of Bitbucket, then putting
##  the chmod and chown commands here would not be so much an issue, as the commands
##  would complete immediately. Even in small installations, the commands could complete
##  within a reasonable time frame. But with large installations, the commands can take
##  upwards of 20 to 30 minutes and more. Which means each time you spin up the container
##  you will be waiting that long before your application even begins to startup. This is
##  not an acceptable parameter in our case. Therefore, we suffer a bit of pain in the 
##  beginning, in order to reap the benefits of containers that spin up in seconds. Keep
##  in mind that typically you will only run the chown and chmod operation the first time
##  you spin up the environment. Unless of course you are refreshing/cloning this instance
##  from another, in which case you could work the chown and chmod into the process of 
##  bringing the source data into the intended target Bitbucket Home.

# The lib dir needs to be created on fresh installations
mkdir -p                          ${BITBUCKET_HOME}/lib 
chown ${RUN_USER}:${RUN_GROUP}    ${BITBUCKET_HOME}/lib

# This must be run in addition to the above conditioning because when the Bitbucket
# Home is mounted into the conainer, Docker will re-own the top level directory on startup
# by the root user. This ensures that the root of Bitbucket Home is reset to be owned
# by the app user and group.
chown ${RUN_USER}:${RUN_GROUP}     ${BITBUCKET_HOME}


# Import ROOT cert to allow app links in dev to work along with other app-to-app communication 
if [[ -n "${AUX_ROOT_CERT_1}" ]] ; then
    keytool -noprompt -importpass -storepass changeit -importcert -keystore ${JAVA_HOME}/jre/lib/security/cacerts -file ${AUX_ROOT_CERT_1} -alias AUX_ROOT_CERT_1
fi

if [[ -n "${AUX_ROOT_CERT_2}" ]] ; then
    keytool -noprompt -importpass -storepass changeit -importcert -keystore ${JAVA_HOME}/jre/lib/security/cacerts -file ${AUX_ROOT_CERT_2} -alias AUX_ROOT_CERT_2
fi

if [[ -n "${AUX_ROOT_CERT_3}" ]] ; then
    keytool -noprompt -importpass -storepass changeit -importcert -keystore ${JAVA_HOME}/jre/lib/security/cacerts -file ${AUX_ROOT_CERT_3} -alias AUX_ROOT_CERT_3
fi

if [[ -n "${AUX_ROOT_CERT_4}" ]] ; then
    keytool -noprompt -importpass -storepass changeit -importcert -keystore ${JAVA_HOME}/jre/lib/security/cacerts -file ${AUX_ROOT_CERT_4} -alias AUX_ROOT_CERT_4
fi

if [[ -n "${AUX_ROOT_CERT_5}" ]] ; then
    keytool -noprompt -importpass -storepass changeit -importcert -keystore ${JAVA_HOME}/jre/lib/security/cacerts -file ${AUX_ROOT_CERT_5} -alias AUX_ROOT_CERT_5
fi


# Import Intermediate cert to allow app links in dev to work along with other app-to-app communication

if [[ -n "${AUX_INTER_CERT_1}" ]] ; then
		keytool -noprompt -importpass -storepass changeit -importcert -keystore ${JAVA_HOME}/jre/lib/security/cacerts -file ${AUX_INTER_CERT_1} -alias AUX_INTER_CERT_1
fi

if [[ -n "${AUX_INTER_CERT_2}" ]] ; then
		keytool -noprompt -importpass -storepass changeit -importcert -keystore ${JAVA_HOME}/jre/lib/security/cacerts -file ${AUX_INTER_CERT_2} -alias AUX_INTER_CERT_2
fi

if [[ -n "${AUX_INTER_CERT_3}" ]] ; then
		keytool -noprompt -importpass -storepass changeit -importcert -keystore ${JAVA_HOME}/jre/lib/security/cacerts -file ${AUX_INTER_CERT_3} -alias AUX_INTER_CERT_3
fi

if [[ -n "${AUX_INTER_CERT_4}" ]] ; then
		keytool -noprompt -importpass -storepass changeit -importcert -keystore ${JAVA_HOME}/jre/lib/security/cacerts -file ${AUX_INTER_CERT_4} -alias AUX_INTER_CERT_4
fi

if [[ -n "${AUX_INTER_CERT_5}" ]] ; then
		keytool -noprompt -importpass -storepass changeit -importcert -keystore ${JAVA_HOME}/jre/lib/security/cacerts -file ${AUX_INTER_CERT_5} -alias AUX_INTER_CERT_5
fi
