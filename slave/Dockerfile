# The FROM will be replaced when building in OpenShift
FROM centos:latest

# Install headless Java
USER root

ENV JENKINS_SWARM_VERSION 3.3
ENV HOME /var/lib/jenkins

RUN yum install -y epel-release

RUN yum clean all && \
        yum-config-manager --disable rhel* 1>/dev/null && \
        yum-config-manager --enable rhel-7-server-rpms && \
        yum-config-manager --enable rhel-7-server-ose-3.2-rpms && \
        export INSTALL_PKGS="nss_wrapper java-1.8.0-openjdk-headless \
            java-1.8.0-openjdk-devel nss_wrapper gettext tar git" && \
        yum clean all && \
        yum install -y --setopt=tsflags=nodocs install $INSTALL_PKGS && \
        rpm -V $INSTALL_PKGS && \
        yum clean all && \
        mkdir -p /var/lib/jenkins && \
        chown -R 1001:0 /var/lib/jenkins && \
        chmod -R g+w /var/lib/jenkins

RUN curl --create-dirs -sSLo /usr/share/jenkins/swarm-client-$JENKINS_SWARM_VERSION.jar https://repo.jenkins-ci.org/releases/org/jenkins-ci/plugins/swarm-client/$JENKINS_SWARM_VERSION/swarm-client-$JENKINS_SWARM_VERSION.jar \
  && chmod 755 /usr/share/jenkins


# Copy the entrypoint
COPY configuration/* /var/lib/jenkins/
USER 1001

# Run the JNLP client by default
# To use swarm client, specify "/var/lib/jenkins/run-swarm-client" as Command
ENTRYPOINT ["/var/lib/jenkins/jenkins-slave.sh"]
