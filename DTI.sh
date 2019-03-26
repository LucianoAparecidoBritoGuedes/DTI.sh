#!/usr/bin/env bash
#
# DTI - Development Tools Installer
#
# 	- E-mail:     luciobrito2012@gmail.com
# 	- Autor:      Luciano Brito
# 	- Telefone:   +55 61 995175170
# 	- Manutenção: Luciano Brito
#
#
# ---------------------------------------------------------------------------------------------------#
#  Descrição: DTI é uma ferramenta para facilitar a instalação de pacotes
#  voltados ao desenvolvimento de software.
#
#  Exemplos: Para execultar basta abrir um terminal na pasta de download do
#  script, dar permissão de execução e digitar o segunte comando:
#
#      $ ./DTI.sh
#
#	Em alguns sistemas será possivel execultar apenas dando dois cliques com o botão
#   esquerdo do mouse, bastando apenas dar permisssão de execução previamemte.
#
# ---------------------------------------------------------------------------------------------------#
#
# Histórico:
#
#	- version 1.0 - Construido toda a aplicação contendo operações GTK com Zenity.
#
#
#
# ---------------------------------------------------------------------------------------------------#
# Testado em:
#   - bash 4.4.19
# ---------------------------------------------------------------------------------------------------#
#
# -------------------------------------------- VARIÁVEIS --------------------------------------------#
# Nome do Sistema:
	SYSTEM=$(lsb_release -i | awk {'print $3'})
#
#
# Instalador de Pacotes:
	INSTALLER=''
#
#
# Variável Senha:
	PASSWORD=''
#
#
# Chaves Flags:
	PROGRAM=0			# Registrador de suporte a flatpak?
	CONTROLLER=0 		# Controlador do Menu Principal?
#
#
# --------------------------------------------- FUNÇÕES ---------------------------------------------#
# Armazenamento de senha?
#
#
function Password() {
	
	local TEST=1
	while [ $TEST != 0 ]; do
		PASSWORD="$(zenity --password --title='Autenticação!')"
		RESULTSET="$?"
		ExecutionTest "$RESULTSET"
		if [ "$RESULTSET" == 0 ]; then
			if [ "$PASSWORD" == "" ]; then
				zenity --warning --text="O campo de senha está vazio! Tente novamente." --ellipsize
			else
				local TEST=0
			fi
		fi
	done
}


# Identificador do instalador padrão da distro linux?
#
#
function IdentifyPackageInstall() {

	PROGRAM=1
	
	while [ $PROGRAM != 0 ]; do
		case $SYSTEM in
			'LinuxMint') SnapFlatpakSuport "apt-get" ;;
			"elementary") SnapFlatpakSuport "apt-get" ;;
			"Ubuntu") SnapFlatpakSuport "apt-get" ;;
			"Debian") SnapFlatpakSuport "apt-get" ;;
			"xubuntu") SnapFlatpakSuport "apt-get" ;;
			"Lubuntu") SnapFlatpakSuport "apt-get" ;;
			"openSUSE") SnapFlatpakSuport "zypper" ;;
			"Fedora") SnapFlatpakSuport "yum" ;;
			"CentOS") SnapFlatpakSuport "yum" ;;
			*) NotSystemSuport ;;
		esac
	done
}


# Instalador de suporte flatpaks e Snaps?
#
#
function SnapFlatpakSuport() {
	INSTALLER=$1
	[ -e /usr/bin/flatpak ] || echo "$PASSWORD" | sudo -S "$INSTALLER" install flatpak -y
	[ -e /usr/bin/snap ] || echo "$PASSWORD" | sudo -S "$INSTALLER" install snapd -y
	[ -e /usr/bin/flatpak ] && [ -e /usr/bin/snap ] && PROGRAM=0
}


