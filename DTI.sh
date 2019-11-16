#!/usr/bin/env bash

######################################################################################################
#	                                DTI - Development Tools Installer                                #
#                                                                                                    #
# 		- E-mail:     luciobrito2012@gmail.com                                                       #
# 		- Autor:      Luciano Brito                                                                  #
# 		- Telefone:   +55 61 995175170                                                               #
# 		- Manutenção: Luciano Brito                                                                  #
#                                                                                                    #
#                                                                                                    #
#----------------------------------------------------------------------------------------------------#
#                                           Description:                                             #
#----------------------------------------------------------------------------------------------------#
#  	DTI (Development Tools Installer) é uma script gráfico que permite uma rápida instalação de      #
#  	softwares e ferramentas necessários para desenvolvedores.                                        #
#                                                                                                    #
#  	Exemplos: Para execultá-lo de forma gráfica, basta abrir a pasta de download de script, dar      #
#   permissão de execução, clicar duas vezes sobre ele e, no popup que se abre, clicar em execultar. #
#	Em alguns casos, será necessário abrir um terminal na pasta de download de script e digitar:     #
#                                                                                                    #
#      $ sudo chmod 775 DTI.sh                                                                       #
#      $ ./DTI.sh                                                                                    #
#                                                                                                    #
#	Em alguns sistemas será possivel execultar apenas dando dois cliques com o botão                 #
#   esquerdo do mouse, bastando apenas dar permisssão de execução previamemte.                       #
#                                                                                                    #
#                                                                                                    #
#                                                                                                    #
#----------------------------------------------------------------------------------------------------#
#                                             History:                                               #
#----------------------------------------------------------------------------------------------------#
#                                            Version: 1                                              #
#                                                                                                    #
#		- version 1.0 - Construido toda a aplicação contendo operações GTK com Zenity.               #
#		- version 1.1 - Implementado correção no código da função de instalação genérica.            #
#                                                                                                    #
#                                                                                                    #
#                                                                                                    #
#----------------------------------------------------------------------------------------------------#
#                                            Version: 2                                              #
#                                                                                                    #
#		- version 2.0 - Implementado correção no código da função de instalação genérica e           #
#       	            implementação das funções de instalação dos pacotes Flatpak, Snap e Nativa.  #
#                                                                                                    #
#                                                                                                    #
#                                                                                                    #
#                                                                                                    #
#----------------------------------------------------------------------------------------------------#
#                                            Version: 3                                              #
#                                                                                                    #
#                                                                                                    #
#                                                                                                    #
#                                                                                                    #
#                                                                                                    #
#----------------------------------------------------------------------------------------------------#
# 	Testado em:                                                                                      #
#   	- bash 4.4.19                                                                                #
#                                                                                                    #
#                                                                                                    #
######################################################################################################


# -------------------------------------------- VARIÁVEIS --------------------------------------------#
# 	Nome do Usuário:
		USER_NAME="$(printf $USER | tr [a-z] [A-Z])"
#
#
# 	Nome do Sistema:
		SYSTEM_NAME="$(lsb_release -i | awk {'print $3'} | tr [a-z] [A-Z])"
#
# 	Arquitetura do Sistema:
		SYSTEM_ARCHITETURE="$(uname -m)"
#
#
# 	Total de Memória
		MEM="$(free -m | grep -i MEM | awk '{print $2}')"
#
#
# 	Instalador Nativo de Pacotes:
		INSTALLER=
#
#
# 	Tipo de pacotes suportados:
		NATIVE_TYPE_PACKAGE=
		FLATPAK="Flatpak"
		SNAP="Snap"
#
#
# 	Variável Senha:
		PASSWORD=
#
#
# 	Chaves Flags:
		PROGRAM=0			# Registrador de suporte a flatpak?
		CONTROLLER=0 		# Controlador do Menu Principal?
#
#
#   Arquivo Temporário
		TEMP=temp.$$
#
#
#
# ------------------------------------------ SYSTEM IDENTIFY -----------------------------------------#
# Testador de Suporte?
#
# Testa se existe suporte para execução do script.
#
#
function TesterSystemSuport() {
	if [ "$SYSTEM_NAME" != '' ]; then
		if [ "$SYSTEM_ARCHITETURE" != 'x86_64' ]; then
			if [ "$SYSTEM_ARCHITETURE" != 'amd64' ]; then
				NotSystemSuport
			fi
		fi	
	fi
}


# Identificador do instalador padrão da distro linux?
#
#
function IdentifyPackageInstall() {

	PROGRAM=1
	
	while [ $PROGRAM != 0 ]; do
		case $SYSTEM_NAME in
			'LINUXMINT') INSTALLER='apt-get' ; NATIVE_TYPE_PACKAGE='.deb' ; PROGRAM=0 ;;
			"ELEMENTARY")INSTALLER='apt-get' ; NATIVE_TYPE_PACKAGE='.deb' ; PROGRAM=0 ;;
			"UBUNTU") 	 INSTALLER='apt-get' ; NATIVE_TYPE_PACKAGE='.deb' ; PROGRAM=0 ;;
			"DEBIAN") 	 INSTALLER='apt-get' ; NATIVE_TYPE_PACKAGE='.deb' ; PROGRAM=0 ;;
			"XUBUNTU") 	 INSTALLER='apt-get' ; NATIVE_TYPE_PACKAGE='.deb' ; PROGRAM=0 ;;
			"LUBUNTU") 	 INSTALLER='apt-get' ; NATIVE_TYPE_PACKAGE='.deb' ; PROGRAM=0 ;;
			"OPENSUSE")  INSTALLER='zypper'  ; NATIVE_TYPE_PACKAGE='.rpm' ; PROGRAM=0 ;;
			"FEDORA") 	 INSTALLER='yum' 	 ; NATIVE_TYPE_PACKAGE='.rpm' ; PROGRAM=0 ;;
			"CENTOS") 	 INSTALLER='yum' 	 ; NATIVE_TYPE_PACKAGE='.rpm' ; PROGRAM=0 ;;
			*) NotSystemSuport ;;
		esac
	done
}


#----------------------------------------------- PASSWORD -------------------------------------------#
# Armazenamento de senha?
#
#
function Password() {
	
	local TEST=1
	while [ $TEST != 0 ]; do
		PASSWORD="$(zenity --password --title="Autenticação para $USER_NAME!")"
		RESULTSET="$?"
		ExecutionTest "$RESULTSET"
		if [ "$RESULTSET" == 0 ]; then
			if [ "$PASSWORD" == '' ]; then
				zenity --warning --text="O campo de senha está vazio! Tente novamente." --ellipsize
			else
				local TEST=0
			fi
		fi
	done
}


