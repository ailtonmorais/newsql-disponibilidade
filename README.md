<p align="center">
<br>Departamento de Computação (DComp-So)</br>
<br>Centro de Ciências e Gestão em Tecnologias (CCGT)</br>
<br>UNIVERSIDADE FEDERAL DE SÃO CARLOS - Campus Sorocaba</br><br></br>
<img src="./images/ufscar.png" width="166">
</p>

# Sobre

Tutorial que aborda NewSQL com relação a disponibilidade como parte da avaliação da disciplina de Tópicos em Banco de Dados (2020/2) - Profa. Dra. Sahudy Gonzalez, do programa de mestrado em Ciência da Computação da UFScar Sorocaba.

# NewSQL - Disponibilidade
<sub>Autor: Ailton Morais</sub>

<a id="indice"></a>
# Índice
1. [Introdução](#introducao)    
	1.1. [MySQL Cluster](#sobre-mysqlcluster)<br>
	1.2. [CockroachDB](#sobre-cockroachdb)<br>
  1.3. [Estudo de Caso](#caso)	
2. [Visão Geral](#geral)    
	2.1. [Alta Disponibilidade](#disponibilidade)<br>
    2.1.1. [MySQL Cluster](#disponibilidade-mysqlcluster)<br>
    2.1.2. [CockroachDB](#disponibilidade-cockroachdb)        
3. [Resiliência a Falhas](#resiliencia)<br>
  3.1. [MySQL Cluster](#resiliencia-mysqlcluster)<br>
  3.2. [CockroachDB](#resiliencia-cockroachdb)
4. [Instalação e Configuração](#instalacao)<br>
	4.1. [Docker](#instalacao-docker)<br>
	4.2. [MySQL Cluster](#instalacao-mysqlcluster)<br>
	4.3. [CockroachDB](#instalacao-cockroachdb)
5. [Disponibilidade na Prática](#pratica)<br>
	5.1. [MySQL Cluster](#pratica-mysqlcluster)<br>
	5.2. [CockroachDB](#pratica-cockroachdb)
6. [Benchmark - MySQL vs CockroachDB](#benchmark)
7. [Conclusão](#conclusao)
8. [Referências Bibliográficas](#referencias)

<a id="introducao"></a>
## 1. Introdução

A proposta do tutorial é apresentar o passo a passo desde a instalação, configuração, casos de uso e testes que irão ajudar a entender a abordagem da **disponibilidade** do [MySQL Cluster](https://www.mysql.com/products/cluster/) & [CockroachDB](https://www.cockroachlabs.com/product/)

<a id="sobre-mysqlcluster"></a>
### 1.1. MySQL Cluster

MySQL Cluster é um banco de dados distribuído que combina escalabilidade linear e alta disponibilidade. Foi projetado para aplicativos de missão crítica, fornece acesso em tempo real na memória com consistência transacional em conjuntos de dados particionados e distribuídos [[1]](#MySQL-2020a).

O Cluster MySQL tem replicação entre *clusters* em vários locais geográficos integrados e uma arquitetura nada compartilhada com reconhecimento de localidade de dados o que torna a escolha perfeita para execução em hardware comum e em infraestrutura em nuvem distribuída globalmente [[1]](#MySQL-2020a).

<a id="sobre-cockroachdb"></a>
### 1.2. CockroachDB

CockroachDB é um banco de dados *SQL* distribuído construído em um armazenamento de chave-valor transacional e fortemente consistente. Ele é dimensionado horizontalmente, sobrevive a falhas de disco, máquina, rack e até mesmo de *datacenter* com interrupção de latência mínima e sem intervenção manual, suporta transações *ACID* fortemente consistentes e fornece uma *API SQL* familiar para estruturar, manipular e consultar dados [[4]](#Cockroach-2020a).

<a id="caso"></a>
### 1.3. Estudo de Caso

Neste tutorial será utilizado o banco de dados do *Northwind* que foi criado pela Microsoft para atender os seus produtos, mas ao longo do tempo se tornou uma amostra bastante utilizada em tutoriais de banco de dados não desenvolvidos pela Microsoft. Dentre as amostras do banco de bados *Northwind* podemos destacar:

* Suppliers
  
* Customers
  
* Employees
  
* Products
  
* Shippers
  
* Orders

No total o banco de dados *Northwind* contém 14 tabelas. O diagrama com o relacionamento entre as tabelas pode ser visto abaixo:

<p align="center">
<img src="./images/northwind-er-diagram.png" width="974">
<br>Figura 1: Diagram ER. Fonte: (YugabyteDB 2020a)</br>
</p>

[Voltar ao índice](#indice)

<a id="geral"></a>
## 2. Visão Geral

Os bancos de dados relacionais surguiram para necessidade de armazenamento de dados, mas na época não existia as tecnologias *Web* e os diversos tipos de dispositivos que geram uma enorme quantidade de dados se compararmos com a nossa realidade atual.

Com a evolução tecnológica e o astronômico crescimento dos dispositivos móveis conectados a internet abriu caminho para a era da Internet das Coisas e já estamos vivendo mudanças significativas na sociedade. Veja algumas declarações que demonstram tal potencial:

* A  Internet das Coisas será uma revolução muito maior que a internet e os celulares juntos! [[13]](#Krco-2013);

* A Internet das Coisas representa uma nova inteligência para os negócios, é uma mudança de paradigma do consumo, uma revolução do comportamento humano, um caminho para um novo mundo onde tudo e todos estarão conectados e sem fronteiras. Um caminho para um mundo que ainda não imaginamos [[14]](#Dias-2016).

A partir destes desafios surgiram os novos sistemas de banco de dados nomeados como *NoSQL* (*Not Only SQL*). Estas soluções fornecem alta disponbilidade, escalabilidade e uma arquitetura distribuída com crescimento horizontal. Mesmo sendo capaz de manipular grandes quantidades de dados, os banco de dados *NoSQL* geralmente não possuem suporte para as propriedades *ACID* [[21]](#KNOB-2019):

* **A**tomicity: Transação deve ser executado por completo ou não executada;

* **C**onsistency: Se o resultado final não for válido ou ocorrer falha, os dados devem ser o mesmo antes do inicio da transação;

* **I**solation: Um transação em andamente não deve sofrer interferência de outra transação concorrente;

* **D**urability: Garante os dados disponíveis em definitivo.

Para quebrar alguns paradgimas foi criado os sistemas de banco de dados *NewSQL* que combinam funcionalidades do modelo relacional e *NoSQL*. Segundo [[15]](#Pavlo-2016) os sistemas *NewSQL* são soluções modernas que buscam prover o mesmo desempenho escalável dos bancos de dados *NoSQL* para cargas de trabalho *OLTP* com tı́pico suporte completo a todas as propriedades *ACID*, como encontrado nos banco de dados relacionais.

Os sistemas de banco de dados *NewSQL* são adequados para aplicações que utilizavam o *SGBD* tradicional, mas que surgiu a necessidade de escalabilidade adicional e aprimoramento de desempenho [[16]](#Yuan-2015).

Os sistemas de banco de dados *NewSQL* tem como característica a execução de transações de leitura e gravação que:

* São de curta duração;

* Atingue um pequeno subconjunto de dados;
  
* Não fazem varredura de tabela completa;

* Possuem consultas repetidas com diferentes entradas.

De acordo com [[15]](#Pavlo-2016) pode existir uma caracterização mais restrita com a implementação de um sistema de banco de dados *NewSQL* que utiliza:

* Um esquema de controle de simultaneidade sem bloqueio;

* Uma arquitetura distribuída não compartilhada.

[STONEBRAKER e CATTEL, 2011[18]](#STONEBRAKER-CATTEL-2011) definem as cinco principais características de um *SGBD NewSQL* abaixo:

1. *SQL* como o principal mecanismo de interação de aplicativos;

2. Suporte *ACID* para transações;
  
3. Um mecanismo de controle de simultaneidade não bloqueável, portanto as leituras em tempo real não entrarão em conflito com as escritas;

4. Uma arquitetura que oferece um desempenho por nó muito maior que o disponível nas soluções *SGBDs* tradicionais;

5. Uma arquitetura de escala, não compartilhada, capaz de funcionar em um grande número de nós sem sofrerem estrangulamentos.

Segundo [[15]](#Pavlo-2016) as três categorias que melhor representam os sistemas de banco de dados *NewSQL* são:

1. Sistemas inovadores construídos a partir do zero usando uma nova arquitetura;

2. *Middleware* que re-implementam a mesma infra-estrutura que foi desenvolvida na década de 2000 pelo Google e outros;

3. Ofertas de banco de dados como serviço de provedores de computação em nuvem que também são baseadas em novas arquiteturas.

Certamente podemos considerar que os sistemas de banco de dados *NewSQL* conseguem resolver os principais problemas de escalabilidade, desempenho e disponibilidade que temos no sistema relacional tradicional. Segundo [[17]](#Kaur-2017) o *NewSQL* deve ser considerado como uma alternativa ao *NoSQL* ou banco de dados relacional clássico para novos aplicativos *OLTP*.

<a id="disponibilidade"></a>
## 2.1. Alta Disponibilidade

A alta disponibilidade não está relacionada somente ao tempo que um sistema está acessível, mas também ao tempo que o sistema precisa para responder às solicitações dos usuários. Geralmente além dos testes é necessário prover componentes redundantes para obter um nível de disponibilidade alta mesmo em caso de falhas em parte da infra-estrutura.

<a id="disponibilidade-mysqlcluster"></a>
### 2.1.1. MySQL Cluster

Para garantir a alta disponibilidade o MySQL Cluster se apoia em [[2]](#MySQL-2020b):

* **Replicação síncrona**: Os dados em cada nó de dados são replicados de forma síncrona para outro nó de dados;

* **Failover automático**: - O mecanismo de pulsação do MySQL Cluster detecta instantaneamente quaisquer falhas e faz failover automaticamente, normalmente em um segundo, para outros nós no cluster, sem interromper o serviço aos clientes;

* **Autocorreção**: Os nós com falha são capazes de se autocorrigir reiniciando automaticamente e ressincronizando com outros nós antes de reingressar no cluster, com total transparência do aplicativo;

* **Arquitetura de nada compartilhado**: Nenhum ponto único de falha, cada nó tem seu próprio disco e memória, portanto, o risco de uma falha causada por componentes compartilhados, como armazenamento, é eliminado;

* **Replicação geográfica**: A replicação geográfica permite que os nós sejam espelhados em *data centers* remotos para recuperação de desastres.

<a id="disponibilidade-cockroachdb"></a>
### 2.1.2. CockroachDB

Para o CockroachDB escalar os serviços horizontalmente é fundamental, para tal devemos utilizar a replicação dos dados em diversos servidores. Em caso de falha de um desses servidores, podemos continuar com os serviços operacionais. Segue um resumo com os principais conceitos utilizados para garantir a disponibilidade [[6]](#Cockroach-2020b):

* **Consistência**: Usa a "consistência" tanto no sentido da semântica *ACID* (*Atomicity*, *Consistency*, *Isolation*, *Durability*) quanto no teorema *CAP* (*Consistency*, *Availability*, *Partition Tolerance*), embora menos formalmente do que qualquer definição. O objetivo é garantir os dados livres de anomalias;

* **Intervalo**: Armazena todos os dados do usuário (tabelas, índices, etc.) e quase todos os dados do sistema em um mapa gigante classificado de pares de chave-valor. Este *keyspace* é dividido em "intervalos", pedaços contíguos do *keyspace*, de forma que cada chave pode sempre ser encontrada em um único intervalo;

* **Consenso**: Quando um intervalo recebe uma gravação, um quorum de nós contendo réplicas do intervalo confirma a gravação. Isso significa que seus dados são armazenados com segurança e a maioria dos nós concorda com o estado atual do banco de dados, mesmo se alguns dos nós estiverem *offline*. Quando uma gravação não chega a um consenso, o progresso de encaminhamento é interrompido para manter a consistência dentro do *cluster*;

* **Replicação**: Criação e distribuição de cópias de dados, bem como a garantia de que as cópias permaneçam consistentes. No entanto, existem vários tipos de replicação: a saber, síncrona e assíncrona. O CockroachDB usa a replicação síncrona que requer que todas as gravações se propaguem para um quorum de cópias dos dados antes de serem consideradas confirmadas;

* **Transações**: Conjunto de operações realizadas em seu banco de dados que atendem aos requisitos da semântica *ACID*. Este é um componente crucial para um sistema consistente confie no seu banco de dados;

* **Disponibilidade Multi-ativa**: O consenso de alta disponibilidade permite que cada nó no *cluster* controle leituras e gravações para um subconjunto dos dados armazenados (em uma base por intervalo).

<a id="resiliencia"></a>
## 3. Resiliência a Falhas

A confiabiliade de um sistema gerenciador de banco de dados tem um relação direta com a resiliência a falhas e redundância dos dados. Segundo [[19]](#Silberschatz-2006) a solução para o problema de confiabilidade é introduzir a redundância; ou seja, armazenamos informações extras que normalmente não são necessárias, mas que podem ser usadas no caso de falha de um disco, para recriar a informação perdida. Assim, mesmo que um disco falhe os dados não são perdidos [...]

<a id="resiliencia-mysqlcluster"></a>
### 3.1. MySQL Cluster

No mínimo de três computadores para executar um cluster viável. No entanto, o número mínimo recomendado de computadores em um Mysql Cluster NDB é quatro: um para cada para executar o gerenciamento e os nós *SQL*, e dois computadores para servir como nós de dados. O objetivo dos dois nós de dados é fornecer redundância; o nó de gerenciamento deve ser executado em uma máquina separada para garantir serviços de arbitragem contínuos no caso de um dos nós de dados falhar [[3]](#MySQL-2020c).

<p align="center">
<img src="./images/mysql_cluster_availability_v1.png" width="867">
<br>Figura 2: Sem um único ponto de falha, o MySQL Cluster oferece extrema resiliência a falhas. Fonte: (MySQL 2020b)</br>
</p>

Na figura acima temos uma arquitetura que garante nenhum ponto de falha, ou seja, cada nó tem o seu próprio disco e memória o que elimina uma falha em componentes compartilhado.

<a id="resiliencia-cockroachdb"></a>
### 3.2. CockroachDB

No mínimo de três computadores (3 nós) para executar um *cluster* viável, quando você estiver pronto para executar o seu sistema em produção em uma única região. É importante implantar pelo menos 3 nós do CockroachDB para aproveitar as vantagens dos recursos de replicação, distribuição, rebalanceamento e resiliência automáticos [[7]](#Cockroach-2020c).

<p align="center">
<img src="./images/topology_basic_production_v1.png" width="960">
<br>Figura 3: Topologia Básica. Fonte: (Cockroach 2020c)</br>
</p>

[Voltar ao índice](#indice)

<a id="instalacao"></a>
## 4. Instalação e Configuração

A distribuição [Ubuntu](https://ubuntu.com/) 18.04 do Linux será o sitema operacional utilizado em todo o processo de instalação e experimentos deste tutorial. Em meados de 2004 foi lançado a primeira versão do Ubuntu que cresceu e se tornou a mais popular distribuição *Linux Desktop* conhecida por ser considerado um sistema operacional fácil de ser usado. Todos os comandos mostrados ao longo deste tutorial podem ser reproduzidos em qualquer distribuição derivada do [Debian](https://www.debian.org/). É importante lembrar que os bancos de dados **MySQL Cluster** e **CockroachDB** serão instalados no **Docker**. Os requisitos mínimos para executar este tutorial são:

* 8 GB de RAM
* 1.80GHz de CPU
* 10GB de espaço em disco

<a id="instalacao-docker"></a>
### 4.1. Docker

O [Docker](https://www.docker.com/) é uma plataforma de código aberto desenvolvida na linguagem [go](https://golang.org/). O **Docker** permite criar, testar e implementar aplicações em um ambiente apartado da máquina original conhecido como contâiner. Isso possibilita que qualquer software seja empacotado de maneira padronizada.

<p align="center">
<img src="./images/docker_logo.png" width="336">
<br>Figura 4: Docker logo. Fonte: (Docker 2020a)</br>
</p>

Siga as instruções abaixo para instalação [[10]](#Digitalocean-2020a).

1. Execute o comando de atualização para garantir as listas de fontes mais recentes:

```bash
$ sudo apt update
```

2. Instale os pacotes de pré-requisitos para garantir que o **apt** utilize pacotes via HTTPS:

```bash
$ sudo apt install apt-transport-https ca-certificates curl software-properties-common
```

3. Adicione a chave GPG para o repositório oficial do Docker em seu sistema:

```bash
$ curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
```

4. Adicione o repositório do Docker as fontes do APT:

```bash
$ sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
```

5. Execute o comando de atualização para garantir as listas de fontes mais recentes:

```bash
$ sudo apt update
```

6. Instale o Docker:

```bash
$ sudo apt install docker-ce
```

7. Neste o ponto o Docker deve ser instalado, o *daemon* iniciado e o processo ativado. Verifique executando o comando abaixo:

```bash
$ sudo systemctl status docker
```

8. Confirme se o comando executado acima mostra o serviço como ativo, conforme exibido abaixo:

```bash
Output
● docker.service - Docker Application Container Engine
   Loaded: loaded (/lib/systemd/system/docker.service; enabled; vendor preset: enabled)
   Active: active (running) since Thu 2018-07-05 15:08:39 UTC; 2min 55s ago
     Docs: https://docs.docker.com
 Main PID: 10096 (dockerd)
    Tasks: 16
   CGroup: /system.slice/docker.service
           ├─10096 /usr/bin/dockerd -H fd://
           └─10113 docker-containerd --config /var/run/docker/containerd/containerd.toml
```

<a id="instalacao-mysqlcluster"></a>
### 4.2. MySQL Cluster

Nesta seção será mostrado o processo de instalação e configuração da versão 8.0 do [MySQL Cluster](https://dev.mysql.com/doc/refman/8.0/en/mysql-cluster.html) no **Docker**. Cada node será executado em *hosts* separados usando a configuração de rede do Docker. Utilizaremos comandos do **git**, se for necessário [clique aqui](https://gist.github.com/leocomelli/2545add34e4fec21ec16) para obter mais detalhes.

<p align="center">
<img src="./images/mysql_docker.png" width="240">
<br>Figura 5: MySQL Docker logo. Fonte: (Medium 2020a)</br>
</p>

Ao final do processo teremos 1 node de gerenciamento, 2 nodes de dados e 2 nodes *SQL* conforme ilustrado na figura abaixo.

<p align="center">
<img src="./images/NDB-cluster-diagram.jpeg" width="505">
<br>Figura 6: NDB Cluster Diagram. Fonte: (Medium 2020a)</br>
</p>

Siga os passos abaixo para instalação e configuração do MySQL Cluster [[11]](#Medium-2020a).

1. Configure a *subnet* no Docker:

```bash
$ docker network create cluster --subnet=10.100.0.0/16
```

2. Clone o MySQL do repositório oficial:

```bash
$ sudo git clone https://github.com/mysql/mysql-docker.git
```

3. Acesse o diretório do MySQL Cluster que foi criado:

```bash
$ sudo cd mysql-docker/
```

4. Crie um novo *branch*:

```bash
$ sudo git checkout mysql-cluster
```

5. Abra o arquivo "8.0/cnf/mysql-cluster.cnf" e configure conforme abaixo:

```bash 
[ndb_mgmd]
NodeId=1
hostname=10.100.0.2
datadir=/var/lib/mysql

[ndbd]
NodeId=2
hostname=10.100.0.3
datadir=/var/lib/mysql

[ndbd]
NodeId=3
hostname=10.100.0.4
datadir=/var/lib/mysql

[mysqld]
NodeId=4
hostname=10.100.0.10

[mysqld]
NodeId=5
hostname=10.100.0.11
```

6. Abra o arquivo "8.0/cnf/my.cnf" e configure conforme abaixo:

```bash
[mysqld]
ndbcluster
ndb-connectstring=10.100.0.2
user=mysql

[mysql_cluster]
ndb-connectstring=10.100.0.2
```

7. Crie a imagem no Docker (docker build -t <image_name> <Path to docker file>):

```bash
$ docker build -t mysql-cluster /opt/mysql-docker/8.0/
```
Após concluir todos os passos citados acima podemos iniciar o processo de criação dos nodes do *cluster*.

8. Crie o node de gerenciamento com o nome management1 e IP 10.100.0.2:

```bash
$ docker run -d --net=cluster --name=management1 --ip=10.100.0.2 mysql-cluster ndb_mgmd
```

9. Crie os 2 nodes de dados:

```bash
$ docker run -d --net=cluster --name=ndb1 --ip=10.100.0.3 mysql-cluster ndbd
```

```bash
$ docker run -d --net=cluster --name=ndb2 --ip=10.100.0.4 mysql-cluster ndbd
```

10. Crie os 2 nodes de *SQL*:

```bash
$ docker run -d --net=cluster --name=mysql1 --ip=10.100.0.10 -e MYSQL_RANDOM_ROOT_PASSWORD=true mysql-cluster mysqld
```

```bash
$ docker run -d --net=cluster --name=mysql2 --ip=10.100.0.11 -e MYSQL_RANDOM_ROOT_PASSWORD=true mysql-cluster mysqld
```

11. Execute o comando abaixo para acessar a *console cluster*:

```bash
$ docker run -it --net=cluster mysql-cluster ndb_mgm
```

A *console* de gerenciamento do *cluster* será iniciada.

```bash
[Entrypoint] MySQL Docker Image 8.0.22-1.1.18-cluster
[Entrypoint] Starting ndb_mgm
-- NDB Cluster -- Management Client --
ndb_mgm>
```

12. Execute o comando "*show*" para verificar o status dos nodes do *cluster*:

```bash
ndb_mgm> show
```

Confirme se todos os nodes estão em execução.

```bash
Connected to Management Server at: 10.100.0.2:1186
Cluster Configuration
---------------------
[ndbd(NDB)]	2 node(s)
id=2	@10.100.0.3  (mysql-8.0.22 ndb-8.0.22, Nodegroup: 0, *)
id=3	@10.100.0.4  (mysql-8.0.22 ndb-8.0.22, Nodegroup: 0)

[ndb_mgmd(MGM)]	1 node(s)
id=1	@10.100.0.2  (mysql-8.0.22 ndb-8.0.22)

[mysqld(API)]	2 node(s)
id=4	@10.100.0.10  (mysql-8.0.22 ndb-8.0.22)
id=5	@10.100.0.11  (mysql-8.0.22 ndb-8.0.22)

ndb_mgm>
```

Na sequência vamos configurar os nodes MySQL para que permitir o *login* remoto no banco de dados. Os nodes *SQL* foram criados com senha randômica.

13. Recupere a senha padrão do 1° node MySQL (docker logs <node_name> 2>&1 | grep PASSWORD):

```bash
$ docker logs mysql1 2>&1 | grep PASSWORD
```

A senha randômica padrão será exibida.

```bash
[Entrypoint] GENERATED ROOT PASSWORD: EaXaS)eWyx%eLULiM0c@HAMoNXLu
```

14. Acesse o 1° node MySQL (docker exec -it <node_name> mysql -uroot -p):

```bash
$ docker exec -it mysql1 mysql -uroot -p
```

15. Digite a senha padrão do 1° node MySQL:

```bash
$ Enter password:
```

O *console* do 1° node do MySQL será exibido.

```bash
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 79
Server version: 8.0.22-cluster MySQL Cluster Community Server - GPL

Copyright (c) 2000, 2020, Oracle and/or its affiliates. All rights reserved.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.
```

16. Altere a senha padrão do 1° node MySQL:

```bash
mysql> ALTER USER 'root'@'localhost' IDENTIFIED BY 'MyNewPass'; 
```

17. Atualize os privilégios de acesso:

```bash
mysql> flush privileges; 
```
**Repita os passos 13 a 17 para o 2° node mysql do cluster.**

<a id="instalacao-cockroachdb"></a>
### 4.3. CockroachDB

Nesta etapa iremos instalar e configurar a versão 20.2.2 do **CockroachDB** no **Docker**. Cada node será executado em *hosts* separados usando a configuração de rede do Docker.

<p align="center">
<img src="./images/cockroachdb_logo.png" width="568">
<br>Figura 7: Cockroach logo. Fonte: (Cockroach 2020a)</br>
</p>

Ao final do processo teremos 3 nodes e cada node terá uma instância de banco de dados conforme podemos ver na figura abaixo.

<p align="center">
<img src="./images/ui_cluster_overview_3_nodes.png" width="505">
<br>Figura 8: Start a Cluster in Docker. Fonte: (Cockroach 2020c)</br>
</p>

Aplique a sequência de comandos abaixo para ter todos os nodes em operacão [[7]](#Cockroach-2020c).

1. Baixe a imagem do cockroachdb no Docker:

```bash
$ sudo docker pull cockroachdb/cockroach:v20.2.2 
```

2. Crie a rede no Docker:

```bash
$ docker network create -d bridge roachnet 
```

3. Inicie o 1° node:

```bash
$ docker run -d \
--name=roach1 \
--hostname=roach1 \
--net=roachnet \
-p 26257:26257 -p 8080:8080  \
-v "${PWD}/cockroach-data/roach1:/cockroach/cockroach-data"  \
cockroachdb/cockroach:v20.2.2 start \
--insecure \
--join=roach1,roach2,roach3
```

* Antes de iniciar os demais nodes, vamos entender cada parâmetro do comando acima.
  * **docker run**: Comando Docker que inicia um novo *container*;
  * **-d**: Esta *flag* permite rodar o comando em *background*;
  * **--name**: O nome do *container*;
  * **--hostname**: Este é um identificador único utilizado para juntar outros nodes no *cluster*;
  * **--net**: O nome do identificador de rede criado no passo 1;
  * **-p 26257:26257 -p 8080:8080**: Porta de comunicação com o node e de requisição *HTTP*;
  * **-v "${PWD}/cockroach-data/roach1:/cockroach/cockroach-data"**: Caminho de armazenamento do *log* do node;
  * **cockroachdb/cockroach:v20.2.2 start --insecure**: Comando que inicia o node em modo inseguro; 
  * **--join**: Lista de *hostnames* que compoem o *cluster*.  

4. Inicie o 2° node:

```bash
$ docker run -d \
--name=roach2 \
--hostname=roach2 \
--net=roachnet \
-p 26257:26257 -p 8080:8080  \
-v "${PWD}/cockroach-data/roach2:/cockroach/cockroach-data"  \
cockroachdb/cockroach:v20.2.2 start \
--insecure \
--join=roach1,roach2,roach3
```
5. Inicie o 3° node:

```bash
$ docker run -d \
--name=roach3 \
--hostname=roach3 \
--net=roachnet \
-p 26257:26257 -p 8080:8080  \
-v "${PWD}/cockroach-data/roach3:/cockroach/cockroach-data"  \
cockroachdb/cockroach:v20.2.2 start \
--insecure \
--join=roach1,roach2,roach3
```

6. Acesse o 1° node do cockroach (docker exec -it <node_name> ./cockroach init --insecure):

```bash
$ docker exec -it roach1 ./cockroach init --insecure
```
Execute o comando abaixo para verificar detalhes do node iniciado.

```bash
$ grep 'node starting' cockroach-data/roach1/logs/cockroach.log -A 11
```

O resultado deve ser parecido com o *log* abaixo.

```bash
CockroachDB node starting at 2021-01-02 21:36:24.902390034 +0000 UTC (took 11.9s)
build:               CCL v20.2.2 @ 2020/11/25 14:45:44 (go1.13.14)
webui:               ‹http://roach1:8080›
sql:                 ‹postgresql://root@roach1:26257?sslmode=disable›
RPC client flags:    ‹/cockroach/cockroach <client cmd> --host=roach1:26257 --insecure›
logs:                ‹/cockroach/cockroach-data/logs›
temp dir:            ‹/cockroach/cockroach-data/cockroach-temp236940084›
external I/O path:   ‹/cockroach/cockroach-data/extern›
store[0]:            ‹path=/cockroach/cockroach-data›
storage engine:      pebble
status:              restarted pre-existing node
clusterID:           ‹fc1b7739-d5bd-4e2b-a2b6-6d93ae12bc9a›
```

**Caso seja necessário, repita o passo 6 para acessar o 2° e 3° node do cockroach.** 

[Voltar ao índice](#indice)

<a id="pratica"></a>
## 5. Disponibilidade na Prática

A disponibilidade é um fator crítico que deve ser considerado ao escolher um banco de dados. Certamente diversos fatores podem influenciar nesta escolha, mas conforme já foi detalhado ao longo deste material temos fatores importantes que tornam o banco de dados mais resiliente e disponível sempre que seja necessário consultar os dados. 

Nas seções anteriores mergulhamos em todas as características relevantes dos bancos de dados que foram escolhidos para este tutorial e foi mostrado com detalhes os passos para instalação e configuração de cada um deles. A disponibilidade do banco de dados é um processo que envolve a melhor escolha possível para o negócio em questão, uma boa definição da arquitetura e infra-estrutura adequada.

Na disponibilidade na pŕatica, vamos explorar o conceito de **replicação** que é realizado de forma síncrona pelos bancos de dados deste estudo. Neste caso iremos criar um novo *database* em um node e confirmar se o dado foi replicado para os demais nodes do *cluster*. Para validar o conceito de ***failover* automático** vamos parar um node do cluster e verificar na ferramenta de monitoramento disponibilizada pelo banco de dados se o node é detectado como indisponível para uso. O nosso último teste será com o conceito de **autocorreção**, tendo o objetivo de confirmar se ao reiniciar um node que esteja indisponível o banco de dados primeiro atualiza este node com os dados mais recentes antes de permitir o reingresso no *cluster*.

A partir de agora vamos mostrar a disponibilidade com foco na redundância, já que construimos este caminho tendo uma estrutura resiliente e redundante para os banco de dados deste estudo.

<a id="pratica-mysqlcluster"></a>
### 5.1. MySQL Cluster

Na seção de [(Alta Disponibilidade)](#disponibilidade), foi mostrado que o MySQL Cluster se apoia na replicação, *failover* automático, autocorreção, arquitetura sem compartilhamento e replicação geográfica para garantir um alto nível de disponibilidade. Acompanhe na prática alguns destes conceitos:

1. **Replicação** - A replicação é realizada de forma síncrona para os nós de dados. É importante lembrar que temos 2 nós de dados e 2 nós *SQL* que podem ser acessados diretamente pelas aplicações dependendo da arquitetura de acesso que será definida. Para confirmar os nodes existentes execute o comando abaixo.

```bash
$ docker ps
```
O resultado deve ser similar ao resultado mostrado.

```bash
CONTAINER ID   IMAGE           COMMAND                  CREATED       STATUS                          PORTS                                     NAMES
ba2c07ad51da   mysql-cluster   "/entrypoint.sh mysq…"   3 weeks ago   Up About a minute (healthy)     1186/tcp, 2202/tcp, 3306/tcp, 33060/tcp   mysql2
56887df6ca9b   mysql-cluster   "/entrypoint.sh mysq…"   3 weeks ago   Up About a minute (healthy)     1186/tcp, 2202/tcp, 3306/tcp, 33060/tcp   mysql1
49b02cc3e06a   mysql-cluster   "/entrypoint.sh ndbd"    3 weeks ago   Up About a minute (unhealthy)   1186/tcp, 2202/tcp, 3306/tcp, 33060/tcp   ndb2
c5e38486e34f   mysql-cluster   "/entrypoint.sh ndbd"    3 weeks ago   Up About a minute (unhealthy)   1186/tcp, 2202/tcp, 3306/tcp, 33060/tcp   ndb1
7b81a0345ee7   mysql-cluster   "/entrypoint.sh ndb_…"   3 weeks ago   Up About a minute (unhealthy)   1186/tcp, 2202/tcp, 3306/tcp, 33060/tcp   management1
```

Também é possível acessar o *console* de gerenciamento do Mysql Cluster. Execute o comando abaixo para iniciar o *NDB Manager*.

```bash
$ docker run -it --net=cluster mysql-cluster ndb_mgm
```

A tela de *console* deve ser exibida.

```bash
[Entrypoint] MySQL Docker Image 8.0.22-1.1.18-cluster
[Entrypoint] Starting ndb_mgm
-- NDB Cluster -- Management Client --
ndb_mgm>
```

Execute o comando *show* para verificar o status do *cluster*.

```bash
ndb_mgm> show
```
Veja o resultado do comando.

```bash
Connected to Management Server at: 10.100.0.2:1186
Cluster Configuration
---------------------
[ndbd(NDB)]	2 node(s)
id=2	@10.100.0.3  (mysql-8.0.22 ndb-8.0.22, Nodegroup: 0, *)
id=3	@10.100.0.4  (mysql-8.0.22 ndb-8.0.22, Nodegroup: 0)

[ndb_mgmd(MGM)]	1 node(s)
id=1	@10.100.0.2  (mysql-8.0.22 ndb-8.0.22)

[mysqld(API)]	2 node(s)
id=4	@10.100.0.10  (mysql-8.0.22 ndb-8.0.22)
id=5	@10.100.0.11  (mysql-8.0.22 ndb-8.0.22)

ndb_mgm>
```

Caso os nodes não estejam ativos, execute o comando abaixo para reiniciar os nodes.

```bash
$ docker start management1 ndb1 ndb2 mysql1 mysql2
```

Para apresentar o conceito de replicação vamos criar o *database northwind* no node 1 e mostrar o resultado da replicação. Antes de executar, veja os banco de dados que temos nos nodes *SQL*.

```bash
mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| bank               |
| information_schema |
| mysql              |
| ndbinfo            |
| performance_schema |
| sys                |
+--------------------+
6 rows in set (0.01 sec)
```
Agora vamos acessar o 1° node *SQL* (docker exec -it <node_name> mysql -uroot -p).

```bash
$ docker exec -it mysql1 mysql -uroot -p
```

Crie o banco de dados do nosso estudo de caso.

```bash
mysql> create database northwind;
Query OK, 1 row affected (0.38 sec)
```

Acessando o 2° node *SQL* é possível confirmar que o comando foi replicado.

```bash
mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| bank               |
| information_schema |
| mysql              |
| ndbinfo            |
| northwind          |
| performance_schema |
| sys                |
+--------------------+
7 rows in set (0.01 sec)
```

2. **Failover automático** - O Mysql Cluster detecta automaticamente as falhas e faz o *failover* automático para os demais nós disponíveis do *cluster* sem interromper o serviço ao usuário.

Para estes testes vamos interromper 1 nó de dado e 1 nó *SQL*.

```bash
$ docker stop mysql1 ndb2
```

Tente acessar o 1° node *SQL*.

```bash
$ docker exec -it mysql1 mysql -uroot -p
```

O resultado será:

```bash
Error response from daemon: Container 56887df6ca9b1a3da24043b004fa1be4500b6e09dd078a522a54f3daed08cb31 is not running
```

Vamos verificar o status do *cluster* novamente.

```bash
ndb_mgm> show
```
Veja o resultado do comando. Note que temos 2 nodes que não estão sendo executados no momento e que foram detectados automaticamente no *console* de gerenciamento do *cluster*.

```bash
Cluster Configuration
---------------------
[ndbd(NDB)]	2 node(s)
id=2	@10.100.0.3  (mysql-8.0.22 ndb-8.0.22, Nodegroup: 0, *)
id=3 (not connected, accepting connect from 10.100.0.4)

[ndb_mgmd(MGM)]	1 node(s)
id=1	@10.100.0.2  (mysql-8.0.22 ndb-8.0.22)

[mysqld(API)]	2 node(s)
id=4 (not connected, accepting connect from 10.100.0.10)
id=5	@10.100.0.11  (mysql-8.0.22 ndb-8.0.22)

ndb_mgm>
```

3. **Autocorreção** - Quando um node que possue os dados replicados fica indisponível é importante garantir que antes de reingressar no cluster esteja com os dados atualizados. No caso do MySQL Cluster faz este trabalho com transparência sem a necessidade de intervenção manual dos usuários.

É importante lembrar que no momento temos 1 node de dados e 1 node *SQL* fora de operação. Para provar o conceito de autocorreção vamos criar as tabelas e inserir dados no banco de dados *northwind* usando o 2° node *SQL* do *cluster*.

Acesse o 2° node *SQL*.

```bash
$ docker exec -it mysql2 mysql -uroot -p
```

Acesse o banco de dados *northwind*.

```bash
mysql> use northwind
```

Execute os [comandos](https://github.com/ailtonmorais/newsql-disponibilidade/blob/master/sample/northwind-tables-mysql.sql) de *create* para criar as tabelas:

Importante: Para utilizar os recursos do MySQL Cluster todas as tabelas devem obrigatoriamente ter o **ENGINE=NDBCLUSTER**.

Execute os [comandos](https://github.com/ailtonmorais/newsql-disponibilidade/blob/master/sample/northwind-data-mysql.sql) de *insert* para popular as tabelas categories, suppliers e products:

Agora vamos reiniciar o node de dados e *SQL* que estão fora de operação.

```bash
$ docker start mysql1 ndb2
```

Se a sua console já esteja aberta, aguarde a exibição da mensagem abaixo.

```bash
ndb_mgm> Node 3: Started (version 8.0.22)
```

Caso contrário, verifique o status executando comando *show* na *console* de gerenciamento do *cluster*.

```bash
ndb_mgm> show
Cluster Configuration
---------------------
[ndbd(NDB)]	2 node(s)
id=2	@10.100.0.3  (mysql-8.0.22 ndb-8.0.22, Nodegroup: 0, *)
id=3	@10.100.0.4  (mysql-8.0.22 ndb-8.0.22, Nodegroup: 0)

[ndb_mgmd(MGM)]	1 node(s)
id=1	@10.100.0.2  (mysql-8.0.22 ndb-8.0.22)

[mysqld(API)]	2 node(s)
id=4	@10.100.0.10  (mysql-8.0.22 ndb-8.0.22)
id=5	@10.100.0.11  (mysql-8.0.22 ndb-8.0.22)
```

Chegou o momento de acessar o 1° node *SQL* e confirmar a **autocorreção** do node com os dados replicados.

```bash
$ docker exec -it mysql1 mysql -uroot -p
```

Veja o resultado das tabelas criadas e os dados inseridos com os comandos listados abaixo.

```bash
mysql> use northwind;
```

Liste as tabelas replicadas para o 1° node *SQL*.

```bash
mysql> show tables;
```

O retorno deve ser:

```bash
+------------------------+
| Tables_in_northwind    |
+------------------------+
| categories             |
| customer_customer_demo |
| customer_demographics  |
| customers              |
| employee_territories   |
| employees              |
| order_details          |
| orders                 |
| products               |
| region                 |
| shippers               |
| suppliers              |
| territories            |
| us_states              |
+------------------------+
14 rows in set (0.00 sec)

mysql>
```

Agora confirme se os dados inseridos foram replicados.

```bash
mysql> select count(*) from categories;
```

Retorno:

```bash
+----------+
| count(*) |
+----------+
|        8 |
+----------+
1 row in set (0.00 sec)
```

```bash
mysql> select count(*) from suppliers;
```

Retorno:

```bash
+----------+
| count(*) |
+----------+
|       29 |
+----------+
1 row in set (0.00 sec)
```

```bash
mysql> select count(*) from products;
```

Retorno:

```bash
+----------+
| count(*) |
+----------+
|       77 |
+----------+
1 row in set (0.00 sec)
```

<a id="pratica-cockroachdb"></a>
### 5.2. CockroachDB

A replicação, distribuição, rebalanceamento e resiliência automáticos são pontos fortes do CockroachDB para garantir um alto nível de disponibilidade. Vamos ver alguns conceitos na prática:

Importante lembrar que temos 3 nodes disponíveis para os nossos testes.

1. **Replicação** - Utiliza a replicação síncrona e requer que todas as gravações se propaguem para um quorum de cópias dos dados antes de serem consideradas confirmadas. Para confirmar os nodes existentes execute o comando abaixo.

```bash
$ docker ps
```
O resultado deve ser similar ao resultado mostrado.

```bash
CONTAINER ID   IMAGE                           COMMAND                  CREATED       STATUS          PORTS                                              NAMES
e9db89e8f36f   cockroachdb/cockroach:v20.2.2   "/cockroach/cockroac…"   3 weeks ago   Up 5 seconds    8080/tcp, 26257/tcp                                roach3
8dc3754dadb1   cockroachdb/cockroach:v20.2.2   "/cockroach/cockroac…"   3 weeks ago   Up 7 seconds    8080/tcp, 26257/tcp                                roach2
44ce3d718ba7   cockroachdb/cockroach:v20.2.2   "/cockroach/cockroac…"   3 weeks ago   Up 11 seconds   0.0.0.0:8080->8080/tcp, 0.0.0.0:26257->26257/tcp   roach1
```

Caso os nodes não estejam ativos, execute o comando abaixo para reiniciar os nodes.

```bash
$ docker start roach1 roach2 roach3
```

Para apresentar o conceito de replicação vamos criar o *database northwind* no node 1 e mostrar o resultado da replicação. Antes de executar, veja os bancos de dados que temos nos nodes *SQL*.

```bash
  database_name | owner
----------------+--------
  bank          | root
  defaultdb     | root
  postgres      | root
  system        | node
(4 rows)
```

Agora vamos acessar o 1° node *SQL* (docker exec -it <node_name> ./cockroach sql --insecure).

```bash
$ docker exec -it roach1 ./cockroach sql --insecure
```

Crie o banco de dados do nosso estudo de caso.

```bash
root@:26257/defaultdb> create database northwind;
CREATE DATABASE

Time: 513ms total (execution 512ms / network 1ms)
```

Acessando o 2° e o 3° node *SQL* é possível confirmar que o comando foi replicado.

```bash
root@:26257/defaultdb> show databases;
  database_name | owner
----------------+--------
  bank          | root
  defaultdb     | root
  northwind     | root
  postgres      | root
  system        | node
(5 rows)

Time: 4ms total (execution 3ms / network 1ms)
```

2. **Failover automático** - O CockroachDB também consegue detectar automaticamente a indisponibilidade de um node e manter o serviço ao usuário ativo. Para estes testes vamos interromper o 2° node.

```bash
$ docker stop roach1
```

Tente acessar o 1° node.

```bash
$ docker exec -it roach1 ./cockroach sql --insecure
```

O resultado será:

```bash
Error response from daemon: Container 44ce3d718ba741e88c660a1747a862d5c322e0055e5ec8b3434fd6cf71832d92 is not running
```

Vamos verificar o status do *cluster* novamente.

```bash
$ docker ps
```

O resultado deve ser similar ao exibido abaixo.

```bash
CONTAINER ID   IMAGE                           COMMAND                  CREATED       STATUS              PORTS                                              NAMES
e9db89e8f36f   cockroachdb/cockroach:v20.2.2   "/cockroach/cockroac…"   3 weeks ago   Up 36 minutes       8080/tcp, 26257/tcp                                roach3
44ce3d718ba7   cockroachdb/cockroach:v20.2.2   "/cockroach/cockroac…"   3 weeks ago   Up About a minute   0.0.0.0:8080->8080/tcp, 0.0.0.0:26257->26257/tcp   roach1
```

Outra maneira de verificar o status do *cluster* é [acessando o localhost](http://localhost:8080/). Veja o resultado:

<p align="center">
<img src="./images/cockroachdb_node_status.png" width="1267">
<br>Figura 9: Node status. Fonte: Gerado pelo autor</br>
</p>

3. **Autocorreção** - No CockroachDB a resiliência automática é reponsável por garantir que um node que estava inoperante só reingresse no *cluster* após a atualização dos dados. Todo este processo é tranparente e não necessita de intervenção manual.

É importante lembrar que no momento temos 2° node fora de operação. Para provar o conceito de autocorreção vamos criar as tabelas e inserir dados no banco de dados *northwind* usando o 3° node *SQL* do *cluster*.

Acesse o 3° node *SQL*.

```bash
$ docker exec -it roach3 ./cockroach sql --insecure
```

Acesse o banco de dados *northwind*.

```bash
root@:26257/northwind> use northwind;
```

Execute os [comandos](https://github.com/ailtonmorais/newsql-disponibilidade/blob/master/sample/northwind-tables-cockroach.sql) de *create* para criar as tabelas:

Execute os [comandos](https://github.com/ailtonmorais/newsql-disponibilidade/blob/master/sample/northwind-data-cockroach.sql) de *insert* para popular as tabelas categories, suppliers e products:

Agora vamos reiniciar o 2° node que está fora de operação.

```bash
$ docker start roach2
```

Execute o comando abaixo para confirmar o status dos nodes.

```bash
$ docker start roach2
```

Verifique se o 2° node já está em operação novamente.

```bash
CONTAINER ID   IMAGE                           COMMAND                  CREATED       STATUS             PORTS                                              NAMES
e9db89e8f36f   cockroachdb/cockroach:v20.2.2   "/cockroach/cockroac…"   3 weeks ago   Up About an hour   8080/tcp, 26257/tcp                                roach3
8dc3754dadb1   cockroachdb/cockroach:v20.2.2   "/cockroach/cockroac…"   3 weeks ago   Up 2 minutes       8080/tcp, 26257/tcp                                roach2
44ce3d718ba7   cockroachdb/cockroach:v20.2.2   "/cockroach/cockroac…"   3 weeks ago   Up 28 minutes      0.0.0.0:8080->8080/tcp, 0.0.0.0:26257->26257/tcp   roach1
```

Chegou o momento de acessar o 2° node e confirmar a autocorreção do node com os dados replicados.

```bash
$ docker exec -it roach2 ./cockroach sql --insecure
```

Veja o resultado das tabelas criadas e os dados inseridos com os comandos listados abaixo.

```bash
root@:26257/defaultdb> use northwind;
```

Liste as tabelas replicadas para o 2° node.

```bash
root@:26257/northwind> show tables;
```

O retorno deve ser:

```bash
  schema_name |       table_name       | type  | owner | estimated_row_count
--------------+------------------------+-------+-------+----------------------
  public      | categories             | table | root  |                   0
  public      | customer_customer_demo | table | root  |                   0
  public      | customer_demographics  | table | root  |                   0
  public      | customers              | table | root  |                   0
  public      | employee_territories   | table | root  |                   0
  public      | employees              | table | root  |                   0
  public      | order_details          | table | root  |                   0
  public      | orders                 | table | root  |                   0
  public      | products               | table | root  |                   0
  public      | region                 | table | root  |                   0
  public      | shippers               | table | root  |                   0
  public      | suppliers              | table | root  |                   0
  public      | territories            | table | root  |                   0
  public      | us_states              | table | root  |                   0
(14 rows)

Time: 150ms total (execution 149ms / network 1ms)
```

Agora confirme se os dados inseridos foram replicados.

```bash
root@:26257/northwind> select count(*) from categories;
```

Retorno:

```bash
  count
---------
      8
(1 row)
```

```bash
root@:26257/northwind> select count(*) from suppliers;
```

Retorno:

```bash
  count
---------
     29
(1 row)
```

```bash
root@:26257/northwind> select count(*) from products;
```

Retorno:

```bash
  count
---------
     77
(1 row)
```

[Voltar ao índice](#indice)

<a id="benchmark"></a>
## 6. Benchmark - MySQL vs CockroachDB

*Benchmarks* provêm um método de comparação da *performance* de vários subsistemas dentre as diferentes arquiteturas de *chips* e sistemas. *Benchmarking* é útil para o entendimento de como o gerenciador de banco de dados responde sob a variação de condições. Pode-se criar cenários que testam o tratamento de *deadlock*, *performance* dos utilitários, diferentes métodos de carregar dados, características da taxa de transição quando mais usuários são adicionados e ainda o efeito na aplicação usando uma nova versão do produto [[20]](#Wikipedia-2020a).

Para este estudo de caso vamos utilizar um teste prático de simultaneidade de operações publicado no github [[5]](#caleblloyd-2020a). Caso tenha o MySQL e CockroachDB é possível reproduzir os mesmos testes baixando os *scripts* disponibilizados no repositório. Acompanhe os resultados obtidos:

- 10 conexões simultâneas. O resultado é o total de **segundos** necessário para finalizar todas as operações.

Teste          | MySQL | CockroachDB 
-------------- |-------|-------------
10x Insert     | 0.11  | 0.57        
100x Insert    | 1.15  | 5.54        
10x Select     | 0.05  | 0.07        
100x Select    | 2.30  | 4.06        
10x Update     | 0.10  | 0.540       
100x Update    | 1.14  | 5.55


- 100 conexões simultâneas. O resultado é o total de **segundos** necessário para finalizar todas as operações.

Teste          | MySQL | CockroachDB 
-------------- |-------|-------------
10x Insert     | 0.21  | 2.68        
100x Insert    | 2.14  | 26.18        
10x Select     | 0.88  | 3.86        
100x Select    | 84.86 | 342.15        
10x Update     | 0.25  | 2.99
100x Update    | 2.13  | 26.55

Conforme o teste de simultaneidade apresentado acima o MySQL foi superior ao CockroachDB em todos as operações independente de ter 10 ou 100 conexões simultâneas.

O desempenho é algo muito complicado de medir em um banco de dados. O desempenho do CockroachDB certamente é afetado por seu modelo de consistência. Em particular, CockroachDB lida com transações usando isolamento serializável e grava usando replicação de consenso.

[Voltar ao índice](#indice)

<a id="conclusao"></a>
## 7. Conclusão

Ao longo deste tutorial foi possível acompanhar todo o processo para prova do conceito de disponibilidade do MySQL Cluster e CockroachDB. Foi apresentado os seguintes processos:

1. Instalação
2. Configuração
3. Criação do banco de dados
4. Criação das tabelas
5. Inclusão de registros nas tabelas
6. Prova do conceito de disponibilidade
7. *Benchmark*

Com o ambiente criado foi realizado os mesmos tipos de testes para verificar o comportamento de cada banco de dados em particular. Na seção de [(Alta Disponibilidade)](#disponibilidade) temos os principais conceitos que o MySQL Cluster e CockroachDB utilizam para garantir um alto nível de disponibilidade, mas nos testes práticos o foco foi:

1. Replicação
2. Failover automático
3. Autocorreção

Foi respeitado a recomendação da documentação oficial de cada banco de dados para ter no mínimo de três computadores (3 nós) para executar um cluster viável e com isso aproveitar a as vantagens dos recursos de replicação, distribuição, rebalanceamento e resiliência automáticos.

Em resumo os banco de dados escolhidos atenderam o conceito de disponibilidade a partir da arquitetura proposta e nos testes de simultaneidade o MySQL foi muito superior ao CockroachDB.

[Voltar ao índice](#indice)

<a id="referencias"></a>
# 8. Referências Bibliográficas

<a id="MySQL-2020a"></a>
1. MySQL. [MySQL CLUSTER, 2020a](https://www.mysql.com/products/cluster/mysql-cluster-datasheet.pdf). Acesso em 14 out 2020 às 19h20m.

<a id="MySQL-2020b"></a>
2. MySQL. [MySQL CLUSTER, 2020b](https://www.mysql.com/products/cluster/availability.html). Acesso em 17 out 2020 às 11h00m.

<a id="MySQL-2020c"></a>
3. MySQL. [Appendix A MySQL 5.7 FAQ: NDB Cluster, 2020c](https://dev.mysql.com/doc/mysql-cluster-excerpt/5.7/en/faqs-mysql-cluster.html). Acesso em 17 out 2020 às 18h15m.

<a id="Cockroach-2020a"></a>
4. Cockroach Labs. [What is CockroachDB 2020a, 2020a](https://www.cockroachlabs.com/docs/stable/frequently-asked-questions.html). Acesso em 16 out 2020 às 17h30m.
  
<a id="Caleblloyd-2020a"></a>
5. Caleb Lloyd. [Concurrency Benchmark Results, 2020a](https://github.com/caleblloyd/MySqlCockroachBench/wiki/Concurrency-Benchmark-Results). Acesso em 30 dez 2020 às 10h30m.

<a id="Cockroach-2020b"></a>
6. Cockroach Labs. [Architecture Overview, 2020b](https://www.cockroachlabs.com/docs/stable/architecture/overview.html). Acesso em 17 out 2020 às 15h30m.

<a id="Cockroach-2020c"></a>
7. Cockroach Labs. [Start a Cluster in Docker, 2020c](https://www.cockroachlabs.com/docs/v20.2/start-a-local-cluster-in-docker-linux). Acesso em 04 dez 2020 às 19h10m.

<a id="YugabyteDB-2020a"></a>
8. YugabyteDB. [YugabyteDB, 2020a](https://docs.yugabyte.com/latest/sample-data/northwind/). Acesso em 29 dez 2020 às 10h15m.

<a id="Docker-2020a"></a>
9. Docker. [Docker, 2020a](https://www.docker.com/). Acesso em 29 dez 2020 às 10h50m.
  
<a id="Digitalocean-2020a"></a>
10. Digitalocean. [Digitalocean, 2020a](https://www.digitalocean.com/community/tutorials/como-instalar-e-usar-o-docker-no-ubuntu-18-04-pt). Acesso em 29 dez 2020 às 11h00m.

<a id="Medium-2020a"></a>
11. Medium. [Medium, 2020a](https://medium.com/@menakajayawardena/how-to-deploy-a-mysql-cluster-from-scratch-with-docker-a2452a56fc33). Acesso em 30 dez 2020 às 13h45m.

<a id="GithubGist-2020a"></a>
12. GithubGist. [GithubGist, 2020a](https://gist.github.com/leocomelli/2545add34e4fec21ec16). Acesso em 30 dez 2020 às 14h05m.
  
<a id="Krco-2013"></a>
13. Krco, Srdjan, et al. [Comic book](https://iotcomicbook.files.wordpress.com/2013/10/iot_comic_book_special_br.pdf). The internet of things, 2012, p. 15. Acesso em 21 dez 2020 às 21h10m.
  
<a id="Dias-2016"></a>
14. Dias, Renata Rapim de Freitas. Internet das Coisas sem Mistérios: Uma nova
inteligência para os negócios. São Paulo: Netpress Books, 2016.

<a id="Pavlo-2016"></a>
15. Pavlo, A. and Aslett. What’s really new with newsql? SIGMOD Rec., 45(2), 2016.

<a id="Yuan-2015"></a>
16. YUAN, L.-Y.; WU, L.; YOU, J.-H.; CHI, Y.  A demonstration of rubato db: A highly scalable
newsql database system for oltp and big data applications. In: ACM. Proceedings of the 2015
ACM SIGMOD International Conference on Management of Data. [S.l.], 2015. p. 907–912.

<a id="Kaur-2017"></a>
17. KAUR, K.; SACHDEVA, M.  Performance evaluation of newsql databases. In: IEEE. Inventive
Systems and Control (ICISC), 2017 International Conference on. [S.l.], 2017. p. 1–5.

<a id="STONEBRAKER-CATTEL-2011"></a>
18. STONEBRAKER, Michael, CATTELL, [Rick. 10 Rules for Scalable Performance in ‘Simple Operation’ Datastores](https://doi.org/10.1145/1953122.1953144). Communications Of The Acm, v. 54, n. 6, p. 72-80, jun. 2011.

<a id="Silberschatz-2006"></a>
19. SILBERSCHATZ, A.; KORTH, H. F.; SUDARSHAN, S. Sistema de banco de dados. 5 ed. Rio de Janeiro: Elsevier, 2006. p. 300.

<a id="Wikipedia-2020a"></a>
20. Wikipédia. [Benchmark (computação), 2020a](https://pt.wikipedia.org/wiki/Benchmark_(computa%C3%A7%C3%A3o)). Acesso em 03 dec 2020 às 19h10m.

<a id="KNOB-2019"></a>
21. KNOB, Ronan R. et al. [Uma Análise de Soluções NewSQL](https://sol.sbc.org.br/index.php/erbd/article/view/8475). In: XV Escola Regional de Banco de Dados (ERBD), 2019, Chapecó. Porto Alegre: Sociedade Brasileira de Computação, p. 21 - 30. ISSN 2595-413X.