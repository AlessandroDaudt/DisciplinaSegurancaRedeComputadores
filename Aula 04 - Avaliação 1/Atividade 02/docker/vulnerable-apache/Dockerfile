ARG HTTPD_VERSION=2.4.49
FROM httpd:${HTTPD_VERSION}

RUN mkdir -p /usr/local/apache2/lab-assets /usr/local/apache2/lab-secrets

COPY lab.conf /usr/local/apache2/conf/extra/lab.conf
COPY htdocs/index.html /usr/local/apache2/htdocs/index.html
COPY lab-assets/publico.txt /usr/local/apache2/lab-assets/publico.txt
COPY lab-secrets/segredo.txt /usr/local/apache2/lab-secrets/segredo.txt

# Inclui a configuração didática sem substituir o httpd.conf original da imagem.
RUN printf '\nInclude conf/extra/lab.conf\n' >> /usr/local/apache2/conf/httpd.conf
