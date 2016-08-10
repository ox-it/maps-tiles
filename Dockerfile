FROM kartoza/tilemill

# replace the run script with our own version which sets the correct ip addresses
ADD maps-ox/run_tilemill.sh /run_tilemill.sh

RUN sudo apt-get update && sudo apt-get install curl nano -y

CMD /bin/bash /run_tilemill.sh
