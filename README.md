# Teaching-HEIGVD-RES-2017-Labo-HTTPInfra
# Solution

## Etape 1

Adresse IP et port sur lesquels est mappé le serveur Apache 80
- 192.168.99.100:9090

Si on veut relancer un container, il faudra le mapper sur un autre port, par exemple 9091

Adresse IP du container trouvé avec "docker inspect *nom du container*"
- 172.17.0.2