#------------------------------------------- WELCOME ------------------------------------------------#
# Função padrão de boas vindas?
#
#
function Welcome() {
	
	zenity --info --text="Seja bem-vindo(a) $USER_NAME !!!\n\n 
	Este programa viabilizará a instalação de vários outros
	programas voltados ao desenvolvimento de softwares.\n\n
	Para possibilitar a instalação desses softwares serão instalados em seu sistema:\n
		* Suporte a Pacotes Flatpak - Desenvolvido pela RHEL;
		* Suporte a Pacotes Snap - Desenvolvido pela Canonical.\n\n
	Informações do Sistema:\n
		- Usuário: $USER_NAME
		- Sistema: $SYSTEM_NAME
		- Arquitetura: $SYSTEM_ARCHITETURE
		- Memória RAM: $MEM Mb
		- Gerenciador de Pacotes: $INSTALLER
		- Binário Nativo: $NATIVE_TYPE_PACKAGE\n\n
	Para prosseguir clique em OK ou feche para encerrar!" --ellipsize
	
	ExecutionTest "$?"
}


function ZenityWarningSoftware() {
	WARNING=$1
	zenity --warning --text="$WARNING já está instalado!" --ellipsize
}


# -------------------------------------------- ERROR ------------------------------------------------#
# Sistema não suportado?
#
# Basicamente o sistema será não suportado quando não houver uma entrada para ele
# no identificador do instalador padrão.
function NotSystemSuport() {
	if ! [ $SYSTEM_NAME == '' ]; then
		zenity --error --text="ERRO: $SYSTEM_NAME não é suportado!\n\n" --ellipsize
	else
		zenity --error --text="ERRO: Seu sistema não é suportado!\n\n" --ellipsize
	fi
	Exit 1
}


# Opção não selecionada?
#
function NullOption() {
	zenity --info --text='Nenhuma opção foi selecionada!\nTente novamente!\n\n' --ellipsize
}


#---------------------------------------------- EXIT ------------------------------------------------#
# Filtro da chamada da função de saida do sistema?
#
function ExecutionTest() {
	
	local Result=$1
	[ $Result != 0 ] && Exit 1
}


# Função de saida padrão do sistema?
#
function Exit() {

	local Test=$1
	if [ $Test == 1 ]; then
		rm -f $TEMP
		zenity --warning --text="Algo inesperado aconteceu $USER_NAME!\n\nO Programa será fechado.\n  " --ellipsize
		exit 1
	else 
		rm -f $TEMP
		zenity --info --text="Obrigado por utilizar nosso software $USER_NAME!\n  " --ellipsize
		CONTROLLER=1
		exit 0
	fi	
}


function QuestionQuit() {
	unset RESULTSET
	zenity --question --text="Você deseja sair do programa?\n\n  " --ellipsize
	RESULTSET=$?

	if [ "$RESULTSET" == 0 ]; then
		Exit 0
	else
		ProgramMain
	fi
}

#--------------------------------------------- MAIN MENU --------------------------------------------#
# Função principal?
#
# TYPE_PROGRAM é a variável que receberá o tipo de programa a ser instalado.
# Uma vez reconhecido o tipo, o fluxo do programa chamará a função subsequente correspondente.
# 
# RESULTSET é a variável que armazenará o retorno de execução de um comando,
# sendo que '0' representa a execução bem sucedida e '!= 0' significa erro na execução.
#
#
function ProgramMain() {

	CONTROLLER=0
	while [ $CONTROLLER == 0 ]; do
		unset TYPE_PROGRAM
		TYPE_PROGRAM="$(zenity --list \
		--title="Instalador de Programas" \
		--text="Escolha um tipo de programa a ser instalado!" \
		--column="Itens" \
		--column="Programas" \
		--column="Descrição" \
		    1 "Programas Convencionais"                         "Possibilita Instalar Variados Pacotes Uteis para o Dia-a-Dia ..." \
			2 "SDKs" 											"Possibilita Instalar Varios SDK's ..." \
			3 "Banco de Dados" 									"Possibilita Instalar o PostgreSQL, MySQL, MariaDB, OracleSQL, XAMPP ..." \
			4 "Editores de Codigo" 								"Possibilita Instalar o Atom, Sublime-Text, VSCode, Brackets ..." \
			5 "IDEs" 											"Possibilita Instalar Vários Ambientes Integrados de Desenvolvimento ..." \
			6 "Ferramentas CASE para UML" 						"Possibilita Instalar o Astah-Community, StarUML, Umbrello ..." \
			7 "Ferramentas Para Testes Automatizados" 			"Possibilita Instalar o Selenium, JUnit, SoapUI ..." \
			8 "Ferramentas Para Versionamento de Codigo"		"Possibilita Instalar o Git, GitHub, GitLab ..." \
			9 "Utilitários de Linha de Comando"					"Possibilita Instalar os Interpretadores de Comando ZSH, PowerShell ..." \
			10 "Navegadores" 									"Possibilita Instalar o Opera, Chrome, Firefox, Chromium ..." \
			11 "Virtualizacao"									"Possibilita Instalar o Docker, VMWare, VirtualBox ..."  \
			12 "Personalizacao"									"Possibilita Instalar Pacotes e Componentes Adicionais no Sistema ..." \
		--radiolist \
		--width=900 \
		--height=500)"

		RESULTSET="$?"
		ExecutionTest "$RESULTSET"

		case "$TYPE_PROGRAM" in
		    'Programas Convencionais') UtilsPrograms                    ;;
			'SDKs') SDKs												;;
			'Banco de Dados') DataBases 								;;
			'Editores de Codigo') CodeEditor							;;
			'IDEs') IDEs												;;
			'Ferramentas CASE para UML') UMLTools						;;
			'Ferramentas Para Testes Automatizados') AutomatedTestTools	;;
			'Ferramentas Para Versionamento de Codigo') CodeVersioners	;;
			'Utilitários de Linha de Comando') CommandLineUtility		;;
			'Navegadores') Browsers										;;
			'Virtualizacao') Virtualization								;;
			'Personalizacao') Customization								;;
			*) NullOption												;;
		esac
		
		[ "$TYPE_PROGRAM" != '' ] && NewInstallation # Chamada do diálogo para nova instalação
	done
}


