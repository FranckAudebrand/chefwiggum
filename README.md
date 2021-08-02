# Chef Wiggum 

est un script BASH à utiliser sur un serveur LDAP.

Son fonctionnement est :

- Extraction vers un fichier temporaire de l'ensemble des groupes LDAP de la branche sélectionnée,
- Test pour chaque groupe de l’existence du DN de la fiche souhaitée

Le résultat apparaît à l'écran simplement.

L'extraction des groupes pouvant être longue, si celle-ci a déjà été faite (présence du fichier temporaire), le script propose de le réutiliser afin de gagner du # temps et de ne pas charger le serveur.

Mise en oeuvre :

Récupérer le script :

<pre> git clone https://github.com/FranckAudebrand/chefwiggum </pre>

Editez les lignes 9 à 12 :

<pre>
ldap_useradmin=manager
ldap_password=ldap_password_here
ldap_defaultuid="uid=chefwiggum75n,ou=internes,o=tiers"
ldap_groupfilter="(|(objectclass=groupofnames)(objectclass=groupofurls))"
</pre>

avec vos paramètres. 
La ligne ldap_groupfilter est utilisée pour lister les groupes statiques (groupofnames) ET les groupes dynamiques (groupofurls) : Adaptez la requête LDAP à vo besoin si nécessaire.