#------------------------------------------- WELCOME ------------------------------------------------#
# Função padrão de boas vindas?
#
#
function Welcome() {
	
	zenity --info --text="Seja bem-vindo(a) $USER \n\n 
	Este programa viabilizará a instalação de vários outros
	programas voltados ao desenvolvimento de softwares.\n\n
	Para possibilitar a instalação desses softwares serão instalados em seu sistema:
	* Suporte a Pacotes Flatpak - Desenvolvido pela RHEL;
	* Suporte a Pacotes Snap - Desenvolvido pela Canonical.\n\n
	Para prosseguir clique em OK ou feche para encerrar!" --ellipsize
	
	ExecutionTest "$?"
}


# -------------------------------------------- ERROR ------------------------------------------------#
# Sistema não suportado?
#
# Basicamente o sistema será não suportado quando não houver uma entrada para ele
# no identificador do instalador padrão.
function NotSystemSuport() {
	zenity --error --text="ERRO: Seu sistema não possui suporte para este programa." --ellipsize
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
		zenity --info --text="Obrigado por utilizar nosso software!  " --ellipsize
		exit 1
	else 
		zenity --info --text="Obrigado por utilizar nosso software!  " --ellipsize
		CONTROLLER=1
		exit 0
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

	while [ $CONTROLLER == 0 ]; do
		TYPE_PROGRAM="$(zenity --list \
		--title="Instalador de Programas" \
		--text="Escolha um tipo de programa a ser instalado!" \
		--column="Itens" \
		--column="Programas" \
		--column="Descrição" \
			1 "IDEs" 							"Instala Ambientes Integrados de Desenvolvimento ..." \
			2 "Editores de Codigo" 				"Instala Atom, Sublime-Text, VSCode, Brackets ..." \
			3 "Banco de Dados" 					"Instala PostgreSQL, MySQL, XAMPP com MariaDB, OracleSQL ..." \
			4 "Ferramentas de Versionamento"	"Instala Git, GitHub, GitLab ..." \
			5 "SDKs" 							"Instala Java SDK, Android SDK ..." \
			6 "Navegadores" 					"Instala Opera, Chrome, Firefox, Chromium ..." \
			7 "Virtualizacao"					"Instala Docker, VM Ware, VirtualBox ..."  \
		--radiolist \
		--width=800 \
		--height=550)"

		RESULTSET="$?"
		ExecutionTest "$RESULTSET"

		case "$TYPE_PROGRAM" in
			'IDEs') IDEs									;;
			'Editores de Codigo') EditoresCodigo			;;
			'Banco de Dados') BancoDeDados					;;
			'Ferramentas de Versionamento') Versionadores	;;
			'SDKs') SDKs									;;
			'Navegadores') Navegadores						;;
			'Virtualizacao') Virtualizacao					;;
			*) NullOption									;;
		esac
		
		[ "$TYPE_PROGRAM" != '' ] && NewInstallation # Chamada do diálogo para nova instalação
	done
}


#------------------------------------- SOFTWARE INSTALATIONS ----------------------------------------#
# Função de Progresso de Instalação?
#
#
function ZenityProgress() {
	NAME_SOFTWARE="$1"

	zenity --progress \
	--text="Instalando o $NAME_SOFTWARE ..." \
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
	NAME_SOFTWARE="$1"
	SOFTWARE_WAY=$(type "$NAME_SOFTWARE")

	if [ -e "$(SOFTWARE_WAY)" ]; then
		zenity --info --text="$NAME_SOFTWARE foi instalado com sucesso!\n\n" --ellipsize
	else
		zenity --error --text="ERRO: $NAME_SOFTWARE não pode ser instalado!\n\n" --ellipsize
	fi

	unset NAME_SOFTWARE
	unset SOFTWARE_WAY
}


