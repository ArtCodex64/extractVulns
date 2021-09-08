#!/bin/bash

if [[ "$(id -u)" == "0" ]];then
	grayColour="\e[0;37m\033[1m"
	endColour="\033[0m\e[0m"

	file="$1"
	ports="$(cat $file | grep -oP '\d{1,5}/open' | awk '{print $1}' FS='/' | xargs | tr ' ' ',')"
	services="$(cat $file | grep -oP '\/\/[a-zA-Z0-9\-]*\/\/' | sed 's/\/\///' | xargs | tr ' ' ',')"
	os="$(cat $file | grep -oE '[^/]+[/]+[a-zA-Z0-9\-]*[,]+' | xargs )"
	IFS=',' read -ra beforeServices <<< "$services"
	IFS=',' read -ra cleanPorts <<< "$ports"
	IFS=',' read -ra osSys <<< "$os"
	declare -a cleanServices
	declare -a uniqServices
	declare -a matrix
	echo -e "#PORTS AND SERVICES" >> portsServices.tmp
	echo -e "PORTS\tSERVICES\t\tOperatingSystems" >> portsServices.tmp
	for (( a = 0 ; a < ${#beforeServices[@]} ; a++ ));do
		before=${beforeServices[$a]}
		after=${before%??}
		cleanServices+=( "$after" )
		beforeS=${osSys[$a]}
        	afterOS=${beforeS%?}
        	cleanOS+=( "$afterOS" )
	done

	c="0"
	d="0"

	for (( b = 0; b < ${#cleanServices[@]}; b++ ));do
		matrix+=( "${cleanPorts[$b]},${cleanServices[$b]},${cleanOS[$b]}" )
	done
	declare -a files
	for (( e = 0 ; e < ${#matrix[@]} ; e++ ));do
		IFS=',' read -ra segmento <<< "${matrix[$e]}"

		if [[ ${segmento[2]} == *Micro* ]];then
			operatingSystem+=( "Windows" )
		elif [[ ${segmento[2]} == *micro* ]];then
			operatingSystem+=( "Windows" )
		elif [[ ${segmento[2]} == *Windows* ]];then
			operatingSystem+=( "Windows" )
		elif [[ ${segmento[2]} == *windows* ]];then
			operatingSystem+=( "Windows" )
		fi

		fileName="$(echo ${segmento[2]} | tr ' ' '-')"

		echo -en "${grayColour}${segmento[0]}${endColour}" >> portsServices.tmp
        	echo -en "\t${grayColour}${segmento[1]}${endColour}" >> portsServices.tmp
        	echo -e "\t\t\t${grayColour}${segmento[2]}${endColour}" >> portsServices.tmp
        	searchsploit "${segmento[1]}" "${operatingSystem[$e]}" >> "./VULNS/${segmento[0]}-$fileName.txt"
		files+=( "./VULNS/${segmento[0]}-$fileName.txt" )
		unset $segmento
		unset $fileName
	done

	count="$(ls ./VULNS/* | wc -l)"
	for (( f = 0; f < $count ; f++ ));do
		grep -q 'Exploits: No Results' ${files[$f]} #> /dev/null 2>/dev/null
		deleteFile00="$(echo $?)"
		grep -q 'Shellcodes: No Results' ${files[$f]} #>/dev/null 2>/dev/null
		deleteFile01="$(echo $?)"
		grep -q 'Papers: No Results' ${files[$f]} #> /dev/null 2>/dev/null
		deleteFile02="$(echo $?)"

		if [[ $deleteFile00 == "0" && $deleteFile01 == "0" && $deleteFile02 ==   "0" ]];then
			rm ${files[$f]}
		fi
	done
	cat portsServices.tmp ; rm portsServices.tmp;
else
	echo "[*]Ejecuta el script como root."
fi
exit 0
