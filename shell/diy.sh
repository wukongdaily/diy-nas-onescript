#!/usr/bin/bash
set -e
UNAME_M="$(uname -m)"
readonly UNAME_M

UNAME_U="$(uname -s)"
readonly UNAME_U

# COLORS
readonly COLOUR_RESET='\e[0m'
readonly aCOLOUR=(
    '\e[38;5;154m' # green  	| Lines, bullets and separators
    '\e[1m'        # Bold white	| Main descriptions
    '\e[90m'       # Grey		| Credits
    '\e[91m'       # Red		| Update notifications Alert
    '\e[33m'       # Yellow		| Emphasis
)

readonly GREEN_LINE=" ${aCOLOUR[0]}─────────────────────────────────────────────────────$COLOUR_RESET"
readonly GREEN_BULLET=" ${aCOLOUR[0]}-$COLOUR_RESET"
readonly GREEN_SEPARATOR="${aCOLOUR[0]}:$COLOUR_RESET"

Show() {
    # OK
    if (($1 == 0)); then
        echo -e "${aCOLOUR[2]}[$COLOUR_RESET${aCOLOUR[0]}  OK  $COLOUR_RESET${aCOLOUR[2]}]$COLOUR_RESET $2"
    # FAILED
    elif (($1 == 1)); then
        echo -e "${aCOLOUR[2]}[$COLOUR_RESET${aCOLOUR[3]}FAILED$COLOUR_RESET${aCOLOUR[2]}]$COLOUR_RESET $2"
        exit 1
    # INFO
    elif (($1 == 2)); then
        echo -e "${aCOLOUR[2]}[$COLOUR_RESET${aCOLOUR[0]} INFO $COLOUR_RESET${aCOLOUR[2]}]$COLOUR_RESET $2"
    # NOTICE
    elif (($1 == 3)); then
        echo -e "${aCOLOUR[2]}[$COLOUR_RESET${aCOLOUR[4]}NOTICE$COLOUR_RESET${aCOLOUR[2]}]$COLOUR_RESET $2"
    fi
}

Warn() {
    echo -e "${aCOLOUR[3]}$1$COLOUR_RESET"
}

GreyStart() {
    echo -e "${aCOLOUR[2]}\c"
}

ColorReset() {
    echo -e "$COLOUR_RESET\c"
}

InitBanner() {
    echo -e "${GREEN_LINE}"
    echo -e " https://github.com/wukongdaily/diy-nas-onescript"
    echo -e "${GREEN_LINE}"
    echo -e ""
}

enable_ssh() {
    echo "启用SSH服务"
    sudo apt-get update
    apt list --upgradable
    sudo apt-get install openssh-server -y
}

#安装常用办公必备软件(office、QQ、微信、远程桌面等)
install_need_apps() {
    sudo apt-get update
    sudo apt-get install btop neofetch -y
    sudo apt-get install cn.wps.wps-office com.qq.weixin.deepin com.gitee.rustdesk com.qq.im.deepin com.mozilla.firefox-zh -y
}

# 下载虚拟机安装包run，并保存为virtualbox7.run
install_virtualbox() {
    echo "安装虚拟机VirtualBox 7"
    wget -O virtualbox7.run https://download.virtualbox.org/virtualbox/7.0.12/VirtualBox-7.0.12-159484-Linux_amd64.run
    sudo sh virtualbox7.run
}

install_virtualbox_extpack() {
    wget https://download.virtualbox.org/virtualbox/7.0.12/Oracle_VM_VirtualBox_Extension_Pack-7.0.12.vbox-extpack
    echo "y" | sudo VBoxManage extpack install --replace Oracle_VM_VirtualBox_Extension_Pack-7.0.12.vbox-extpack
    sudo VBoxManage list extpacks
    sudo groupadd usbfs
    sudo adduser $USER vboxusers
    sudo adduser $USER usbfs
    Show 0 "VM 扩展包安装完成,重启后才能生效。重启后USB才可以被虚拟机识别"
}

# 格式转换
convert_vm_format() {
    echo "虚拟机一键格式转换(img2vdi)"
    # 获取用户输入的文件路径
    read -p "请将待转换的文件拖拽到此处(img|img.zip|img.gz): " file_path

    # 去除路径两端的单引号（如果存在）
    file_path=$(echo "$file_path" | sed "s/^'//; s/'$//")

    # 验证文件是否存在
    if [ ! -f "$file_path" ]; then
        Show 1 "文件不存在，请检查路径是否正确。"
        exit 1
    fi

    # 定义目标文件路径
    target_path="${file_path%.*}.vdi"

    # 检查文件类型并进行相应的处理
    if [[ "$file_path" == *.zip ]]; then
        # 如果是 zip 文件，先解压
        Show 0 "正在解压 zip 文件..."
        unzip_dir=$(mktemp -d)
        unzip "$file_path" -d "$unzip_dir"
        img_file=$(find "$unzip_dir" -type f -name "*.img")

        if [ -z "$img_file" ]; then
            Show 1 "在 zip 文件中未找到 img 文件。"
            rm -rf "$unzip_dir"
            exit 1
        fi

        # 执行转换命令
        Show 0 "正在转换 请稍后..."
        VBoxManage convertfromraw "$img_file" "$target_path" --format VDI

        # 清理临时目录
        rm -rf "$unzip_dir"
    elif [[ "$file_path" == *.img.gz ]]; then
        # 如果是 img.gz 文件，先解压
        Show 0 "正在解压 img.gz 文件..."
        gunzip -k "$file_path"
        img_file="${file_path%.*}"

        # 执行转换命令
        Show 0 "正在转换 请稍后..."
        VBoxManage convertfromraw "$img_file" "$target_path" --format VDI

        # 删除解压后的 img 文件
        rm -f "$img_file"
    elif [[ "$file_path" == *.img ]]; then
        # 如果是 img 文件，直接执行转换
        Show 0 "正在转换 请稍后..."
        VBoxManage convertfromraw "$file_path" "$target_path" --format VDI
    else
        Show 1 "不支持的文件类型。"
        exit 1
    fi

    # 检查命令是否成功执行
    if [ $? -eq 0 ]; then
        sudo chmod 777 $target_path
        Show 0 "转换成功。转换后的文件位于：$target_path"
    else
        Show 1 "转换失败，请检查输入的路径和文件。"
    fi
}