# Nova Instalação?
#
# Função de diálogo de nova instalação
#
#
function NewInstallation(){
	$(zenity --question --text="Você deseja realizar a instalação de outro software?" --ellipsize)
	if [ $? != 0 ]; then
		CONTROLLER=1 && unset SOFTWARE_CHOSEN && Exit 0
	else
		unset SOFTWARE_CHOSEN 	#Limpeza do conteúdo do Array SOFTWARE_CHOSEN
	fi
}


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
	INDEX=$(($QUANT_PARAM/3))

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
	"${SOFTWARE_CHOSEN[@]}"	\
	--checklist \
	--width=800 \
	--height=550)"

	RESULTSET=$?

	if [ $RESULTSET == 0 ] && [ "$OPTION_SOFTWARE" != '' ]; then
		OPTION_SOFTWARE="$OPTION_SOFTWARE|"
		for (( i = 0; i < $INDEX; i++ )); do
			COMPONENT="$(echo "$OPTION_SOFTWARE" | cut -d'|' -f$(($i+1)))"
			[  "$COMPONENT" != '' ] && CHOICE[$i]="$COMPONENT"
			case "${CHOICE[$i]}" in
				'Android Studio') (Android_Studio_Install) | ZenityProgress "${CHOICE[$i]}" ; InstalationCheckup "${CHOICE[$i]}" ; unset CHOICE ; break ;;
				'Netbeans') (Netbeans_Install) | ZenityProgress "${CHOICE[$i]}" ; InstalationCheckup "${CHOICE[$i]}" ; unset CHOICE ; break ;;
				'Eclipse') (Eclipse_Install) | ZenityProgress "${CHOICE[$i]}" ; InstalationCheckup "${CHOICE[$i]}" ; unset CHOICE ; break ;;
				'InteliJ IDEA Community') (InteliJ_Install) | ZenityProgress "${CHOICE[$i]}" ; InstalationCheckup "${CHOICE[$i]}" ; unset CHOICE ; break ;;
				'PyCharm Community') (PyCharm_Install) | ZenityProgress "${CHOICE[$i]}" ; InstalationCheckup "${CHOICE[$i]}" ; unset CHOICE  ; break ;;
				'PhpStorm') (PhpStorm_Install) | ZenityProgress "${CHOICE[$i]}" ; InstalationCheckup "${CHOICE[$i]}" ; unset CHOICE  ; break ;;
				'MonoDevelop') (MonoDevelop_Install) | ZenityProgress "${CHOICE[$i]}" ; InstalationCheckup "${CHOICE[$i]}" ; unset CHOICE  ; break ;;
				'Aduino IDE') (Aduino_IDE_Install) | ZenityProgress "${CHOICE[$i]}" ; InstalationCheckup "${CHOICE[$i]}" ; unset CHOICE  ; break ;;
				'Geany') Geany_Install | ZenityProgress "${CHOICE[$i]}" ; InstalationCheckup "${CHOICE[$i]}" ; unset CHOICE ; break ;;
				'CodeBlocks') (CodeBlocks_Install) | ZenityProgress "${CHOICE[$i]}" ; InstalationCheckup "${CHOICE[$i]}" ; unset CHOICE  ; break ;;
				'Atom') (Atom_Install) | ZenityProgress "${CHOICE[$i]}" ; InstalationCheckup "${CHOICE[$i]}" ; unset CHOICE  ; break ;;
				'Sublime Text') (Sublime_Text_Install) | ZenityProgress "${CHOICE[$i]}" ; unset CHOICE  ; break ;;
				'Brackets') (Brackets_Install) | ZenityProgress "${CHOICE[$i]}" ; InstalationCheckup "${CHOICE[$i]}" ; unset CHOICE  ; break ;;
				'VS Code') (VS_Code_Install) | ZenityProgress "${CHOICE[$i]}" ; InstalationCheckup "${CHOICE[$i]}" ; unset CHOICE  ; break ;;
				'Notepadqq') (Notepadqq_Install) | ZenityProgress "${CHOICE[$i]}" ; InstalationCheckup "${CHOICE[$i]}" ; unset CHOICE  ; break ;;
				'Vim') (Vim_Install) | ZenityProgress "${CHOICE[$i]}" ; InstalationCheckup "${CHOICE[$i]}" ; unset CHOICE  ; break ;;
				'DBeaver Community') (DBeaver_Community_Install) | ZenityProgress "${CHOICE[$i]}" ; InstalationCheckup "${CHOICE[$i]}" ; unset CHOICE  ; break ;;
				'PostgreSQL') (PostgreSQL_Install) | ZenityProgress "${CHOICE[$i]}" ; InstalationCheckup "${CHOICE[$i]}" ; unset CHOICE  ; break ;;
				'MySQL') (MySQL_Install) | ZenityProgress "${CHOICE[$i]}" ; InstalationCheckup "${CHOICE[$i]}" ; unset CHOICE  ; break ;;
				'MariaDB') (MariaDB_Install) | ZenityProgress "${CHOICE[$i]}" ; InstalationCheckup "${CHOICE[$i]}" ; unset CHOICE  ; break ;;
				'Oracle Databases') (Oracle_Install) | ZenityProgress "${CHOICE[$i]}" ; InstalationCheckup "${CHOICE[$i]}" ; unset CHOICE  ; break ;;
				'IBM DB2') (DB2_Install) | ZenityProgress "${CHOICE[$i]}" ; InstalationCheckup "${CHOICE[$i]}" ; unset CHOICE  ; break ;;
				'MongoDB') (MongoDB_Install) | ZenityProgress "${CHOICE[$i]}" ; InstalationCheckup "${CHOICE[$i]}" ; unset CHOICE  ; break ;;
				'Git') (Git_Install) | ZenityProgress "${CHOICE[$i]}" ; InstalationCheckup "${CHOICE[$i]}" ; unset CHOICE  ; break ;;
				'GitKraken') (GitKraken_Install) | ZenityProgress "${CHOICE[$i]}" ; InstalationCheckup "${CHOICE[$i]}" ; unset CHOICE  ; break ;;
				'GitHub') (GitHub_Install) | ZenityProgress "${CHOICE[$i]}" ; InstalationCheckup "${CHOICE[$i]}" ; unset CHOICE  ; break ;;
				'GitLab') (GitLab_Install) | ZenityProgress "${CHOICE[$i]}" ; InstalationCheckup "${CHOICE[$i]}" ; unset CHOICE  ; break ;;
				'Subversion') (SVN_Install) | ZenityProgress "${CHOICE[$i]}" ; InstalationCheckup "${CHOICE[$i]}" ; unset CHOICE  ; break ;;
				'Java SDK') (Java_SDK_Install) | ZenityProgress "${CHOICE[$i]}" ; InstalationCheckup "${CHOICE[$i]}" ; unset CHOICE  ; break ;;
				'Android SDK') (Android_SDK_Install) | ZenityProgress "${CHOICE[$i]}" ; InstalationCheckup "${CHOICE[$i]}" ; unset CHOICE  ; break ;;
				'Python SDK') (Python_SDK_Install) | ZenityProgress "${CHOICE[$i]}" ; InstalationCheckup "${CHOICE[$i]}" ; unset CHOICE  ; break ;;
				'DotNet Core SDK') (DotNetCore_SDK_Install) | ZenityProgress "${CHOICE[$i]}" ; InstalationCheckup "${CHOICE[$i]}" ; unset CHOICE  ; break ;;
				'Kotlin SDK') (Kotlin_SDK_Install) | ZenityProgress "${CHOICE[$i]}" ; InstalationCheckup "${CHOICE[$i]}" ; unset CHOICE  ; break ;;
				'Node SDK') (Node_SDK_Install) | ZenityProgress "${CHOICE[$i]}" ; InstalationCheckup "${CHOICE[$i]}" ; unset CHOICE  ; break ;;
				'Chrome') (Chrome_Install) | ZenityProgress "${CHOICE[$i]}" ; InstalationCheckup "${CHOICE[$i]}" ; unset CHOICE  ; break ;;
				'Chromium') (Chromium_Install) | ZenityProgress "${CHOICE[$i]}" ; InstalationCheckup "${CHOICE[$i]}" ; unset CHOICE  ; break ;;
				'Firefox') (Firefox_Install) | ZenityProgress "${CHOICE[$i]}" ; InstalationCheckup "${CHOICE[$i]}" ; unset CHOICE  ; break ;;
				'Opera') (Opera_Install) | ZenityProgress "${CHOICE[$i]}" ; InstalationCheckup "${CHOICE[$i]}" ; unset CHOICE  ; break ;;
				'Vivaldi') (Vivaldi_Install) | ZenityProgress "${CHOICE[$i]}" ; InstalationCheckup "${CHOICE[$i]}" ; unset CHOICE  ; break ;;
				'Tor') (Tor_Install) | ZenityProgress "${CHOICE[$i]}" ; InstalationCheckup "${CHOICE[$i]}" ; unset CHOICE  ; break ;;
				'Epiphany') (Epiphany_Install) | ZenityProgress "${CHOICE[$i]}" ; InstalationCheckup "${CHOICE[$i]}" ; unset CHOICE  ; break ;;
				'Links') (Links_Install) | ZenityProgress "${CHOICE[$i]}" ; InstalationCheckup "${CHOICE[$i]}" ; unset CHOICE  ; break ;;
				'Docker') (Docker_Install) | ZenityProgress "${CHOICE[$i]}" ; InstalationCheckup "${CHOICE[$i]}" ; unset CHOICE  ; break ;;
				'VM Ware') (VM_Ware_Install) | ZenityProgress "${CHOICE[$i]}" ; InstalationCheckup "${CHOICE[$i]}" ; unset CHOICE  ; break ;;
				'VirtualBox') (VirtualBox_Install) | ZenityProgress "${CHOICE[$i]}" ; InstalationCheckup "${CHOICE[$i]}" ; unset CHOICE  ; break ;;
				*) NullOption ; unset CHOICE ; break ;;
			esac
		done
	else
		Exit 1
	fi
}


