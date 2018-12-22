#/bin/bash!

docker run -d \
	--name fhem \
	-p 8083:8083 \
	-p 8084:8084 \
	-p 8085:8085 \
	--device=/dev/serial/by-id/usb-FTDI_FT231X_USB_UART_DN028GKE-if00-port0 \
	-v /srv/docker/daten_docker/fhem/fhem.cfg:/opt/fhem/fhem.cfg \
        -v /srv/docker/daten_docker/fhem/98_Hanazeder_FP10.pm:/opt/fhem/FHEM/98_Hanazeder_FP10.pm \
	-v /srv/docker/daten_docker/fhem/log:/opt/fhem/log \
	-v /etc/timezone:/etc/timezone:ro \
	-v /etc/localtime:/etc/localtime:ro \
	fhem
#        --entrypoint bash \
#        --device=/dev/serial/by-id/usb-Rademacher_DuoFern_USB-Stick_WR02H1JZ-if00-port0 \
#        --mount type=bind,source=/srv/docker/daten_docker/fhem/,target=/opt/fhem/ \

#        -v /srv/docker/daten_docker/fhem/:/opt/fhem/ \

