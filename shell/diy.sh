#!/usr/bin/bash
set -e
UNAME_M="$(uname -m)"
readonly UNAME_M

UNAME_U="$(uname -s)"
readonly UNAME_U

# COLORS
readonly COLOUR_RESET='\e[0m'
readonly aCOLOUR=(
    '\e[38;5;154m' # 绿色 - 用于行、项目符号和分隔符 0
    '\e[1m'        # 粗体白色 - 用于主要描述
    '\e[90m'       # 灰色 - 用于版权信息
    '\e[91m'       # 红色 - 用于更新通知警告
    '\e[33m'       # 黄色 - 用于强调
    '\e[34m'       # 蓝色
    '\e[35m'       # 品红
    '\e[36m'       # 青色
    '\e[37m'       # 浅灰色
    '\e[92m'       # 浅绿色9
    '\e[93m'       # 浅黄色
    '\e[94m'       # 浅蓝色
    '\e[95m'       # 浅品红
    '\e[96m'       # 浅青色
    '\e[97m'       # 白色
    '\e[40m'       # 背景黑色
    '\e[41m'       # 背景红色
    '\e[42m'       # 背景绿色
    '\e[43m'       # 背景黄色
    '\e[44m'       # 背景蓝色19
    '\e[45m'       # 背景品红
    '\e[46m'       # 背景青色21
    '\e[47m'       # 背景浅灰色
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

# 定义红色文本
RED='\033[0;31m'
# 无颜色
NC='\033[0m'
GREEN='\033[0;32m'
YELLOW="\e[33m"

declare -a menu_options
declare -A commands
menu_options=(
    "启用SSH服务"
    "安装注音输入法(新酷音输入法)"
    "安装常用办公必备软件(office、QQ、微信、远程桌面等)"
    "安装虚拟机VirtualBox 7"
    "安装虚拟机VirtualBox 7扩展包"
    "虚拟机一键格式转换(img2vdi)"
    "设置虚拟机开机自启动(headless)"
    "VirtualBox硬盘直通"
    "创建root身份的VirtualBox图标"
    "刷新虚拟硬盘的UUID"
    "准备CasaOS的使用环境"
    "安装CasaOS(包含Docker)"
    "还原配置文件os-release"
    "配置docker为国内镜像"
    "安装btop资源监控工具"
    "卸载虚拟机"
    "卸载 CasaOS"
)

commands=(
    ["启用SSH服务"]="enable_ssh"
    ["安装虚拟机VirtualBox 7"]="install_virtualbox"
    ["安装虚拟机VirtualBox 7扩展包"]="install_virtualbox_extpack"
    ["虚拟机一键格式转换(img2vdi)"]="convert_vm_format"
    ["设置虚拟机开机自启动(headless)"]="set_vm_autostart"
    ["卸载虚拟机"]="uninstall_vm"
    ["准备CasaOS的使用环境"]="prepare_for_casaos"
    ["安装CasaOS(包含Docker)"]="install_casaos"
    ["还原配置文件os-release"]="restore_os_release"
    ["卸载 CasaOS"]="uninstall_casaos"
    ["配置docker为国内镜像"]="configure_docker_mirror"
    ["安装常用办公必备软件(office、QQ、微信、远程桌面等)"]="install_need_apps"
    ["安装注音输入法(新酷音输入法)"]="install_fcitx5_chewing"
    ["安装btop资源监控工具"]="enable_btop"
    ["VirtualBox硬盘直通"]="attach_raw_disk_to_vm"
    ["创建root身份的VirtualBox图标"]="create_root_vm_desktop"
    ["刷新虚拟硬盘的UUID"]="refresh_vm_disk_uuid"
    

)

# 函数：检查并启动 SSH
enable_ssh() {
    # 检查 openssh-server 是否安装
    if dpkg -l | grep -q openssh-server; then
        echo "openssh-server 已安装。"
    else
        echo "openssh-server 未安装，正在安装..."
        sudo apt-get update
        sudo apt-get install openssh-server -y
    fi

    # 启动 SSH 服务
    sudo systemctl start ssh
    echo "SSH 服务已启动。"

    # 设置 SSH 服务开机自启
    sudo systemctl enable ssh
    echo "SSH 服务已设置为开机自启。"

    # 显示 SSH 服务状态
    sudo systemctl status ssh
}

#安装常用办公必备软件(office、QQ、微信、远程桌面等)
install_need_apps() {
    sudo apt-get upgrade -y
    sudo apt-get update
    sudo apt-get install cn.wps.wps-office com.qq.weixin.deepin com.gitee.rustdesk com.qq.im.deepin com.mozilla.firefox-zh -y
    sudo apt-get install neofetch -y
}

# 下载虚拟机安装包run，并保存为virtualbox7.run
install_virtualbox() {
    echo "安装虚拟机VirtualBox 7"
    wget -O virtualbox7.run https://download.virtualbox.org/virtualbox/7.0.12/VirtualBox-7.0.12-159484-Linux_amd64.run
    sudo sh virtualbox7.run
}

install_virtualbox_extpack() {
    wget https://download.virtualbox.org/virtualbox/7.0.12/Oracle_VM_VirtualBox_Extension_Pack-7.0.12.vbox-extpack
    sudo chmod 777 Oracle_VM_VirtualBox_Extension_Pack-7.0.12.vbox-extpack
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
    sudo apt-get update >/dev/null 2>&1
    if ! command -v pv &>/dev/null; then
        echo "pv is not installed. Installing pv..."
        sudo apt-get install pv -y || true
    else
        echo -e
    fi

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
        pv "$file_path" | gunzip -c >"${file_path%.*}" || true
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
prepare_for_casaos() {
    # 备份一下原始文件
    sudo cp /etc/os-release /etc/os-release.backup
    # 显示带有红色文本的提示信息
    echo -e
    echo -e "安装CasaOS过程会自动安装docker,为了避免docker版本冲突,\n需要${GREEN}卸载本机安装过的docker,${NC}${RED}确定要卸载docker吗。是否继续?${NC} [Y/n] "
    read -r -n 1 response
    echo
    case $response in
    [nN])
        echo "操作已取消。"
        ;;
    *)
        uninstall_docker
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
        ;;
    esac
}