# --------------------------------------------- SUBMENUS --------------------------------------------#


function IDEs() {

	GenericSoftwareInstall \
	1 'Android Studio' 			'IDE para Desenvolvimento em Java ...' \
	2 'Netbeans' 				'IDE para Desenvolvimento em Java, PHP, Python ...' \
	3 'Eclipse' 				'IDE para Desenvolvimento em Java, PHP, Python ...' \
	4 'InteliJ IDEA Community' 	'IDE para Desenvolvimento em Java, PHP, Python ...' \
	5 'PyCharm Community' 		'IDE para Desenvolvimento em Python ...' \
	6 'PhpStorm'				'IDE para Desenvolvimento em PHP ....' \
	7 'MonoDevelop' 			'IDE para Desenvolvimento em Visual Basic, C#, ASP.NET ...' \
	8 'Aduino IDE'				'IDE para Desenvolvimento em Linguagem C/C++ ...' \
	9 'Geany' 					'IDE para Desenvolvimento em Linguagem C/C++ ...' \
	10 'CodeBlocks' 			'IDE para Desenvolvimento em Linguagem C/C++ ...' 
}


function EditoresCodigo(){

	GenericSoftwareInstall \
	1 'Atom' 					'Editores de Código Completo para Web e Desktop' \
	2 'Sublime Text' 			'Editores de Código Completo para Web e Desktop' \
	3 'Brackets' 				'Editores de Código para Web' \
	4 'VS Code' 				'Editores de Código para Web' \
	5 'Notepadqq' 				'Editores de Código Simples' \
	6 'Vim' 					'Editores de Código em Modo Texto'
}


