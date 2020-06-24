#!/bin/bash

#Utilidades para instalar Sitel y PiActivia en Linux.
#Created By ChichoCoria

opcion=0
validalicencia='^[A-Z0-9]{8}$'
#Funcion para instalar gcc-multilib
install_multilib () {
echo -e  "\Instalando librerias para compatibilidad, java y samba."
apt-get update
apt-get install sudo
sudo apt-get install gcc-multilib
	if [ $? -eq 0 ]; then
		echo "Se instalo gcc-multilib con exito"
	else
		echo "Fallo la instalacion"
	fi
sudo apt-get install default-jdk
sudo apt-get install samba
sudo apt-get install unzip

sudo  cat /etc/samba/smb.conf | grep "ITC Soluciones"
	if [ $? -eq 1 ]; then
		echo "Creando directorio /data y  /activia"
		echo -e "\n[data] \ncomment = OSDE - ITC Soluciones \npath = /home/share/data \npublic = yes \nwritable = yes \nforce user = itc \nforce group = nogroup \nprintable = no \nbrowseable = yes \ncreate mask = 0777" | sudo tee -a /etc/samba/smb.conf
		echo -e "\n[activia] \ncomment = OSDE - ITC SOLUCIONES \npath = /home/share/activia \npublic = yes \nwritable = yes \nforce user = itc \nforce group = nogroup \nprintable = no \nbrowseable = yes \ncreate mask = 0777" | sudo tee -a /etc/samba/smb.conf
		echo "Restart Samba Service"
		sleep 2
		echo "Creando directorio Sitel"
		sudo mkdir -p /home/share/data/term00/upload /home/share/data/term00/download /home/share/data/tx
		sleep 2
		echo "Creando directorio Activia en caso de usar piactivia"
		sudo mkdir -p /home/share/activia /home/share/activia/ter1 /home/share/activia/ter2 /home/share/activia/ter3
		sleep 2
		echo "Descomprimiendo archivos ZIP"
		sudo unzip Sitel-rh8-1.5.1.zip -d /home/itc/
		sudo unzip Jactivia.zip -d /home/itc/
		sleep 2
		echo "Cambiando propietario y grupo de los directorios. Cambiando permisos."
		sudo chown -R itc:itc /home/share/
		sudo chmod -R 755 /home/share/
		sudo chmod -R 755 /home/itc/
		sleep 2
		echo "Se realizo la instalacion y Configuracion con exito."
		sleep 3
	else
		echo "Ya existe el directorio /data y /activia"
	fi
}

register_lic (){
echo "Registrar Licencia: Debe contener 8 digitos, solo numeros y letras en mayuscula"
#Validacion de licencia
	read -p "Ingrese la licencia a registrar: " licencia
	if [[ $licencia =~ $validalicencia ]] ;then
		echo "Registrando Licencia"
		sudo /home/itc/regsitel -r 200.47.62.201 -p 8315 -l $licencia -n 'CPKCP8K0' -t /home/share/data/ -s /home/itc/sitel -a -ttcp -a -x10 -a -l/var/log/regsitel.log
		echo "La licencia agregada es: "$licencia
		sleep 3
	else
		echo "La licencia debe contener 8 digitos y solo letras en mayuscula y numeros"
	fi
}

iniciar_txfinder () {
sudo cat /var/spool/cron/crontabs/root | grep reboot
        if [ $? -eq 1 ]; then
		echo "Creando job en Crontab"
	    (crontab -l 2>/dev/null ; echo -e "# START CRON JOB LIST\n@reboot /home/itc/txfinder /home/share/data /home/itc/sitel -X10 -d -l /var/log/txfinder.log -a -t -a tcp -a -l -a /var/log/txfinder.log -a -x -a 10\n@reboot /home/itc/regsitel -r 200.47.62.201 -p 8315 -l CPKCP8K0 -n 'PRUEBA' -t /home/share/data/ -s /home/itc/sitel -a -ttcp -a -x10 -a -l/var/log/regsitel.log\n@reboot /home/itc/jactivia/setup/jactivia.sh\n# END CRON JOB LIST") | crontab -
		echo "Reiniciando para ejecutar cambios..."
		sleep 4
		reboot
	else
		echo "Ya esta creada la tarea en Crontab"
		sleep 3
	fi
}

prueba_svl () {
echo "305467412536105316067195620220301AA  000000MN00000000000000            000000000000            00000000000000000  %b&afiliado prueba autoriz.autom.-2031019991060301&_.610531606719562017.991010150120000008_         LDOCUMENTO PRUEBA.TXT                                    0000000000000000C" > /home/itc/_svl.1
echo "V1071101" > /home/itc/_svl.0
sudo cp /home/itc/_svl.* /home/share/data/term00/upload/ ; touch /home/share/data/tx/term00 ; timeout 15 tail -f /var/log/txfinder.log
}

salir () {
echo "Saliendo del Programa"
sleep 2
exit 0
}
while :
do
	clear
	echo "-----------------------------"
	echo " Utilidades Sitel Pi Activia "
	echo "-----------------------------"
	echo "        Menu Principal       "
	echo "-----------------------------"
	echo "1-Instalar compatibiliad binarios, Java JDK y Samba"
	echo "2-Registrar Licencia"
	echo "3-Crear tarea en Crontab de TXFinfer y Plugin"
	echo "4-Realizar prueba de funcionamiento con SVL"
	echo "5-Salir del Programa de utilidades"

	read -n1 -p "Ingrese una Opcion [1-3]: " opcion

	case $opcion in
		1) install_multilib
		   sleep 5 
		;;
		2) register_lic
		   sleep 3
		;;
		3) iniciar_txfinder
		   sleep 3
		;;
		4) prueba_svl
		   sleep 3
		;;
		5) salir

	esac

done
