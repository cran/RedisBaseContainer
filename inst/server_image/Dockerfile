FROM redis:6.2-rc
RUN apt-get update \
	&& apt-get install -y openssh-server
WORKDIR /workspace
COPY . /workspace
CMD bash /workspace/server_commands