#卸载docker
uninstall_docker() {
    sudo dpkg --configure -a
    sudo apt-get purge docker-ce docker-ce-cli containerd.io
    sudo apt autoremove
}

# 安装CasaOS—Docker
install_casaos() {
    prepare_for_casaos
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

install_fcitx5_chewing() {
    sudo apt-get install fcitx5-chewing -y
    if [ $? -eq 0 ]; then
        Show 0 "新酷音输入法(注音输入法) 安装成功"
        Show 0 "请您在全部应用里找到Fxitx5配置,添加新酷音"
    else
        Show 1 "安装失败，请检查错误信息"
    fi
}

# 设置开机自启动虚拟机virtualbox
set_vm_autostart() {

    # 显示带有红色文本的提示信息
    echo -e
    echo -e "设置虚拟机开机自启动,需要${GREEN}设置系统自动登录。${NC}\n${RED}这可能会带来安全风险。当然如果你后悔了,也可以在系统设置里取消自动登录。是否继续？${NC} [Y/n] "

    # 读取用户的响应
    read -r -n 1 response
    echo # 新行

    case $response in
    [nN])
        echo "操作已取消。"
        exit 1
        ;;
    *)
        do_autostart_vm
        ;;
    esac

}

#设置自动登录
setautologin() {
    # 使用whoami命令获取当前有效的用户名
    USERNAME=$(whoami)

    # 设置LightDM配置以启用自动登录
    sudo sed -i '/^#autologin-user=/s/^#//' /etc/lightdm/lightdm.conf
    sudo sed -i "s/^autologin-user=.*/autologin-user=$USERNAME/" /etc/lightdm/lightdm.conf
    sudo sed -i "s/^#autologin-user-timeout=.*/autologin-user-timeout=0/" /etc/lightdm/lightdm.conf
    # 去掉开机提示:解锁您的开机密钥环
    sudo rm -rf ~/.local/share/keyrings/*
}

# 设置虚拟机自启动
do_autostart_vm() {
    # 检查系统上是否安装了VirtualBox
    if ! command -v VBoxManage >/dev/null; then
        Show 1 "未检测到VirtualBox。请先安装VirtualBox。"
        return
    fi

    # 确定/etc/rc.local文件是否存在，如果不存在，则创建它
    if [ ! -f /etc/rc.local ]; then
        echo "#!/bin/sh -e" | sudo tee /etc/rc.local >/dev/null
        sudo chmod +x /etc/rc.local
    fi

    # 获取当前用户名
    USERNAME=$(whoami)

    # 获取当前用户创建的虚拟机列表
    USER_VMS=$(VBoxManage list vms | cut -d ' ' -f 1 | sed 's/"//g')
    USER_VM_ARRAY=($USER_VMS)

    # 获取root用户创建的虚拟机列表
    ROOT_VMS=$(sudo VBoxManage list vms | cut -d ' ' -f 1 | sed 's/"//g')
    ROOT_VM_ARRAY=($ROOT_VMS)

    # 合并两个虚拟机数组
    VM_ARRAY=(${USER_VM_ARRAY[@]} ${ROOT_VM_ARRAY[@]})

    # 检查虚拟机数量
    if [ ${#VM_ARRAY[@]} -eq 0 ]; then
        Show 1 "没有检测到任何虚拟机,您应该先创建虚拟机"
        return
    fi

    # 设置自动登录 免GUI桌面登录
    setautologin

    # 创建一个临时文件用于存储新的rc.local内容
    TMP_RC_LOCAL=$(mktemp)

    # 向临时文件添加初始行
    echo "#!/bin/sh -e" >$TMP_RC_LOCAL
    echo "sleep 5" >>$TMP_RC_LOCAL

    # 为每个普通用户创建的虚拟机添加启动命令
    for VMNAME in "${USER_VM_ARRAY[@]}"; do
        echo "su - $USERNAME -c \"VBoxHeadless -s $VMNAME &\"" >>$TMP_RC_LOCAL
    done

    # 为每个root用户创建的虚拟机添加启动命令
    for VMNAME in "${ROOT_VM_ARRAY[@]}"; do
        echo "sudo VBoxHeadless -s $VMNAME &" >>$TMP_RC_LOCAL
    done

    # 添加exit 0到临时文件的末尾
    echo "exit 0" >>$TMP_RC_LOCAL

    # 用新的rc.local内容替换旧的rc.local文件
    cat $TMP_RC_LOCAL | sudo tee /etc/rc.local >/dev/null

    # 删除临时文件
    rm $TMP_RC_LOCAL

    # 创建一个临时文件用于存储虚拟机列表
    TMP_VM_LIST=$(mktemp)

    # 将虚拟机名称写入临时文件
    for VMNAME in "${VM_ARRAY[@]}"; do
        echo "$VMNAME" >>"$TMP_VM_LIST"
    done

    # 使用 dialog 显示虚拟机列表，并将按钮标记为“确定”
    dialog --title "下列虚拟机均已设置为开机自启动" --ok-label "确定" --textbox "$TMP_VM_LIST" 10 50

    # 清除对话框
    clear

    # 删除临时文件
    rm "$TMP_VM_LIST"

    # 显示/etc/rc.local的内容
    Show 0 "已将所有虚拟机设置为开机后台自启动。查看配置 /etc/rc.local,如下"
    cat /etc/rc.local
}



# 安装btop
enable_btop() {
    # 尝试使用 apt 安装 btop
    if sudo apt-get update >/dev/null 2>&1 && sudo apt-get install -y btop 2>/dev/null; then
        echo "btop successfully installed using apt."
        return 0
    else
        echo "Failed to install btop using apt, trying snap..."

        # 检查 snap 是否已安装
        if ! command -v snap >/dev/null; then
            echo "Snap is not installed. Installing snapd..."
            if ! sudo apt-get install -y snapd; then
                echo "Failed to install snapd."
                return 1
            fi
            echo "Snapd installed successfully."
        else
            echo "Snap is already installed."
        fi

        # 使用 snap 安装 btop
        if sudo snap install btop; then
            echo "btop successfully installed using snap."
            # 定义要添加的路径
            path_to_add="/snap/bin"
            # 检查 ~/.bashrc 中是否已存在该路径
            if ! grep -q "export PATH=\$PATH:$path_to_add" ~/.bashrc; then
                # 如果不存在，将其添加到 ~/.bashrc 文件的末尾
                echo "export PATH=\$PATH:$path_to_add" >>~/.bashrc
                echo "Path $path_to_add added to ~/.bashrc"
            else
                echo "Path $path_to_add already in ~/.bashrc"
            fi
            # 重新加载 ~/.bashrc
            source ~/.bashrc
            Show 0 "btop已经安装,你可以使用btop命令了"
            return 0
        else
            echo "Failed to install btop using snap."
            return 1
        fi
    fi
}

# 检查zenity是否安装
check_zenity_installed() {
    # 检查 zenity 是否已经安装
    if ! command -v zenity >/dev/null 2>&1; then
        echo "Zenity is not installed. Installing Zenity..."
        sudo apt-get update >/dev/null 2>&1
        sudo apt-get install zenity -y >/dev/null 2>&1
        # 再次检查是否成功安装
        if command -v zenity >/dev/null 2>&1; then
            echo "Zenity installed successfully."
        else
            echo "Failed to install Zenity."
            return 1
        fi
    else
        echo -e
        #echo "Zenity is already installed."
    fi
}


#硬盘直通(需root身份启动vm)
attach_raw_disk_to_vm() {
    # 直通的硬盘,只能用于root身份启动的virtualbox
    check_zenity_installed

    Show 3 "注意:直通的硬盘,只能用于${YELLOW}root身份启动的${NC}virtualbox,\n请选择物理硬盘索引vmdk文件保存的位置(敲回车去选择位置)${NC} [Y/n] "
    read -r -n 1 response
    echo
    case $response in
    [nN])
        echo "操作已取消。"
        exit 1
        ;;
    *)
        vmdk_path=$(zenity --file-selection --save --confirm-overwrite --file-filter="VMDK files (vmdk) | *.vmdk" --title="Select a Path for VMDK File" 2>/dev/null)
        echo "硬盘索引保存在: $vmdk_path"
        ;;
    esac

    # 获取硬盘及其大小
    DISKS=$(lsblk -nrdo NAME,TYPE,SIZE | awk '$2=="disk" {print "/dev/"$1 " " $3}')

    # 将硬盘信息转换为 dialog 可接受的格式
    OPTIONS=()
    for DISK in $DISKS; do
        # 分割字符串以获取设备名和大小
        IFS=' ' read -r NAME SIZE <<<"$DISK"
        OPTIONS+=("${NAME}   ${SIZE}")
    done

    # 使用 dialog 显示菜单
    device=$(dialog --clear \
        --backtitle "VirtualBox硬盘直通(软直通)" \
        --title "硬盘列表" \
        --menu "请选择一个需要直通的硬盘：" 15 50 4 \
        "${OPTIONS[@]}" \
        2>&1 >/dev/tty)

    # 清除对话框
    clear
    # 输出用户选择
    echo "直通的硬盘是: ${device} 其中索引vmdk文件将创建在:${vmdk_path}"
    sudo VBoxManage internalcommands createrawvmdk -filename "$vmdk_path" -rawdisk $device

    # 检查命令执行的退出状态码
    if [ $? -eq 0 ]; then
        # 检查文件是否存在
        if [ -f "$vmdk_path" ]; then
            Show 0 "恭喜您！直通的索引 VMDK 文件已成功创建在: $vmdk_path"
            sudo chmod 777 $vmdk_path
            Show 3 "请您以root身份启动虚拟机,添加直通的硬盘索引vmdk文件即可"
            Show 3 "添加之前,请检查${device} 是否处于挂载状态。若处于挂载状态,请在磁盘管理中卸载"
        else
            echo "VMDK 文件不存在。可能是由于权限问题或路径错误。"
        fi
    else
        echo "命令执行失败。"
    fi

}

# 创建一个以root身份运行的Virtualbox7 图标
create_root_vm_desktop() {
    # 指定 .desktop 文件的路径
    local desktop_file="$HOME/Desktop/VirtualBoxRoot.desktop"
    # 创建 .desktop 文件并写入内容
    cat >"$desktop_file" <<EOF
[Desktop Entry]
Type=Application
Exec=sh -c 'pkexec env DISPLAY=\$DISPLAY XAUTHORITY=\$XAUTHORITY VirtualBox'
Name=VirtualBox (Root)
Icon=virtualbox
Terminal=false
EOF

    chmod +x "$desktop_file"
    Show 0 "以root身份运行的Virtualbox7 图标已创建,在桌面上直接双击就可以用啦！"
}

# 刷新虚拟硬盘的UUID
# 在 VirtualBox 中，每个虚拟磁盘（VDI、VMDK 等）都有一个唯一的 UUID，有时需要重新生成这个 UUID，特别是在复制或移动虚拟磁盘文件时。
refresh_vm_disk_uuid() {
    check_zenity_installed
    # 让用户选择虚拟磁盘文件
    local disk_path=$(zenity --file-selection --title="Select a Virtual Disk File" --file-filter="*.vmdk *.vdi" 2>/dev/null)

    # 检查用户是否选择了文件
    if [ -z "$disk_path" ]; then
        zenity --error --text="No file selected. Operation cancelled." --width=400 --height=200 2>/dev/null
        return 1
    fi

    # 检查磁盘文件是否存在
    if [ ! -f "$disk_path" ]; then
        zenity --error --text="Disk file not found: $disk_path" --width=400 --height=200 2>/dev/null
        return 1
    fi

    # 使用 VBoxManage 命令刷新 UUID
    if  VBoxManage internalcommands sethduuid "$disk_path" >/dev/null 2>&1; then
        zenity --info --text="恭喜你!虚拟硬盘UUID刷新成功了\n文件位于:$disk_path" --width=400 --height=200 2>/dev/null
    else
        zenity --error --text="Failed to refresh UUID for disk: $disk_path" --width=400 --height=200 2>/dev/null
    fi
}



show_menu() {
    clear
    YELLOW="\e[33m"
    NO_COLOR="\e[0m"

    echo -e "${GREEN_LINE}"
    echo '
    ***********  DIY NAS 工具箱v1.1  ***************
    适配系统:deepin 20.9/v23 beta2(基于debian)
    脚本作用:快速部署一个办公场景下的Diy NAS
    
            --- Made by wukong with YOU ---
    '
    echo -e "${GREEN_LINE}"
    echo "请选择操作："

    for i in "${!menu_options[@]}"; do
        if [[ "${menu_options[i]}" == "设置虚拟机开机自启动(headless)" ]]; then
            echo -e "$((i + 1)). ${YELLOW}${menu_options[i]}${NO_COLOR}"
        elif [[ "${menu_options[i]}" == "VirtualBox硬盘直通" ]]; then
            echo -e "$((i + 1)). ${aCOLOUR[0]}${menu_options[i]}${NO_COLOR}"
        else
            echo "$((i + 1)). ${menu_options[i]}"
        fi
    done
}

handle_choice() {
    local choice=$1
    # 检查输入是否为空
    if [[ -z $choice ]]; then
        echo -e "${RED}输入不能为空，请重新选择。${NC}"
        return
    fi

    # 检查输入是否为数字
    if ! [[ $choice =~ ^[0-9]+$ ]]; then
        echo -e "${RED}请输入有效数字!${NC}"
        return
    fi

    # 检查数字是否在有效范围内
    if [[ $choice -lt 1 ]] || [[ $choice -gt ${#menu_options[@]} ]]; then
        echo -e "${RED}选项超出范围!${NC}"
        echo -e "${YELLOW}请输入 1 到 ${#menu_options[@]} 之间的数字。${NC}"
        return
    fi

    # 执行命令
    if [ -z "${commands[${menu_options[$choice - 1]}]}" ]; then
        echo -e "${RED}无效选项，请重新选择。${NC}"
        return
    fi

    "${commands[${menu_options[$choice - 1]}]}"
}

while true; do
    show_menu
    read -p "请输入选项的序号(输入q退出): " choice
    if [[ $choice == 'q' ]]; then
        break
    fi
    handle_choice $choice
    echo "按任意键继续..."
    read -n 1 # 等待用户按键
done
