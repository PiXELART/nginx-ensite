#!/bin/bash
#
# Copyright PixiBixi 
# nGinx_enSite
# Utilisation : CF README

# CONF #
NGINX_PATH="/etc/nginx"
NGINX_AVAILABLE="$NGINX_PATH/sites-available"
NGINX_ENABLED="$NGINX_PATH/sites-enabled"
NAME=${0##*/}
SERVICE="service"
# END OF CONF # 

# COLORS #
WHITE="\033[m"
WHITE_BOLD="\033[1m"
BLUE="\033[34m"
RED="\033[31m"
YELLOW="\033[33m"
GREEN="\033[32m"
CEND="\033[0m"
# END OF COLORS #

if [[ $UID != 0 ]]; then
	echo -e "${RED}${WHITE_BOLD}$NAME doit être exécuté en root${CEND}"
	exit 1;
fi

function preCheck(){
	if [[ ! -d $NGINX_AVAILABLE ]]; then
		echo -e "${RED}${WHITE_BOLD}$NGINX_AVAILABLE inexistant${CEND}"
	fi

	if [[ ! -d $NGINX_ENABLED ]]; then
		echo -e "${RED}${WHITE_BOLD}$NGINX_ENABLED inexistant${CEND}"
	fi

	if ! [[ $(dpkg -s nginx | grep Status ) =~ "Status: install ok installed" ]]  &> /dev/null ; then
		echo -e "${RED}${WHITE_BOLD}nGinx n'est pas installé${CEND}"
	fi
}

case $1 in
	enable )
		preCheck
			# Si Argument
			if [[ -z $2 ]]; then
				echo -e "${RED}${WHITE_BOLD}Utilisation : $NAME enable nginx_block${CEND}"
				exit 1
			fi
			# Si fichier inexistant $SITES_AVAILABLE
			if [[ ! -f "$NGINX_AVAILABLE/$2" ]]; then
				echo -e "${RED}${WHITE_BOLD}Fichier $2 inexistant dans ${NGINX_AVAILABLE}${CEND}"
				exit 1
			# Si fichier existant $SITES_ENABLED
			elif [[ -f "$NGINX_ENABLED/$2" ]]; then
                echo -e "${RED}${WHITE_BOLD}Fichier $2 déjà activé${CEND}"
				exit 1
			# Sinon
			else
				echo -e "${GREEN}${WHITE_BOLD}Fichier $2 existant${CEND}"
				# Si fichier existant $SITES_ENABLED
				if [[ -f "$NGINX_ENABLED/$2" ]]; then
					echo -e "${RED}${WHITE_BOLD}Fichier $2 déjà activé${CEND}"
					exit 1
				else
					ln -s "$NGINX_AVAILABLE/$2" "$NGINX_ENABLED/$2"
					echo -e "${GREEN}${WHITE_BOLD}Block $2 activé${CEND}"
					$SERVICE nginx restart &> /dev/null
					echo -e "${GREEN}${WHITE_BOLD}nGinx redémarré${CEND}"
				fi
			fi
		;;

	disable )
		preCheck
			if [[ -z $2 ]]; then
				echo -e "${RED}${WHITE_BOLD}Utilisation : $NAME enable nginx_block${CEND}"
				exit 1
			fi

			if [[ ! -f "$NGINX_ENABLED/$2" ]]; then
				echo -e "${RED}${WHITE_BOLD}Fichier $2 inexistant dans ${NGINX_ENABLED}${CEND}"
				exit 1
			# Sinon (Si un fichier existe)
			else
				if [[ -L "$NGINX_ENABLED/$2" ]]; then # Lien symbolique + fichier existe
					echo -e "${GREEN}Fichier $NGINX_ENABLED/$2 supprimé${CEND}"
					/bin/rm "$NGINX_ENABLED/$2"
					$SERVICE nginx restart
					echo -e "${GREEN}Redémarrage de nginx${CEND}"
				elif [[ -h "$NGINX_ENABLED/$2" ]]; then # Lien symbolique + fichier inexexistant
					echo -e "${RED}Attention: Fichier ${SITES_AVAILABLE}/${2} inexexistant${CEND}"
					/bin/rm "$NGINX_ENABLED/$2"
				else
					echo -e -n "${RED}$NGINX_ENABLED/$2 n'est pas un lien symbolique vers $SITES_AVAILABLE, souhaitez-vous le supprimer ? (YES|NO)${CEND}"
					read CHOICE_RM
					if [[ $CHOICE_RM =~ yes ]]; then
						/bin/rm "$NGINX_ENABLED/$2"
						echo -e "${GREEN}$NGINX_ENABLED/$2 a été supprimé${CEND}"
						$SERVICE nginx restart
						echo -e "${GREEN}Redémarrage de nginx${CEND}"
					else
						echo -e "${RED}$NGINX_ENABLED/$2 n'a pas été supprimé${CEND}"
						exit 1
					fi
				fi
			fi


		;;

	list )
		preCheck
		echo -e "${YELLOW}${WHITE_BOLD} => $NGINX_AVAILABLE${WHITE}"
		/bin/ls $NGINX_AVAILABLE 2>/dev/null

		echo -e "${YELLOW}${WHITE_BOLD} => $NGINX_ENABLED${WHITE}"
		/bin/ls $NGINX_ENABLED 2>/dev/null
		;;

	* )
		echo -e "${YELLOW}${WHITE_BOLD}Usages possibles :"
		echo -e "${WHITE_BOLD}${BLUE}enable :${WHITE} enable nginx block${CEND}"
		echo -e "${WHITE_BOLD}${BLUE}disable :${WHITE} disable nginx block${CEND}"
		echo -e "${WHITE_BOLD}${BLUE}list :${WHITE} list all nginx blocks${CEND}"
esac