#------------------------------------------------- SUBMENU ------------------------------------------#
# Instalação Genérica?
#
# Função genérica de instalação de pacotes:
#
#  - QUANT_PARAM:		é a variável que receberá em números a quantidade de parâmetros passados para dentro desta função.
#  - INDEX:				é a variável que receberá a quantidade de colunas a ser impressa.
#  - SOFTWARE_CHOSEN[]:	é o Array que receberá todos os parâmetros que serão impressos em formas de colunas. 
#  - OPTION_SOFTWARE:	é a variável que receberá do usuário os nomes dos softwares a serem instalados.
#  - COMPONENT:			é a variável que filtrará os nomes que estarão separados por '|' dentro da variável OPTION_SOFTWARE.
#  - CHOICE[]:			é o Array que armazenará os nomes dos pacotes na posição de i. 
#
# 
function GenericSoftwareInstall() {

	QUANT_PARAM=$#
	INDEX=$(($QUANT_PARAM/4))

	for (( i = 0; i < $QUANT_PARAM; i++ )); do
		SOFTWARE_CHOSEN[$i]="$1"
		shift
	done

	IFS=\| read OPTION_SOFTWARE <<< "$(zenity --list \
	--title="Instalador de Programas" \
	--text="Escolha o(s) software(s) a ser(em) instalado(s)!" \
	--column="Itens" \
	--column="Software" \
	--column="Descrição" \
	--column="Tipo de Pacote" \
	"${SOFTWARE_CHOSEN[@]}"	\
	--checklist \
	--width=900 \
	--height=500)"

	RESULTSET=$?

	if [ $RESULTSET == 0 ] && [ "$OPTION_SOFTWARE" != '' ]; then
		OPTION_SOFTWARE="$OPTION_SOFTWARE|"
		for (( i = 0; i <= $INDEX; i++ )); do
			c=$(($i+1))
			COMPONENT="$(echo "$OPTION_SOFTWARE" | cut -d'|' -f"$c")"
			[ "$COMPONENT" != '' ] && CHOICE[$i]="$COMPONENT"
			case "${CHOICE[$i]}" in
			    #----------------------------------------- Programas Uteis --------------------------------------------------#
				'Grub Customizer') echo "$PASSWORD" | sudo -S add-apt-repository ppa:danielrichter2007/grub-customizer -y && echo "$PASSWORD" | sudo -S $INSTALLER update ; Native_Install_Package 'grub-customizer'  "${CHOICE[$i]}" ;;
				'Gnome-System-Monitor') Native_Install_Package 'gnome-system-monitor' '-y' "${CHOICE[$i]}" ;;
				'Gnome-Disks') Native_Install_Package 'gnome-disk-utility' '-y' "${CHOICE[$i]}" ;;
				'GParted') Native_Install_Package 'gparted' '-y' "${CHOICE[$i]}" ;;
				'Timeshift') Native_Install_Package 'timeshift' '-y' "${CHOICE[$i]}" ;;
				'Brasero') Native_Install_Package 'brasero' '-y' "${CHOICE[$i]}" ;;
				'ClipGrab')  echo "$PASSWORD" | sudo -S add-apt-repository ppa:clipgrab-team/ppa -y && echo "$PASSWORD" | sudo -S $INSTALLER update ; Native_Install_Package 'clipgrab' '-y' "${CHOICE[$i]}" ;;
				'Transmission') Flatpak_Install_Package 'com.transmissionbt.Transmission' '--system -y' "${CHOICE[$i]}" ;;
				'Mailspring') Snap_Install_Package 'mailspring' '' "${CHOICE[$i]}" ;;
				'Thunderbird') Flatpak_Install_Package 'org.mozilla.Thunderbird' '--system -y' "${CHOICE[$i]}" ;;
				'VLC') Flatpak_Install_Package 'org.videolan.VLC' '--system -y' "${CHOICE[$i]}" ;;
				'Parole')  ;;
				'Audacity') Flatpak_Install_Package 'org.audacityteam.Audacity' '--system -y' "${CHOICE[$i]}" ;;
				'Spotify') Flatpak_Install_Package 'com.spotify.Client' '--system -y' "${CHOICE[$i]}" ;;
				'Transmageddon)')  ;;	
				'Converseen')  ;;
				'Inkscape') Flatpak_Install_Package 'org.inkscape.Inkscape' '--system -y' "${CHOICE[$i]}" ;;
				'Gimp') Flatpak_Install_Package 'org.gimp.GIMP' '--system -y' "${CHOICE[$i]}" ;;
				'Krita') Flatpak_Install_Package 'org.kde.krita' '--system -y' "${CHOICE[$i]}" ;;
				'OBS-Studio') Flatpak_Install_Package 'com.obsproject.Studio' '--system -y' "${CHOICE[$i]}" ;;
				'Kdenlive') Flatpak_Install_Package 'org.kde.kdenlive' '--system -y' "${CHOICE[$i]}" ;;
				'Davinci Resolve')  ;;
				'LibreOffice') Flatpak_Install_Package 'org.libreoffice.LibreOffice' '--system -y' "${CHOICE[$i]}" ;;
				'WPS Office') Flatpak_Install_Package 'com.wps.Office' '--system -y' "${CHOICE[$i]}" ;;
				'FreeOffice')  ;;
				'GoldenDictionary') Snap_Install_Package 'goldendictionary' '' "${CHOICE[$i]}" ;;
				'Bible Time') Flatpak_Install_Package 'info.bibletime.BibleTime' '--system -y' "${CHOICE[$i]}" ;;
				'Team Viewer')  ;;
				'WhatsApp') Snap_Install_Package 'whatsdesk' '' "${CHOICE[$i]}" ;;
				'Telegram') Snap_Install_Package 'telegram-desktop' '' "${CHOICE[$i]}" ;;
				'Dropbox') Flatpak_Install_Package 'com.dropbox.Client' '--system -y' "${CHOICE[$i]}" ;;
				'Insync')  ;;
				'Wine') Snap_Install_Package 'wine-platform-4-stable' '' "${CHOICE[$i]}" ;;
				'PlayOnLinux') Flatpak_Install_Package 'org.phoenicis.playonlinux' '--system -y' "${CHOICE[$i]}" ;;
				'Steam') Flatpak_Install_Package 'com.valvesoftware.Steam' '--system -y' "${CHOICE[$i]}" ;;
				'VirtualBox')  ;;
				#---------------------------------------------- SDK ---------------------------------------------------------#
				'Android SDK') Native_Install_Package 'android-sdk' '-y' "${CHOICE[$i]}" ;;
				'DotNet Core SDK') Snap_Install_Package 'dotnet-sdk' '--classic' "${CHOICE[$i]}" ;;
				'JDK') Native_Install_Package 'default-jdk' '-y' "${CHOICE[$i]}" ;;
				'Open JDK 8') Native_Install_Package 'openjdk-8-jdk openjdk-8-source' '-y' "${CHOICE[$i]}" ;;
				'Open JDK 11') Native_Install_Package 'openjdk-11-jdk openjdk-11-source' '-y' "${CHOICE[$i]}" ;;
				'Kotlin SDK') Snap_Install_Package 'kotlin' '--classic' "${CHOICE[$i]}" ;;
				'Node SDK') Snap_Install_Package 'node' '--channel=10/stable --classic' "${CHOICE[$i]}" ;;
				'Openstack SDK') Native_Install_Package 'python3-openstacksdk' '-y' "${CHOICE[$i]}"  ;;
				'Ubuntu SDK') Native_Install_Package 'ubuntu-make ubuntu-sdk-qmake-extras' '-y' "${CHOICE[$i]}" ;;
				#----------------------------------------- Banco de Dados ---------------------------------------------------#
				'DataGrip') Snap_Install_Package 'datagrip' '--classic' "${CHOICE[$i]}" ;;
				'DBeaver Community') Flatpak_Install_Package 'io.dbeaver.DBeaverCommunity' '--system -y' "${CHOICE[$i]}" ;;
				'IBM DB2') DB2_Install ;;
				'MongoDB') MongoDB_Install ;;
				'MySQL-Workbench') MySQL-Workbench_Installer "mysql-workbench" ;;
				'Oracle Databases') Oracle_Install ;;
				'PGAdmin 4') Snap_Install_Package 'postgresql' '' "${CHOICE[$i]}" ;;
				'XAMPP') XAMPP_Install "${CHOICE[$i]}" ;;
				'MySQL') Native_Install_Package 'mysql-client' '-y' "${CHOICE[$i]}" ;;
				'MariaDB') Native_Install_Package 'mariadb-client' '-y' "${CHOICE[$i]}" ;;
				#--------------------------------------- Editores de Código -------------------------------------------------#
				'Atom') Flatpak_Install_Package 'io.atom.Atom' '--system -y' "${CHOICE[$i]}" ;;
				'Brackets') Snap_Install_Package 'brackets' '--classic' "${CHOICE[$i]}" ;;
				'Notepad++') Snap_Install_Package 'notepad-plus-plus' '' "${CHOICE[$i]}" ;;
				'Notepadqq') Flatpak_Install_Package 'com.notepadqq.Notepadqq' '--system -y' "${CHOICE[$i]}" ;;
				'Sublime Text') Flatpak_Install_Package 'com.sublimetext.three' '--system -y' "${CHOICE[$i]}" ;;
				'Vim') Flatpak_Install_Package 'org.vim.Vim' '--system -y' "${CHOICE[$i]}" ;;
				'VS Code') Flatpak_Install_Package 'com.visualstudio.code' '--system -y' "${CHOICE[$i]}" ;;
				#---------------------------------------------- IDE ---------------------------------------------------------#
				'Android Studio') Flatpak_Install_Package 'com.google.AndroidStudio' '--system -y' "${CHOICE[$i]}" ;;
				'Arduino IDE') Flatpak_Install_Package 'cc.arduino.arduinoide' '--system -y' "${CHOICE[$i]}" ;;
				'CodeBlocks') Flatpak_Install_Package 'org.codeblocks.codeblocks' '--system -y' "${CHOICE[$i]}" ;;
				'Geany') Flatpak_Install_Package 'org.geany.Geany' '--system -y' "${CHOICE[$i]}" ;;
				'Eclipse') Snap_Install_Package 'eclipse' '--classic' "${CHOICE[$i]}" ;;
				'Netbeans') Snap_Install_Package 'netbeans' '--classic' "${CHOICE[$i]}" ;;	
				'InteliJ IDEA Community') Snap_Install_Package 'intellij-idea-community' '--classic' "${CHOICE[$i]}" ;;
				'WebStorm') Snap_Install_Package 'webstorm' '--classic' "${CHOICE[$i]}" ;;
				'PhpStorm') Snap_Install_Package 'phpstorm' '--classic' "${CHOICE[$i]}" ;;
				'PyCharm Community') Snap_Install_Package 'pycharm-community' '--classic' "${CHOICE[$i]}" ;;
				'Rider') Snap_Install_Package 'rider' '--classic' "${CHOICE[$i]}"  ;;
				'GoLand') Snap_Install_Package 'goland' '--classic' "${CHOICE[$i]}" ;;
				'RubyMine') Snap_Install_Package 'rubymine' '--classic' "${CHOICE[$i]}" ;;
				#-------------------------------------- Ferramentas CASE para UML -------------------------------------------#
				'Astah-Community') ;;
				'StarUML') ;;
				'Umbrello') Snap_Install_Package 'umbrello' '' "${CHOICE[$i]}" ;;
				#------------------------------- Ferramentas de Automação de Testes -----------------------------------------#
				'JUnit') ;;
				'Selenium') ;;
				'SoapUI') ;;
				#------------------------------- Ferramentas para Versionamento de Código -----------------------------------#
				'Git') Native_Install_Package 'git' '-y' "${CHOICE[$i]}" ; TermModify ;;
				'GitHub') Native_Install_Package 'github' '-y' "${CHOICE[$i]}" ;;
				'GitKraken') Flatpak_Install_Package 'com.axosoft.GitKraken' '--system -y' "${CHOICE[$i]}" ;;
				'GitLab') GitLab_Install ;;
				'Subversion') SVN_Install ;;
				'TermModify') TermModify ;;
				#------------------------------------ Utilitários de Linha de Comando ---------------------------------------#
				'Power Shell') Snap_Install_Package 'powershell' '--classic' "${CHOICE[$i]}" ;;
				'ZSH') Native_Install_Package 'zsh' '-y' "${CHOICE[$i]}" ;;
				'Fast') Snap_Install_Package 'fast' '' "${CHOICE[$i]}" ;;
				'SpeedTest-CLI') Native_Install_Package 'speedtest-cli' '-y' "${CHOICE[$i]}" ;;
				#------------------------------------------ Navegadores -----------------------------------------------------#
				'Chrome') Native_Install_Package 'google-chrome-stable' '-y' "${CHOICE[$i]}" ;;
				'Chromium') Snap_Install_Package 'chromium' '' "${CHOICE[$i]}" ;;
				'Epiphany') Snap_Install_Package 'epiphany' '' "${CHOICE[$i]}" ;;
				'Firefox') Snap_Install_Package 'firefox' '' "${CHOICE[$i]}" ;;
				'Links') Snap_Install_Package 'links' '' "${CHOICE[$i]}" ;;
				'Opera') Snap_Install_Package 'opera' '' "${CHOICE[$i]}" ;;
				'Tor') Snap_Install_Package 'tor' '' "${CHOICE[$i]}" ;;
				#------------------------------------------- Containers -----------------------------------------------------#
				'Docker') Snap_Install_Package 'docker' '' "${CHOICE[$i]}" ;;
				'VirtualBox') Native_Install_Package 'virtualbox virtualbox-guest-additions-iso' '-y' "${CHOICE[$i]}"  ;;
				'VM Ware') Native_Install_Package 'vmware-manager' '-y' "${CHOICE[$i]}"  ;;
				#---------------------------------------------- Custon ------------------------------------------------------#
				'Gerenciador de Arquivos') Nemo_Add_On ;;
				'Terminal') TermModify ;;
				'Icones') Native_Install_Package 'papirus-icon-theme' '-y' "${CHOICE[$i]}"  ;;
				'GTK') Native_Install_Package 'arc-theme' '-y' "${CHOICE[$i]}"   ;;
				#--------------------------------------------- ERROR --------------------------------------------------------#
				'') unset CHOICE ; unset SOFTWARE_CHOSEN ; break ;;
				*) NullOption ; unset CHOICE ; unset SOFTWARE_CHOSEN ; break ;;
			esac
		done
	else
		unset SOFTWARE_CHOSEN
		unset CHOICE
		CONTROLLER=1
		QuestionQuit 
	fi
}


