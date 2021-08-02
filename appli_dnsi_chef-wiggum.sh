#!/bin/bash
#########################################################
## CHEF WIGGUM : Recherche les groupes LDAP d'un agent ##
#########################################################
## DNSI - POLE EXPLOITATION - EQUIPE APPLI - F. AUDEBRAND

# CONSTANTES

ldap_useradmin=manager
ldap_password=ldap_password_here
ldap_defaultuid="uid=chefwiggum75n,ou=internes,o=tiers"
ldap_groupfilter="(|(objectclass=groupofnames)(objectclass=groupofurls))"

title="Chef Wiggum 1.0"
help+="\n\nVous avez demandé la police ? Ne quittez pas !\n\nBesoin de savoir quels sont les groupes LDAP d'un agent ? Le chef mène l'enquête !"
help+="\nUsage : Repondez aux questions, avouez !!!"
help+="\n\nVersion 1.0 - F. Audebrand Pole Appli-DNSI"
help+="\nhttps://vignette.wikia.nocookie.net/les-simpson-springfield/images/3/37/Wiggum.png/revision/latest?cb=20141224131633&path-prefix=fr"

# FUNCTION

function abort_panel ()
{
whiptail --title "/!\\ $title /!\\" --msgbox "Abandon de la recherche !" --fb 13 60
}

# BESOIN D'AIDE PEUT ETRE ?

if [ "$1" ]; then 
echo '   ________         ____   _       ___                            '
echo '  / ____/ /_  ___  / __/  | |     / (_)___ _____ ___  ______ ___  '
echo ' / /   / __ \/ _ \/ /_    | | /| / / / __ `/ __ `/ / / / __ `__ \ '
echo '/ /___/ / / /  __/ __/    | |/ |/ / / /_/ / /_/ / /_/ / / / / / / '
echo '\____/_/ /_/\___/_/       |__/|__/_/\__, /\__, /\__,_/_/ /_/ /_/  '
echo '                                   /____//____/                   '	
echo -e $help;exit; fi

# QUELLE BRANCHE ? AUTHENTIFICATION POUR LA BRANCHE

branche=$(whiptail --inputbox "Pour quelle branche ?" 13 60 "tiers" --fb --title "(?) $title (?)" 3>&1 1>&2 2>&3)
if [ "$branche" = "" ] ; then abort_panel; exit;fi
ldap_useradmin=$(whiptail --inputbox "Username pour o=$branche ?" 13 60 "$ldap_useradmin" --fb --title "(?) $title (?)" 3>&1 1>&2 2>&3)
if [ "$ldap_useradmin" = "" ] ; then abort_panel; exit;fi 
ldap_password=$(whiptail --inputbox "Mot de passe $ldap_useradmin pour o=$branche ?" 13 60 "$ldap_password" --fb --title "(?) $title (?)" 3>&1 1>&2 2>&3)
if [ "$ldap_password" = "" ] ; then abort_panel; exit;fi

# ON RECUPERE LA LISTE DES GROUPES DE TOUT L'ANNUAIRE
# L'EXTRACTION EST LONGUE DONC ON PROPOSE DE REUTILISER LE FICHIER DE TRAVAIL SI IL EST PRESENT
if [ -f "/tmp/hell_dap_groups.txt" ] ; then
	hellinfo=$(ls -lh /tmp/hell_dap_groups.txt)
	if (whiptail --yesno "Le listing des groupes existe déjà :\n\n$hellinfo\n\nSouhaitez-vous le regénérer ?" 18 90 --fb --title "(?) $title (?)" 3>&1 1>&2 2>&3)
	then rebuild=1; else rebuild=0; fi
else  rebuild=1;fi

if [ "$rebuild" = 1 ]; then

clear
echo "VEUILLEZ PATIENTER (environ 20 secondes si tout va bien)...."
#echo  "Veuillez patienter, l'extraction des groupes LDAP se savoure...."
# ldif-wrap=no évite que ldapsearch formate la réponse avec une largeur de colonne par défaut sinon un pert la fin des dn trop longs
 ldapsearch  -D cn=$ldap_useradmin,o=$branche -w $ldap_password -b o=$branche -o ldif-wrap=no -LLL "$ldap_groupfilter" | grep "dn: " > /tmp/hell_dap_groups.txt

fi

# CONTROLE DE L'EXTRACTION DES GROUPES

nbgroup=$(cat /tmp/hell_dap_groups.txt | wc -l)
if [ "$nbgroup" = 0 ] ; then 
	whiptail --title "/!\\ $title /!\\" --msgbox "Aucun groupe ?! Vérifiez le fichier \n/tmp/hell_dap_groups.txt \npuis le ldapsearch en ligne 55 du code.\nAbandon de la recherche !" 18 60 --fb
	exit
fi

whiptail --title "(i) $title (i)" --msgbox "Wahou !\nIl y a $nbgroup groupes dans l'annuaire" 13 60 --fb

# ON RECUPERE LE DN DE LA FICHE CONCERNEE

dn=$(whiptail --inputbox "Quel est le DN de la fiche traiter ? (respectez la syntaxe)" 13 60 "$ldap_defaultuid" --fb --title "(?) $title (?)" 3>&1 1>&2 2>&3)

if [ "$dn" ]; then

# LECTURE DU FICHIER DES GROUPES LIGNE PAR LIGNE
c=0
clear
echo -e "Recherche des groupes pour $dn :\n\n"
while IFS= read -r line
do

  l2=$(echo $line | sed s/'dn: '/''/g)
  l3=$(ldapsearch  -D cn=$ldap_useradmin,o=$branche -w $ldap_password -b $l2 -o ldif-wrap=no -LLL | grep $dn)
	if [ "$l3" ] ;then
	liste+="$l2\n"
	((c++))
fi
echo -n "."
done < /tmp/hell_dap_groups.txt 

echo -e "\n$liste"

if [ $c -gt 0 ] ; then plur="s"; else plur=""; fi
echo "$c groupe$plur trouvé$plur : Fin du traitement."
else abort_panel;exit
fi

