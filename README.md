# Wolk Software

# Script para backup de bases mysql.
2013-2014

Atualmente o script trabalha com 2 arquivos, um script executável e um script de configuração.
O script de configuração, deve ser colocado em /etc/.
* Ex. /etc/mdbbkp.conf

O script executável deve ser colocado em /bin/.
* Ex. /bin/mdbbkp.sh

O arquivo SH lê os parâmetros setados no .conf e executa de acordo com o valor setado.

A configuração padrão, é para fazer dump de todas as bases, em arquivos separados, para caso de restauração de uma unica base, não se tornar um trabalho impossível.