# Submenus Gráficos?
#
# Submenus Interativos.
#
#
function UtilsPrograms() {

	GenericSoftwareInstall 																					\
	1 'Grub Customizer' 		'Customizador de Bootloader'      					"$NATIVE_TYPE_PACKAGE" 	\
	2 'Gnome-System-Monitor' 	'Monitor do Sistema'								"$NATIVE_TYPE_PACKAGE" 	\
	3 'Gnome-Disks' 	    	'Gerenciador de Discos'      						"$NATIVE_TYPE_PACKAGE" 	\
	4 'GParted' 				'Gerenciador de Discos'      						"$NATIVE_TYPE_PACKAGE" 	\
	5 'Timeshift' 				'Gerenciador de Backups' 							"$NATIVE_TYPE_PACKAGE" 	\
	6 'Brasero' 				'Gravador de Mídias'      							"$NATIVE_TYPE_PACKAGE" 	\
	7 'ClipGrab' 				'Cliente de Downloads de Vídeos'      				"$NATIVE_TYPE_PACKAGE" 	\
	8 'Transmission' 			'Cliente de Torrent'      							"$FLATPAK" 				\
	9 'Mailspring' 				'Cliente de E-mail'      							"$SNAP" 				\
	10 'Thunderbird' 			'Cliente de E-mail'      							"$FLATPAK" 				\
	11 'VLC' 					'Player Multimídia'      							"$FLATPAK" 				\
	12 'Parole' 				'Player Multimídia'      							"$NATIVE_TYPE_PACKAGE" 	\
	13 'Audacity' 				'Editor de Audios'      							"$FLATPAK" 				\
	14 'Spotify' 				'Player de Streeming de Músicas'      				"$FLATPAK" 				\
	15 'Transmageddon' 			'Conversor de Vídeos'      							"$NATIVE_TYPE_PACKAGE" 	\
	16 'Converseen' 			'Conversor de Imagens'      						"$NATIVE_TYPE_PACKAGE" 	\
	17 'Inkscape' 				'Editor de imagens Vetoriais'						"$FLATPAK" 				\
	18 'Gimp' 					'Editor de Imagens'      							"$FLATPAK" 				\
	19 'Krita' 					'Editor de Imagens'      							"$FLATPAK" 				\
	20 'OBS-Studio' 			'Cliente de Streeming de Vídeos'      				"$FLATPAK" 				\
	21 'Kdenlive' 				'Editor de Vídeos'      							"$FLATPAK" 				\
	22 'Davinci Resolve' 		'Editor de Vídeos'      							"$NATIVE_TYPE_PACKAGE" 	\
	23 'LibreOffice' 			'Suite de automação de escritório'      			"$FLATPAK" 				\
	24 'WPS Office' 			'Suite de automação de escritório'      			"$FLATPAK" 				\
	25 'FreeOffice' 			'Suite de automação de escritório'      			"$NATIVE_TYPE_PACKAGE" 	\
	26 'GoldenDictionary'		'Gerenciador de Dicionários'      					"$SNAP" 				\
	27 'Bible Time' 			'Bíblia de Estudos'      							"$FLATPAK" 				\
	28 'Team Viewer' 			'Cliente para Acesso Remoto'      					"$NATIVE_TYPE_PACKAGE" 	\
	29 'WhatsApp' 				'Cliente de Mensagens Instantaneas para Desktop'    "$SNAP" 				\
	30 'Telegram' 				'Cliente de Mensagens Instantaneas para Desktop' 	"$SNAP" 				\
	31 'Dropbox' 				'Cliente de Armazenamento de Arquivos'      		"$FLATPAK" 				\
	32 'Insync' 				'Cliente de Armazenamento de Arquivos'      		"$NATIVE_TYPE_PACKAGE" 	\
	33 'Wine' 					'Emulador de Programas do Windows' 					"$SNAP" 				\
	34 'PlayOnLinux' 			'Emulador de Programas do Windows' 					"$FLATPAK" 				\
	35 'Steam' 					'Cliente de Jogos' 									"$FLATPAK" 				\
	36 'VirtualBox' 			'Gerenciador de Maquinas Virtuais' 					"$NATIVE_TYPE_PACKAGE"
}


