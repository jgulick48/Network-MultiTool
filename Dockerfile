FROM alpine:3.13

MAINTAINER Kamran Azeem & Henrik Høegh (kaz@praqma.net, heh@praqma.net)

EXPOSE 80 443 1180 11443

# Install some tools in the container and generate self-signed SSL certificates.
# Packages are listed in alphabetical order, for ease of readability and ease of maintenance.
RUN     apk update \
    &&  apk add bind-tools busybox-extras curl \
                iproute2 iputils jq mtr net-snmp-tools \
                net-tools nginx openssl tcptraceroute \
                perl-net-telnet procps tcpdump wget \
    &&  mkdir /certs \
    &&  chmod 700 /certs \
    &&  openssl req \
        -x509 -newkey rsa:2048 -nodes -days 3650 \
        -keyout /certs/server.key -out /certs/server.crt -subj '/CN=localhost'


# Copy a simple index.html to eliminate text (index.html) noise which comes with default nginx image.
# (I created an issue for this purpose here: https://github.com/nginxinc/docker-nginx/issues/234)

COPY index.html /usr/share/nginx/html/


# Copy a custom/simple nginx.conf which contains directives
#   to redirected access_log and error_log to stdout and stderr.
# Note: Don't use '/etc/nginx/conf.d/' directory for nginx virtual hosts anymore.
#   This 'include' will be moved to the root context in Alpine 3.14.

COPY nginx.conf /etc/nginx/nginx.conf

COPY docker-entrypoint.sh /docker-entrypoint.sh


# Start nginx in foreground:
CMD ["/usr/sbin/nginx", "-g", "daemon off;"]



# Note: If you have not included the "bash" package, then it is "mandatory" to add "/bin/sh"
#         in the ENTNRYPOINT instruction. 
#       Otherwise you will get strange errors when you try to run the container. 
#       Such as:
#       standard_init_linux.go:219: exec user process caused: no such file or directory

# Run the startup script as ENTRYPOINT, which does few things and then starts nginx.
ENTRYPOINT ["/bin/sh", "/docker-entrypoint.sh"]





###################################################################################################

# Build and Push (to dockerhub) instructions:
# -------------------------------------------
# docker build -t local/network-multitool .
# docker tag local/network-multitool jgulick48/network-multitool
# docker login
# docker push jgulick48/network-multitool


# Pull (from dockerhub):
# ----------------------
# docker pull jgulick48/network-multitool


# Usage - on Docker:
# ------------------
# docker run --rm -it jgulick48/network-multitool /bin/bash
# OR
# docker run -d  jgulick48/network-multitool
# OR
# docker run -p 80:80 -p 443:443 -d  jgulick48/network-multitool
# OR
# docker run -e HTTP_PORT=1180 -e HTTPS_PORT=11443 -p 1180:1180 -p 11443:11443 -d  jgulick48/network-multitool


# Usage - on Kubernetes:
# ---------------------
# kubectl run multitool --image=jgulick48/network-multitool