function BancoDeDados() {

	GenericSoftwareInstall \
	1 'DBeaver Community'		'SGBD Livre Compativel com MySQL, MariaDB, PostgreSQL ...' \
	2 'PostgreSQL' 				'Banco de Dados Relacional e SGBD PgAdmin 4' \
	3 'MySQL' 					'Banco de Dados Relacional e SGBD MySQL-Workbench' \
	4 'MariaDB' 				'Banco de Dados Relacional, XAMPP e SGBD MySQL-Workbench' \
	5 'Oracle Databases' 		'Banco de Dados Relacional e SGBD Oracle' \
	6 'IBM DB2'					'Banco de Dados Relacional e SGBD IBM' \
	7 'MongoDB'					'Banco de Dados Orientado a Documentos, NoSQL e SGBD'
}


function Versionadores() {

	GenericSoftwareInstall \
	1 'Git' 					'Ferramenta de Versionamento em modo texto' \
	2 'GitKraken'				'Interface grafica para o git' \
	3 'GitHub' 					'Versionador Remoto' \
	4 'GitLab' 					'Versionador Remoto' \
	5 'Subversion'				'Versionador Remoto' \
	6 'Bitbucket'				'Versionador Remoto'
}


function SDKs() {

	GenericSoftwareInstall \
	1 'Java SDK' 				'Kit de Desenvolvimento Java' \
	2 'Android SDK' 			'Kit de Desenvolvimento Android' \
	3 'Python SDK' 				'Kit de Desenvolvimento Python' \
	4 'DotNet Core SDK'			'Kit de Desenvolvimento DotNet Core' \
	5 'Kotlin SDK'				'Kit de Desenvolvimento Kotlin' \
	6 'Node SDK'				'Kit de Desenvolvimento Node'
}