function SDKs() {

	GenericSoftwareInstall 																					\
	1 'Android SDK' 			'Kit de Desenvolvimento Android'					"$NATIVE_TYPE_PACKAGE" 	\
	2 'DotNet Core SDK'			'Kit de Desenvolvimento DotNet Core'				"$SNAP"					\
	3 'JDK' 					'Kit de Desenvolvimento Java Proprietário'			"$NATIVE_TYPE_PACKAGE" 	\
	4 'Open JDK 8'				'Kit de Desenvolvimento Java 8 Open Source'			"$NATIVE_TYPE_PACKAGE"	\
	5 'Open JDK 11' 			'Kit de Desenvolvimento Java 11 Open Source'		"$NATIVE_TYPE_PACKAGE"	\
	6 'Kotlin SDK'				'Kit de Desenvolvimento Kotlin'						"$SNAP" 				\
	7 'Node SDK'				'Kit de Desenvolvimento Node'						"$SNAP" 				\
	8 'Openstack SDK'			'Kit de Desenvolvimento Python3 para OpenStack'		"$NATIVE_TYPE_PACKAGE"	\
	9 'Ubuntu SDK' 				'Kit de Desenvolvimento Ubuntu'						"$NATIVE_TYPE_PACKAGE"
}


function DataBases() {

	GenericSoftwareInstall 																																		\
	1 'DataGrip' 				'Cliente SQL para Administração de Base de Dados MySQL, Oracle, PostgreSQL, DB2, MS SQL Server, Azure' 	"$SNAP" 				\
	2 'DBeaver Community'		'Cliente SQL para Administração de Base de Dados MySQL, MariaDB, PostgreSQL'							"$FLATPAK" 				\
	3 'IBM DB2'					'Cliente SQL para Administração de Base de Dados IBM'													"" 						\
	4 'MongoDB'					'Cliente NoSQL para Administração de Base de Dados MongoDB'												"" 						\
	5 'MySQL-Workbench' 		'Cliente SQL para Administração de Bases de Dados MySQL e MariaDB'										"$NATIVE_TYPE_PACKAGE" 	\
	6 'Oracle Databases' 		'Cliente SQL para Administração de Base de Dados Oracle'												"" 						\
	7 'PGAdmin 4' 				'Cliente SQL para Administração de Base de Dados PostgreSQL'											"$SNAP" 				\
	8 'XAMPP' 					'Apache, MariaDB, PHP e Perl'																			".run" 					\
	9 'MySQL'					'Banco de Dados Relacional' 																			"$NATIVE_TYPE_PACKAGE" 	\
	10 'MariaDB'				'Banco de Dados Relacional' 																			"$NATIVE_TYPE_PACKAGE" 
}


