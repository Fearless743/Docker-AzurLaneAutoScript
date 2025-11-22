FROM python:3.7-slim-bullseye

ENV TZ=Asia/Shanghai
ENV ALAS_URL=https://github.com/W1NDes/M-AzurLaneAutoScript
ENV FIX_MXNET=0
EXPOSE 22267

# update TZ
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone

# Install dependencies (include adb from Debian repos to avoid external download)
RUN apt-get update && \
    apt-get install -y git libgomp1 wget unzip pkg-config build-essential adb \
    libavdevice-dev libavfilter-dev libavformat-dev libavcodec-dev libavutil-dev libswscale-dev && \
    apt-get clean

WORKDIR /app

RUN git clone -b dev $ALAS_URL /app/AzurLaneAutoScript && \
    cp /app/AzurLaneAutoScript/deploy/docker/requirements.txt /tmp/requirements.txt && \
    sed -i '/^av==/d' /tmp/requirements.txt && \
    printf '\nav==8.0.3\n' >> /tmp/requirements.txt
RUN pip install --no-cache-dir -r /tmp/requirements.txt

RUN cd /app/AzurLaneAutoScript/config/ && \
    cp -f deploy.template-docker.yaml deploy.yaml && \
    mkdir /app/config && \
    cp /app/AzurLaneAutoScript/config/* /app/config/

# clean
RUN rm -rf /tmp/* && \
    rm -r ~/.cache/pip

VOLUME /app/AzurLaneAutoScript/config

COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

CMD [ "/app/entrypoint.sh" ]