function Navegadores() {

	GenericSoftwareInstall \
	1 'Chrome' 					'Navegador Proprietário' \
	2 'Chromium' 				'Navegador Livre' \
	3 'Firefox' 				'Navegador Livre' \
 	4 'Opera' 					'Navegador Proprietário' \
	5 'Vivaldi' 				'Navegador Livre' \
	6 'Tor' 					'Navegador Livre' \
	7 'Epiphany' 				'Navegador Livre' \
	8 'Links' 					'Navegador em modo texto'
}


function Virtualizacao() {

	GenericSoftwareInstall \
	1 'Docker' 					'Tecnologia de Containers' \
	2 'VM Ware' 				'Tecnologia Hyper-v' \
	3 'VirtualBox'				'Tecnologia Hyper-v'
}


# ---------------------------------------- SOFTWARES INSTALLER --------------------------------------#
function Android_Studio_Install() {
	echo "$PASSWORD" | sudo -S flatpak install flathub com.google.AndroidStudio -y
}

function Netbeans_Install() {
	echo "$PASSWORD" | sudo -S flatpak install flathub org.apache.netbeans -y
}

function Eclipse_Install() {
	echo "$PASSWORD" | sudo -S snap install eclipse --classic
}

function InteliJ_Install() {
	echo "$PASSWORD" | sudo -S flatpak install flathub com.jetbrains.IntelliJ-IDEA-Community -y
}

function PyCharm_Install() {
	echo "$PASSWORD" | sudo -S flatpak install flathub com.jetbrains.PyCharm-Community -y
}

function PhpStorm_Install() {
	echo "$PASSWORD" | sudo -S snap install phpstorm
}

function MonoDevelop_Install() {
	echo "$PASSWORD" | sudo -S snap install eclipse --classic
}

function Aduino_IDE_Install() {
	echo "$PASSWORD" | sudo -S flatpak install flathub cc.arduino.arduinoide -y
}

function Geany_Install() {
	echo "$PASSWORD" | sudo -S flatpak install flathub org.geany.Geany -y
}

function CodeBlocks_Install() {
	echo "$PASSWORD" | sudo -S flatpak install flathub org.codeblocks.codeblocks -y
}

function Atom_Install() {
	echo "$PASSWORD" | sudo -S flatpak install flathub io.atom.Atom -y
}