function CodeEditor() {

	GenericSoftwareInstall 														\
	1 'Atom' 					'Editor de Código'					"$FLATPAK" 	\
	2 'Brackets' 				'Editor de Código'					"$SNAP" 	\
	3 'Notepad++'				'Editor de Código'					"$SNAP" 	\
	4 'Notepadqq' 				'Editor de Código'					"$FLATPAK" 	\
	5 'Sublime Text' 			'Editor de Código'					"$FLATPAK" 	\
	6 'Vim' 					'Editor de Código em Modo Texto'	"$FLATPAK" 	\
	7 'VS Code' 				'Editor de Código'					"$FLATPAK"
}


function IDEs() {

	GenericSoftwareInstall 																										\
	1 'Android Studio' 			'IDE para Desenvolvimento em Java, PHP, Python ...' 								"$FLATPAK" 	\
	2 'Arduino IDE'				'IDE para Desenvolvimento em Linguagem C/C++ ...'									"$FLATPAK" 	\
	3 'CodeBlocks' 				'IDE para Desenvolvimento em Linguagem C/C++ ...'									"$FLATPAK" 	\
	4 'Geany' 					'IDE para Desenvolvimento em Linguagem C/C++ ...'									"$FLATPAK" 	\
	5 'Eclipse' 				'IDE para Desenvolvimento em Java, PHP, Python ...' 								"$SNAP" 	\
	6 'Netbeans' 				'IDE para Desenvolvimento em Java, PHP, Python ...' 								"$SNAP" 	\
	7 'InteliJ IDEA Community' 	'IDE para Desenvolvimento em Java, PHP, Python ...' 								"$SNAP" 	\
	8 'WebStorm'				'IDE para Desenvolvimento em JavaScrip, TypeScript, React, Vue.js, Angular ...'		"$SNAP" 	\
	9 'PhpStorm'				'IDE para Desenvolvimento em PHP, HTML, CSS ...'									"$SNAP" 	\
	10 'PyCharm Community' 		'IDE para Desenvolvimento em Python ...' 											"$SNAP"		\
	11 'Rider'					'IDE para Desenvolvimento em C#, VB.NET, .NET, .NET-Core, ASP.NET, JSON, SQL ...' 	"$SNAP"		\
	12 'GoLand' 				'IDE para Desenvolvimento em Go ...' 												"$SNAP"		\
	13 'RubyMine' 				'IDE para Desenvolvimento em Ruby on Rails ...' 									"$SNAP"
}


function UMLTools() {

	GenericSoftwareInstall 											\
	1 'Astah-Community'			'Ferramenta Case UML'		"" 		\
	2 'StarUML'					'Ferramenta Case UML'		"" 		\
	3 'Umbrello'				'Ferramenta Case UML'		"$SNAP"
}


function AutomatedTestTools() {

	GenericSoftwareInstall 																			\
	1 'JUnit' 		''																			"" 	\
	2 'Selenium' 	'API de Automação de Teste'													"" 	\
	3 'SoapUI' 		'Ferramenta de Automação de Teste para Web Services, APIs REST e SOAP'		"" 
}


function CodeVersioners() {

	GenericSoftwareInstall 																			\
	1 'Bitbucket'				'Versionador Remoto'						"" 						\
	2 'Git' 					'Ferramenta de Versionamento de Código'		"$NATIVE_TYPE_PACKAGE" 	\
	3 'GitHub' 					'Repositório Remoto'						"$NATIVE_TYPE_PACKAGE" 	\
	4 'GitKraken'				'GUI para o Git'							"$FLATPAK" 				\
	5 'GitLab' 					'Versionador Remoto'						"" 						\
	6 'Subversion'				'Versionador Remoto'						""
}


function CommandLineUtility() {

	GenericSoftwareInstall 																				\
	1 'Power Shell'		'Interpretador de Comando Microsoft para Linux'		"$SNAP"						\
	2 'ZSH'				'Interpretador de Comandos para Linux'				"$NATIVE_TYPE_PACKAGE"		\
	3 'Fast'			'Analizador de Banda de Internet'					"$SNAP"						\
	4 'SpeedTest-CLI'	'Analizador de Banda de Internet'					"$NATIVE_TYPE_PACKAGE"
}


function Browsers() {

	GenericSoftwareInstall 																\
	1 'Firefox' 				'Navegador Livre'				"$SNAP" 				\
	2 'Chrome' 					'Navegador Proprietário'		"$NATIVE_TYPE_PACKAGE" 	\
	3 'Chromium' 				'Navegador Livre'				"$SNAP"					\
	4 'Epiphany' 				'Navegador Livre'				"$SNAP" 				\
	5 'Links' 					'Navegador em modo texto'		"$SNAP" 				\
 	6 'Opera' 					'Navegador Proprietário'		"$SNAP" 				\
	7 'Tor' 					'Navegador Livre'				"$SNAP"
}


