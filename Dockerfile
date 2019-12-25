FROM httpd
EXPOSE 80
RUN apt-get update -y   &&   apt-get install apt-utils  -y
RUN apt-get install php curl git -y

RUN echo "<?php phpinfo();" >> htdocs/phpinfo.php 


RUN curl -sS https://getcomposer.org/installer -o composer-setup.php  &&   php composer-setup.php --install-dir=/usr/local/bin --filename=composer    &&    rm composer-setup.php

#this will Fail:
###RUN composer global require drush/drush:dev-master
# (due to some other missing dependencies natively found in the drupal image from Docker Hub)
ENV DRUSH='/root/.composer/vendor/drush/drush/drush'

# with this you aren't asked to approve the unknown host  (maybe there's a switch for that?)
COPY ssh_keys_docker/known_hosts   /root/.ssh/
# Copy your key or some group key that the staging/testing/build system has for pulling Git repos.
# in the case of your own dev system, just put your own keys there.
#COPY ssh_keys_docker/id_rsa   /root/.ssh/


#WORKDIR /var/www/html/

#RUN git clone git@.....

