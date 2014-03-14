#!/bin/bash
# Script de automatização de backup
# pega os parametros setados em /etc/mdbbkp.conf
# Ordem dos acontecimentos
# 1 - verifica arquivo e pega variaveis
# 2 - cria PID
# 3 - verifica os parametros de data
# 4 - pega o nome das bases de dados
# 5 - cria diretorio e começa exportação
# 6 - gera o log
# 7 - Envia email

EXEC_MYDUMP=`which mysqldump`;
EXEC_MKDIR=`which mkdir`;
EXEC_TAR=`which tar`;

# Verificando se o arquivo conf existe
# Pegando as variaveis do arquivo
CONF=/etc/mdbbkp.conf;
if [ -f $CONF ]; then
  DIR_BKP=$(grep 'dir_bkp' $CONF | awk -F" " '{print $3 ; }');
  TIPO_DT=$(grep 'tipo_dt' $CONF | awk -F" " '{print $3 ; }');
  TIPO_DB=$(grep 'tipo_db' $CONF | awk -F" " '{print $3 ; }');
  HOST_SRV=$(grep 'host_srv' $CONF | awk -F" " '{print $3 ; }');
  HOST_USER=$(grep 'host_user' $CONF | awk -F" " '{print $3 ; }');
  HOST_PASS=$(grep 'host_pass' $CONF | awk -F" " '{print $3 ; }');
  NOME_DB=$(grep 'nome_db' $CONF | awk -F" " '{print $3 ; }');
  GERA_LOG=$(grep 'gera_log ' $CONF | awk -F" " '{print $3 ; }');
  DIR_LOG=$(grep 'dir_log' $CONF | awk -F" " '{print $3 ; }');
  EMAIL_PARA=$(grep 'email_para' $CONF | awk -F" " '{print $3 ; }');
  TIPO_EMAIL=
else
  echo "Arquivo de configuracao nao encontrado";
  exit 0;
fi

# Criando o PID e adicionando informação sobre o processo
PID=/tmp/jamantadb.pid
touch $PID
PROCESSO=`ps xua | grep jamantadb.sh | awk '{print $2}'`;
MSGPID1="Esta rodando";
MSGPID2='Processo';
MSGPID3=$PROCESSO;
MSGPID4="Jamanta Scripts";
echo "" > $PID;
echo $MSGPID1 > $PID;
echo $MSGPID2 >> $PID;
echo $MSGPID3 >> $PID;
echo $MSGPID4 >> $PID;

# Verificando tipo da data
DT_BKP=""
if [ "$TIPO_DT" = "dmy" ]; then
  DT_BKP=`date +%d-%m-%y`;
fi

if [ "$TIPO_DT" = "dmY" ]; then
  DT_BKP=`date +%d-%m-%Y`;
fi

if [ "$TIPO_DT" = "mdy" ]; then
  DT_BKP=`date +%m-%d-%y`;
fi

if [ "$TIPO_DT" = "ymd" ]; then
  DT_BKP=`date +%y-%m-%d`;
fi

#criando diretório padrão
$EXEC_MKDIR $DIR_BKP;

# Executando os procedimentos
# Pegando as bases de dados e excluindo as não necessárias do export

if [ $NOME_DB = "all" ]; then
  PEGA_BASE=`mysql -u $HOST_USER -p$HOST_PASS -e "show databases" | awk '{print $1}' | grep -v Database | grep -v mysql | grep -v information_schema | grep -v performance_schema | grep -v test`
  # Criando os diretórios do MYSQL
  $EXEC_MKDIR $DIR_BKP/dump-$DT_BKP;


  #echo ${PEGA_BASE[*]};
  for x  in $PEGA_BASE; do
    MY_DUMP=`$EXEC_MYDUMP -u $HOST_USER -p$HOST_PASS -h $HOST_SRV $x > $DIR_BKP/dump-$DT_BKP/$x-$DT_BKP.sql`;
    exec $MY_DUMP;
  done
  
  cd $DIR_BKP;
  GERA_BKP=`$EXEC_TAR -zcvf mysql-$DT_BKP.tar dump-$DT_BKP`;

  if [ "$GERA_LOG" = "sim" ]; then
    $EXEC_MKDIR /var/log/bkp_mysql;
    LOGANDO=`$EXEC_TAR -tvf $DIR_BKP/mysql-$DT_BKP.tar > /var/log/bkp_mysql/mysql-$DT_BKP.log`;
    echo $LOGANDO;
    MANDA_EMAIL=`cat /var/log/bkp_mysql/mysql-$DT_BKP.log | mail -s BKP_MYSQL_DIARIO $EMAIL_PARA`
    echo $MANDA_EMAIL;
  else
    echo "SEM LOG";
  fi
fi

# Mandando PID pro quiabo
rm -rf $PID;

exit 0