function Virtualization() {

	GenericSoftwareInstall 												\
	1 'Docker' 					'Tecnologia de Containers'		"$SNAP" \
	2 'VirtualBox'				'Tecnologia Hyper-v'			"" 		\
	3 'VM Ware' 				'Tecnologia Hyper-v'			""
}


function Customization() {

	GenericSoftwareInstall 																											\
	1 'Gerenciador de Arquivos' 	'Instala Componentes ao gerenciador de Arquivos Nemo' 					"Scripts" 				\
	2 'Terminal' 					'Instala Componentes ao Arquivo de Configuração do Bash (.bashrc)' 		"Scripts" 				\
	3 'Icones' 						'Instala Temas de Icones ao Sistema' 									"$NATIVE_TYPE_PACKAGE" 	\
	4 'GTK' 						'Instala Temas GTK ao Sistema' 											"$NATIVE_TYPE_PACKAGE"
}


# ---------------------------------------- SOFTWARES INSTALLATION --------------------------------------#
# Instalador de suporte flatpaks e Snaps?
#
#
function SuportInstalation() {

	FLATPAK_WAY=$(which flatpak)
	SNAP_WAY=$(which snap)
	XTERM_WAY=$(which xterm)

	if ! [ -e "$FLATPAK_WAY" ]; then
		(echo "$PASSWORD" | sudo -S "$INSTALLER" install flatpak -y) | ZenityProgress "$FLATPAK"
		InstalationCheckup "$FLATPAK_WAY" "$FLATPAK"
	fi

	if ! [ -e "$SNAP_WAY" ]; then
		(echo "$PASSWORD" | sudo -S "$INSTALLER" install snapd -y) | ZenityProgress "$SNAP"
		InstalationCheckup"$SNAP_WAY" "$SNAP"
	fi

	if ! [ -e "$XTERM_WAY" ]; then
		(echo "$PASSWORD" | sudo -S "$INSTALLER" install xterm -y) | ZenityProgress "Xterm"
		InstalationCheckup "$XTERM_WAY" "Xterm"
	fi
}


function ColectionsInstaller() {	
	
	CONT=$#
	VET[$CONT]=''

	for (( i = 0; i < $CONT; i++ )); do
		VET[$i]=$1
		shift
	done

	for (( i = 0; i < 10; i++ )); do
		Native_Install_Package "${VET[$i]}"	'' "${VET[$i]}"
	done
}

# Functions Add-On

#function Git_Add_On() {
#
#}

function Nemo_Add_On() {

	INSTALLED="$( which xdotool)"

	(
		if ! [ -e "$INSTALLED" ]; then
			echo "$PASSWORD" | sudo -S xterm -e "$INSTALLER install xdotool -y"&


			if [ -d '/usr/share/nemo/actions' ]; then
				if ! [ -e '/usr/share/nemo/actions/nemo-refresh.nemo_action' ]; then
					echo "$PASSWORD" | sudo -S touch /usr/share/nemo/actions/nemo-refresh.nemo_action
					echo "$PASSWORD" | sudo -S bash -c 'echo -e "[Nemo Action]\nName=Atualizar\nComment=Nemo Refresh\n\
					Exec=xdotool key ctrl+r\nSelection=None\nExtensions=any;\nIcon-Name=view-refresh-symbolic\nName[tr]=Tazele" > /usr/share/nemo/actions/nemo-refresh.nemo_action'
					echo "$PASSWORD" | sudo -S nemo -q
				fi
			else
				echo "$PASSWORD" | sudo -S mkdir /usr/share/nemo/actions
				Nemo_Add_On
			fi
		fi

	) | ZenityProgress "Xdotool" && InstalationCheckup "/usr/share/nemo/actions/nemo-refresh.nemo_action" "Nemo Refresh"

}


function TermModify() {

	(
		BASHRC_ORIGINAL=~/.bashrc
		BASHRC="$(cat ~/.bashrc)" 
		echo "$BASHRC" | grep -i "source /usr/lib/git-core/git-sh-prompt"

		if [ $? != 0 ]; then 
			echo "source /usr/lib/git-core/git-sh-prompt" > "$TEMP"
		fi

		echo "$BASHRC" | grep -i "export PS1='\[\033[01;32m\]\u@\h\[\033[01;34m\] \w\[\033[0;32m\]\$(__git_ps1 \" (%s)\")\[\033[01;34m\]$\[\033[00m\] '"

		if [ $? != 0 ]; then 
			echo "$BASHRC" >> "$TEMP"
			echo "export PS1='\[\033[01;32m\]\u@\h\[\033[01;34m\] \w\[\033[0;32m\]\$(__git_ps1 \" (%s)\")\[\033[01;34m\]$\[\033[00m\] '" >> "$TEMP"
			cat "$TEMP" > "$BASHRC_ORIGINAL"
			source "$BASHRC_ORIGINAL"
			remove -Rf $TEMP
		fi
		
		echo "$PASSWORD" | sudo -S mkdir /etc/apt/apt.conf.d
		echo "$PASSWORD" | sudo -S touch /etc/apt/apt.conf.d/99progressbar
		echo "$PASSWORD" | sudo -S bash -c 'echo -e "Dpkg::Progress-Fancy \"1\";" > /etc/apt/apt.conf.d/99progressbar'
		source ~/.bashrc
	) | ZenityProgress "Componentes para o Terminal"
}


function MySQL-Workbench_Installer() {
	NAME_SOFTWARE="$1"

	(
		if [ -x "$(which mysql-workbench)" != 0 ]; then
			cd /tmp/
			MYSQL_DEB='https://cdn.mysql.com//Downloads/MySQLGUITools/mysql-workbench-community_8.0.18-1ubuntu18.04_amd64.deb'
			MYSQL_RPM='https://cdn.mysql.com//Downloads/MySQLGUITools/mysql-workbench-community-8.0.18-1.el7.x86_64.rpm'

			wget -c "$MYSQL_DEB" -O mysql-workbench."$NATIVE_TYPE_PACKAGE"
			echo "$PASSWORD" | sudo -S gdebi -n mysql-workbench."$NATIVE_TYPE_PACKAGE"
		else
			ZenityWarningSoftware "$NAME_SOFTWARE"
		fi
	) | ZenityProgress "MySQL-Workbench"
	InstalationCheckup '/usr/bin/mysql-workbench' "MySQL-Workbench"
}


