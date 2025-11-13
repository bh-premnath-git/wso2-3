FROM wso2/wso2is:7.1.0

ARG MYSQL_CONNECTOR_VERSION=8.0.30
# copy extensions to the identity server home
COPY dockerfiles/is-as-km/dropins ${WSO2_SERVER_HOME}/repository/components/dropins/
# copy customized webapps to the identity server home
COPY dockerfiles/is-as-km/webapps ${WSO2_SERVER_HOME}/repository/deployment/server/webapps/

ADD --chown=wso2carbon:wso2 wso2/reposistory/components/lib/mysql-connector-j-8.0.33.jar /home/wso2carbon/wso2is-7.1.0/repository/components/lib/mysql-connector-j-8.0.33.jar