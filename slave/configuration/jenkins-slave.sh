#!/bin/bash

#!/bin/bash
#
# This script will launch the JNLP remoting client that Jenkins master server
# will use for the auto-discovery of this slave.
#

# The directory that Jenkins will execute the builds and store cache files.
# The directory has to be writeable for the user that the container is running
# under.
export JENKINS_HOME=/var/lib/jenkins

# Setup nss_wrapper so the random user OpenShift will run this container
# has an entry in /etc/passwd.
# This is needed for 'git' and other tools to work properly.
#
export USER_ID=$(id -u)
export GROUP_ID=$(id -g)
envsubst < ${JENKINS_HOME}/passwd.template > ${JENKINS_HOME}/passwd
export LD_PRELOAD=libnss_wrapper.so
export NSS_WRAPPER_PASSWD=${JENKINS_HOME}/passwd
export NSS_WRAPPER_GROUP=/etc/group

# Make sure the Java clients have valid $HOME directory set
export HOME=${JENKINS_HOME}

set -e

# if `docker run` first argument start with `-` the user is passing jenkins swarm launcher arguments
if [[ $# -lt 1 ]] || [[ "$1" == "-"* ]]; then

  # jenkins swarm slave
  JAR=`ls -1 /usr/share/jenkins/swarm-client-*.jar | tail -n 1`

  # if -master is not provided and using --link jenkins:jenkins
  if [[ "$@" != *"-master "* ]] && [ ! -z "$JENKINS_PORT_8080_TCP_ADDR" ]; then
    PARAMS="-master http://$JENKINS_PORT_8080_TCP_ADDR:$JENKINS_PORT_8080_TCP_PORT"
  fi

  echo Running java $JAVA_OPTS -jar $JAR -fsroot $HOME $PARAMS "$@"
  exec java $JAVA_OPTS -jar $JAR -fsroot $HOME $PARAMS "$@"
fi

# As argument is not jenkins, assume user want to run his own process, for sample a `bash` shell to explore this image
exec "$@"
