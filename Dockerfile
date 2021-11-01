FROM httpd
EXPOSE 80
RUN apt-get update -y   &&   apt-get install apt-utils  -y
RUN apt-get install php curl git -y

RUN echo "<?php phpinfo();" >> htdocs/phpinfo.php 


RUN curl -sS https://getcomposer.org/installer -o composer-setup.php  &&   php composer-setup.php --install-dir=/usr/local/bin --filename=composer    &&    rm composer-setup.php
