FROM nginx:alpine
ENV PORT=80
COPY . /usr/share/nginx/html
COPY default.conf.template /etc/nginx/templates/default.conf.template