# 卸载虚拟机
uninstall_vm() {
    echo "卸载虚拟机"
    sudo sh /opt/VirtualBox/uninstall.sh
}

#  为了深度系统顺利安装CasaOS 打补丁和临时修改os-release
patch_os_release() {
    # 备份一下原始文件
    sudo cp /etc/os-release /etc/os-release.backup
    Show 0 "准备CasaOS的使用环境..."
    Show 0 "打补丁和临时修改os-release"
    # 打补丁
    # 安装深度deepin缺少的依赖包udevil
    wget -O /tmp/udevil.deb https://cdn.jsdelivr.net/gh/wukongdaily/diy-nas-onescript@master/res/udevil.deb
    sudo dpkg -i /tmp/udevil.deb
    # 安装深度deepin缺少的依赖包mergerfs
    wget -O /tmp/mergerfs.deb https://cdn.jsdelivr.net/gh/wukongdaily/diy-nas-onescript@master/res/mergerfs.deb
    sudo dpkg -i /tmp/mergerfs.deb

    #伪装debian 12 修改系统名称和代号，待CasaOS安装成功后，还原回来
    sudo sed -i -e 's/^ID=.*$/ID=debian/' -e 's/^VERSION_CODENAME=.*$/VERSION_CODENAME=bookworm/' /etc/os-release
    Show 0 "妥啦! 深度Deepin系统下安装CasaOS的环境已经准备好 你可以安装CasaOS了."
}

# 安装CasaOS—Docker
install_casaos() {
    patch_os_release
    echo "安装CasaOS"
    curl -fsSL https://get.casaos.io | sudo bash
    Show 0 "CasaOS 已安装,正在还原配置文件"
    restore_os_release
}

# CasaOS安装成功之后,要记得还原配置文件
restore_os_release() {
    sudo cp /etc/os-release.backup /etc/os-release
    Show 0 "配置文件已还原"
}

#卸载CasaOS
uninstall_casaos() {
    Show 2 "卸载 CasaOS"
    sudo casaos-uninstall
}

#配置docker为国内镜像
configure_docker_mirror() {
    echo "配置docker为国内镜像"
    sudo mkdir -p /etc/docker

    sudo tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": [
    "https://0b27f0a81a00f3560fbdc00ddd2f99e0.mirror.swr.myhuaweicloud.com",
    "https://ypzju6vq.mirror.aliyuncs.com",
    "https://registry.docker-cn.com",
    "http://hub-mirror.c.163.com",
    "https://docker.mirrors.ustc.edu.cn"
  ]
}
EOF

    sudo systemctl daemon-reload
    sudo systemctl restart docker
    Show 0 "docker 国内镜像地址配置完毕!"
}

declare -a menu_options
declare -A commands

menu_options=(
    "启用SSH服务"
    "安装常用办公必备软件(office、QQ、微信、远程桌面等)"
    "安装虚拟机VirtualBox 7"
    "安装虚拟机VirtualBox 7扩展包"
    "卸载虚拟机"
    "虚拟机一键格式转换(img2vdi)"
    "准备CasaOS的使用环境"
    "安装CasaOS(包含Docker)"
    "还原配置文件os-release"
    "卸载 CasaOS"
    "配置docker为国内镜像"
)

commands=(
    ["启用SSH服务"]="enable_ssh"
    ["安装虚拟机VirtualBox 7"]="install_virtualbox"
    ["安装虚拟机VirtualBox 7扩展包"]="install_virtualbox_extpack"
    ["虚拟机一键格式转换(img2vdi)"]="convert_vm_format"
    ["卸载虚拟机"]="uninstall_vm"
    ["准备CasaOS的使用环境"]="patch_os_release"
    ["安装CasaOS(包含Docker)"]="install_casaos"
    ["还原配置文件os-release"]="restore_os_release"
    ["卸载 CasaOS"]="uninstall_casaos"
    ["配置docker为国内镜像"]="configure_docker_mirror"
    ["安装常用办公必备软件(office、QQ、微信、远程桌面等)"]="install_need_apps"
)

show_menu() {
    echo -e "${GREEN_LINE}"
    echo '
    ***********  DIY NAS 工具箱v1.0  ***************
    使用环境:基于debian 12的深度deepin系统(内核版本6.1)
    脚本作用:快速部署一个办公场景下的Diy NAS
    
            --- Made by wukong with YOU ---
'
    echo -e "${GREEN_LINE}"
    echo "请选择操作："
    for i in "${!menu_options[@]}"; do
        echo "$((i + 1)). ${menu_options[i]}"
    done
}

handle_choice() {
    local choice=$1

    if [ -z "${menu_options[$choice - 1]}" ] || [ -z "${commands[${menu_options[$choice - 1]}]}" ]; then
        echo "无效选项，请重新选择。"
        return
    fi

    "${commands[${menu_options[$choice - 1]}]}"
}

# 主逻辑
while true; do
    show_menu
    read -p "请输入选项的序号(输入q退出): " choice
    if [[ $choice == 'q' ]]; then
        break
    fi
    handle_choice $choice
done