function Sublime_Text_Install() {
	echo "$PASSWORD" | sudo -S flatpak install flathub com.sublimetext.three -y
}

function Brackets_Install() {
	echo "$PASSWORD" | sudo -S flatpak install flathub io.brackets.Brackets -y
}

function VS_Code_Install() {
	echo "$PASSWORD" | sudo -S flatpak install flathub com.visualstudio.code -y
}

function Notepadqq_Install() {
	echo "$PASSWORD" | sudo -S flatpak install flathub com.notepadqq.Notepadqq -y
}

function Vim_Install() {
	echo "$PASSWORD" | sudo -S flatpak install flathub org.vim.Vim -y
}

function DBeaver_Community_Install() {
	echo "$PASSWORD" | sudo -S flatpak install flathub io.dbeaver.DBeaverCommunity -y
}

function PostgreSQL_Install() {
	echo "$PASSWORD" | sudo -S snap install postgresql
}

function MySQL_Install() {
	echo "$PASSWORD" | sudo -S snap install mysql --beta
}

function MariaDB_Install() {
	echo "$PASSWORD" | sudo -S  -y
}

function Oracle_Install() {
	echo "$PASSWORD" | sudo -S  -y
}

function DB2_Install() {
	echo "$PASSWORD" | sudo -S  -y
}

function MongoDB_Install() {
	echo "$PASSWORD" | sudo -S  -y
}

function Git_Install() {
	echo "$PASSWORD" | sudo -S "$INSTALLER" install git-core -y
}

function GitKraken_Install() {
	echo "$PASSWORD" | sudo -S flatpak install flathub com.axosoft.GitKraken -y
}

function GitHub_Install() {
	echo "$PASSWORD" | sudo -S "$INSTALLER" install github -y
}

function GitLab_Install() {
	echo "$PASSWORD" | sudo -S  -y
}

function SVN_Install() {
	echo "$PASSWORD" | sudo -S  -y
}

function Java_SDK_Install () {
	echo "$PASSWORD" | sudo -S  -y
}

function Android_SDK_Install () {
	echo "$PASSWORD" | sudo -S  -y
}

function Python_SDK_Install () {
	echo "$PASSWORD" | sudo -S  -y
}

function DotNetCore_SDK_Install () {
	echo "$PASSWORD" | sudo -S snap install dotnet-sdk --classic
}

function Kotlin_SDK_Install () {
	echo "$PASSWORD" | sudo -S snap install kotlin --classic
}

function Node_SDK_Install () {
	echo "$PASSWORD" | sudo -S sudo snap install node --channel=10/stable --classic
}

function Chrome_Install() {
	echo "$PASSWORD" | sudo -S  -y
}

function Chromium_Install() {
	echo "$PASSWORD" | sudo -S snap install chromium
}

function Firefox_Install() {
	echo "$PASSWORD" | sudo -S snap install firefox
}

function Opera_Install() {
	echo "$PASSWORD" | sudo -S snap install opera
}

function Vivaldi_Install() {
	echo "$PASSWORD" | sudo -S  -y
}

function Tor_Install() {
	echo "$PASSWORD" | sudo -S snap install tor
}

function Epiphany_Install() {
	echo "$PASSWORD" | sudo -S snap install epiphany
}

function Links_Install() {
	echo "$PASSWORD" | sudo -S snap install links
}

function Docker_Install() {
	echo "$PASSWORD" | sudo -S snap install docker
}

function VM_Ware_Install() {
	echo "$PASSWORD" | sudo -S  -y
}

function VirtualBox_Install() {
	echo "$PASSWORD" | sudo -S  -y
}

# ----------------------------------------------- EXECUÇÃO ------------------------------------------#
Password
Welcome
(IdentifyPackageInstall) | ZenityProgress 'Snap e Flatpak'
ProgramMain
#----------------------------------------------------------------------------------------------------#