function XAMPP_Install() {
	NAME_SOFTWARE="$1"

	(
		if ! [ -x "$(which /opt/lampp/xampp)" ]; then

		    if [ `uname -m` == 'x86_64' ] || [ `uname -m` == 'amd64' ] ; then
		    	cd /tmp/
		    	echo
		   		echo "$PASSWORD" | sudo -S xterm -e 'wget -c https://downloadsapachefriends.global.ssl.fastly.net/7.3.11/xampp-linux-x64-7.3.11-0-installer.run?from_af=true -O xampp-installer.run'
	            echo "$PASSWORD" | sudo -S chmod +x xampp-installer.run
		   		echo "$PASSWORD" | sudo -S xterm -e ./xampp-installer.run

			   	if [ -x '/opt/lampp/xampp' ]; then
			   		echo "$PASSWORD" | sudo -S touch /usr/share/applications/xampp.desktop
			   		echo "$PASSWORD" | sudo -S bash -c 'echo -e "[Desktop Entry]\n Version=1.0\n Name=XAMPP\n Exec=/opt/lampp/exec_xampp.sh\n Icon=/opt/lampp/htdocs/favicon.ico\n Type=Application\n Categories=Development" > /usr/share/applications/xampp.desktop'
				    echo "$PASSWORD" | sudo -S chmod +x /usr/share/applications/xampp.desktop
				    echo "$PASSWORD" | sudo -S touch /opt/lampp/exec_xampp.sh
				    echo "$PASSWORD" | sudo -S bash -c 'echo -e "#!/usr/bin/env bash\n\npkexec env DISPLAY=$DISPLAY XAUTHORITY=$XAUTHORITY /opt/lampp/manager-linux-x64.run" > /opt/lampp/exec_xampp.sh'
				    echo "$PASSWORD" | sudo -S chmod +x /opt/lampp/exec_xampp.sh
				    cp /usr/share/applications/xampp.desktop ~/Área\ de\ Trabalho/ || cp /usr/share/applications/xampp.desktop ~/Desktop/
				fi
			else
				NotSystemSuport "$NAME_SOFTWARE"
			fi
		else
			ZenityWarningSoftware "$NAME_SOFTWARE"
		fi
	) | ZenityProgress "$NAME_SOFTWARE"
	InstalationCheckup "/opt/lampp/xampp" "$NAME_SOFTWARE"
}


# Instalação de Pacotes Nativos?
#
# Função de instalação de pacotes nativos do sistema.
#
#
function Native_Install_Package() {
	PACKAGE="$1"
	PARAMETER="$2"
	NAME_SOFTWARE="$3"
	PACKAGE_WAY="$(which $PACKAGE)"

	if ! [ -e "$PACKAGE_WAY" ]; then
		(echo "$PASSWORD" | sudo -S xterm -e "$INSTALLER install $PACKAGE $PARAMETER") | ZenityProgress "$NAME_SOFTWARE"
		InstalationCheckup "$PACKAGE_WAY" "$NAME_SOFTWARE"
	else
		ZenityWarningSoftware "$NAME_SOFTWARE"
	fi

}


# Instalação de Pacotes Flatpaks?
#
# Função de instalação de pacotes flatpaks.
#
#
function Flatpak_Install_Package() {
	PACKAGE="$1"
	PARAMETER="$2"
	NAME_SOFTWARE="$3"
	KEY_INSTALATION=$(($4+0))
	PACK_WAY="$5"

	if [ $KEY_INSTALATION == 0 ]; then
		if ! [ -e "/var/lib/flatpak/app/$PACKAGE" ]; then
			(echo "$PASSWORD" | sudo -S xterm -e "flatpak install flathub $PACKAGE $PARAMETER") | ZenityProgress "$NAME_SOFTWARE"
			InstalationCheckup "/var/lib/flatpak/app/$PACKAGE" "$NAME_SOFTWARE"
		else
			ZenityWarningSoftware "$NAME_SOFTWARE"
		fi
	else
		if ! [ -e "/var/lib/flatpak/app/$PACKAGE" ]; then
			(echo "$PASSWORD" | sudo -S xterm -e "flatpak install $PACKAGE $PARAMETER") | ZenityProgress "$NAME_SOFTWARE"
			InstalationCheckup "/var/lib/flatpak/app/$PACKAGE" "$NAME_SOFTWARE"
		else
			ZenityWarningSoftware "$NAME_SOFTWARE"
		fi
	fi

}


# Instalação de Pacotes Snaps?
#
# Função de instalação de pacotes snaps.
#
#
function Snap_Install_Package() {

	PACKAGE="$1"
	PARAMETER="$2"
	NAME_SOFTWARE="$3"

	if ! [ -e "/snap/$PACKAGE" ]; then
		(echo "$PASSWORD" | sudo -S xterm -e "snap install $PACKAGE $PARAMETER") | ZenityProgress "$NAME_SOFTWARE"
		InstalationCheckup "/snap/$PACKAGE" "$NAME_SOFTWARE"
	else
		ZenityWarningSoftware "$NAME_SOFTWARE"
	fi
}


# Função de Progresso de Instalação?
#
#
function ZenityProgress() {
	NAME_SOFTWARE="$1"

	zenity --progress \
	--text="Instalando o(s) $NAME_SOFTWARE..." \
	--percentage=0 \
	--pulsate \
	--auto-close \
	--auto-kill \
	--time-remaining \
	--width=400 \
	--height=50

	unset NAME_SOFTWARE
}


# Função de Checkup de Instalação?
#
#
function InstalationCheckup() {
	
	SOFTWARE_WAY=$1
	NAME_SOFTWARE=$2

	if [ -e "$SOFTWARE_WAY" ]; then
		zenity --info --text="$NAME_SOFTWARE foi instalado com sucesso!\n\n" --ellipsize
	else
		zenity --error --text="ERRO: $NAME_SOFTWARE não pode ser instalado!\n\n" --ellipsize
	fi

	unset SOFTWARE_WAY
	unset NAME_SOFTWARE
}


# Nova Instalação?
#
# Função de diálogo de nova instalação
#vmware snap package
#
function NewInstallation(){
	$(zenity --question --text="Você deseja realizar a instalação de outro software?" --ellipsize)
	if [ $? != 0 ]; then
		CONTROLLER=1
		unset SOFTWARE_CHOSEN
		Exit 0
	else
		unset SOFTWARE_CHOSEN 	#Limpeza do conteúdo do Array SOFTWARE_CHOSEN
	fi
}


# ----------------------------------------------- EXECUTION -----------------------------------------#
Password
TesterSystemSuport
IdentifyPackageInstall
Welcome
SuportInstalation
ProgramMain

#----------------------------------------------------------------------------------------------------#
