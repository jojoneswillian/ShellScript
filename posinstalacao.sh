#!/bin/bash
# ==============================================================================
# Title       : install_postgresql.sh
# Description : Script para instalar o PostgreSQL no sistema
# Author      : Jones Willian
# Date        : 24-03-2024
# Version     : 1.2
# Usage       : ./install_postgresql.sh
# Repository  : [GitHub -> https://github.com/jojoneswillian/repo.git]
# ==============================================================================

# Verifica se o usuário é root
if [ "$(id -u)" -ne 0 ]; then
    echo "Este script precisa ser executado como root" >&2
    exit 1
fi

# Remover qualquer versão do PostgreSQL
sudo apt-get purge postgresql* -y
sudo apt-get autoremove -y
sudo apt-get autoclean

# Verifica se a remoção foi bem-sucedida antes de prosseguir
if [ $? -ne 0 ]; then
    echo "Erro ao remover o PostgreSQL. Verifique as permissões e tente novamente." >&2
    exit 1
fi

# Instalar o PostgreSQL
sudo apt-get update
sudo apt-get install postgresql postgresql-contrib -y

# Verifica se a instalação foi bem-sucedida antes de prosseguir
if [ $? -ne 0 ]; then
    echo "Erro ao instalar o PostgreSQL. Verifique a conexão com a internet e tente novamente." >&2
    exit 1
fi

# Configurar PostgreSQL
sudo sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/g" /etc/postgresql/$(ls /etc/postgresql/)/main/postgresql.conf
sudo echo "host    all             pdv             0.0.0.0/0               trust" | sudo tee -a /etc/postgresql/$(ls /etc/postgresql/)/main/pg_hba.conf
sudo echo "host    all             loja            0.0.0.0/0               trust" | sudo tee -a /etc/postgresql/$(ls /etc/postgresql/)/main/pg_hba.conf
sudo systemctl restart postgresql

# Verifica se a configuração foi bem-sucedida antes de prosseguir
if [ $? -ne 0 ]; then
    echo "Erro ao configurar o PostgreSQL. Verifique as configurações e tente novamente." >&2
    exit 1
fi

# Conceder privilégios para usuários
sudo -u postgres psql -c "CREATE ROLE pdv LOGIN;"
sudo -u postgres psql -c "CREATE ROLE loja LOGIN;"
sudo -u postgres psql -c "ALTER ROLE pdv CREATEDB;"
sudo -u postgres psql -c "ALTER ROLE loja CREATEDB;"

# Verifica se a criação de usuários foi bem-sucedida antes de prosseguir
if [ $? -ne 0 ]; then
    echo "Erro ao conceder privilégios para usuários. Verifique as configurações e tente novamente." >&2
    exit 1
fi

# Criar bancos de dados
sudo -u postgres psql -c "CREATE DATABASE pdv OWNER pdv;"
sudo -u postgres psql -c "CREATE DATABASE loja OWNER loja;"

# Verifica se a criação de bancos de dados foi bem-sucedida antes de prosseguir
if [ $? -ne 0 ]; then
    echo "Erro ao criar bancos de dados. Verifique as configurações e tente novamente." >&2
    exit 1
fi

echo "PostgreSQL instalado e configurado com sucesso!"

# Atualiza a lista de pacotes
apt update

# Instalação dos pacotes
sudo apt install -y vim openssh-server net-tools default-jdk

sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# Reinicia o serviço SSH para aplicar as alterações
sudo systemctl restart ssh

# Instalação do JDK 11
sudo apt install -y openjdk-11-jdk

# Instalação do JDK 8 de 32 bits (para sistemas que suportam arquitetura de 32 bits)
apt install -y openjdk-8-jdk:i386

# Limpeza de pacotes desnecessários
apt autoremove -y

