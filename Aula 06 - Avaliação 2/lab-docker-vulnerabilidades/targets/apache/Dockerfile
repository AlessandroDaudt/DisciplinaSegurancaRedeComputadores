FROM httpd:2.4.49

COPY httpd.conf /usr/local/apache2/conf/httpd.conf
COPY public/ /usr/local/apache2/htdocs/
COPY cgi-bin/ /usr/local/apache2/cgi-bin/

RUN chmod 755 /usr/local/apache2/cgi-bin/lab-info.cgi
