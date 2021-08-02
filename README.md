#   ________         ____   _       ___                            
#  / ____/ /_  ___  / __/  | |     / (_)___ _____ ___  ______ ___  
# / /   / __ \/ _ \/ /_    | | /| / / / __ `/ __ `/ / / / __ `__ \ 
#/ /___/ / / /  __/ __/    | |/ |/ / / /_/ / /_/ / /_/ / / / / / / 
#\____/_/ /_/\___/_/       |__/|__/_/\__, /\__, /\__,_/_/ /_/ /_/  
#                                   /____//____/                   
# 
# 
# Chef Wiggum est un script BASH à utiliser sur un serveur LDAP.
# 
# Son fonctionnement est :
# 
# - Extraction vers un fichier temporaire de l'ensemble des groupes LDAP de la branche sélectionnée,
# - Test pour chaque groupe de l’existence du DN de la fiche souhaitée
#  
# Le résultat apparaît à l'écran simplement.
# 
# L'extraction des groupes pouvant être longue, si celle-ci a déjà été faite (présence du fichier temporaire), le script propose de le réutiliser afin de gagner du # temps et de ne pas charger le serveur.
