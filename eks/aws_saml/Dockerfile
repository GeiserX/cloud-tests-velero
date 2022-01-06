FROM python:2-alpine

LABEL maintainer="fedor.kaplan@de.clara.net"

RUN apk add --no-cache openssh git bash sudo libxml2-dev libxslt-dev musl-dev gcc
RUN sed -i 's/#PermitRootLogin.*/PermitRootLogin\ yes/' /etc/ssh/sshd_config; \
    sed -i 's/#AllowAgentForwarding.*/AllowAgentForwarding\ yes/' /etc/ssh/sshd_config; \
    sed -ri 's/(#*)PermitEmptyPasswords.*/PermitEmptyPasswords\ yes/' /etc/ssh/sshd_config; \
    echo "ssh" >> /etc/securetty; \
    echo "" > /etc/motd

RUN pip install bs4 boto boto3 botocore ConfigParser BeautifulSoup requests pathlib lxml awscli

# generate host keys if not present
RUN ssh-keygen -A
RUN passwd -d root

COPY . ./

VOLUME ["/root/.aws"]
ENTRYPOINT [ "/entrypoint.sh" ]
