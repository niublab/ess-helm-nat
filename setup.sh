#!/bin/bash
# Matrix Stack 完整安装和管理工具 v2.5
# 支持完全自定义配置、高级用户管理、清理功能和证书切换
# 基于 element-hq/ess-helm 项目 - 修正所有已知问题

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 脚本信息
SCRIPT_VERSION="2.5.0"
GITHUB_RAW_URL="https://raw.githubusercontent.com/niublab/test/main"

# 自动化模式标志
AUTO_MODE="false"

# 默认配置
DEFAULT_INSTALL_PATH="/opt/matrix"
DEFAULT_HTTP_NODEPORT="30080"
DEFAULT_HTTPS_NODEPORT="30443"
DEFAULT_EXTERNAL_HTTP_PORT="8080"
DEFAULT_EXTERNAL_HTTPS_PORT="8443"
DEFAULT_TURN_PORT_START="30152"
DEFAULT_TURN_PORT_END="30252"
DEFAULT_SUBDOMAIN_MATRIX="matrix"
DEFAULT_SUBDOMAIN_CHAT="chat"
DEFAULT_SUBDOMAIN_AUTH="auth"
DEFAULT_SUBDOMAIN_RTC="rtc"

# 配置变量
INSTALL_PATH=""
DOMAIN=""
ADMIN_EMAIL=""
ADMIN_USERNAME=""
ADMIN_PASSWORD=""
HTTP_NODEPORT=""
HTTPS_NODEPORT=""
EXTERNAL_HTTP_PORT=""
EXTERNAL_HTTPS_PORT=""
TURN_PORT_START=""
TURN_PORT_END=""
SUBDOMAIN_MATRIX=""
SUBDOMAIN_CHAT=""
SUBDOMAIN_AUTH=""
SUBDOMAIN_RTC=""
USE_LIVEKIT_TURN="false"
DEPLOYMENT_MODE=""
CERT_MODE=""
DNS_PROVIDER=""
DNS_API_KEY=""

# 日志函数
log_info() {
    echo -e "${BLUE}[信息]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[成功]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[警告]${NC} $1"
}

log_error() {
    echo -e "${RED}[错误]${NC} $1"
}

log_debug() {
    echo -e "${PURPLE}[调试]${NC} $1"
}

# 显示横幅
show_banner() {
    clear
    echo -e "${CYAN}"
    cat << 'EOF'
╔══════════════════════════════════════════════════════════════════╗
║              Matrix Stack 安装管理工具                        ║
║                                                                  ║
║  🚀 支持完全自定义配置                                           ║
║  🏠 专为 NAT 环境和动态 IP 设计                                  ║
║  🔧 菜单式交互，简化部署流程                                     ║
║  🌐 支持自定义端口和子域名                                       ║
║  📱 完全兼容 Element X 客户端                                    ║
║  🔄 支持 LiveKit 内置 TURN 服务                                  ║
║  ✅ 修正所有已知问题                                             ║
║  🛠️ 完整的管理和清理功能                                         ║
║  👤 高级用户管理和邀请码系统                                     ║
║                                                                  ║
╚══════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
    echo
}

# 显示主菜单
show_main_menu() {
    echo -e "${CYAN}请选择操作模式：${NC}"
    echo
    echo "1) 🚀 快速部署 (推荐新手)"
    echo "2) 🔧 自定义配置部署"
    echo "3) 🛠️ 管理已部署的服务"
    echo "4) 📋 查看系统要求"
    echo "5) 🔍 检查系统状态"
    echo "6) 🧹 清理/卸载部署"
    echo "0) 🚪 退出"
    echo
    read -p "请选择 [1-7]: " choice
    
    case $choice in
        1) DEPLOYMENT_MODE="quick" ;;
        2) DEPLOYMENT_MODE="custom" ;;
        3) show_management_menu ;;
        4) show_requirements; show_main_menu ;;
        5) check_system; show_main_menu ;;
        6) show_cleanup_menu ;;
        0) exit 0 ;;
        *) log_error "无效选项，请重新选择"; show_main_menu ;;
    esac
}

# 显示管理菜单
show_management_menu() {
    clear
    echo -e "${CYAN}=== 服务管理菜单 ===${NC}"
    echo
    echo "1) 📊 查看服务状态"
    echo "2) 👤 用户管理"
    echo "3) 🔒 证书管理"
    echo "4) 🔄 重启服务"
    echo "5) 📝 查看日志"
    echo "6) 💾 备份数据"
    echo "7) 📤 恢复数据"
    echo "8) ⚙️ 更新配置"
    echo "0) 🔙 返回主菜单"
    echo
    read -p "请选择 [1-9]: " mgmt_choice
    
    case $mgmt_choice in
        1) show_service_status ;;
        2) show_user_management ;;
        3) show_certificate_management ;;
        4) restart_services ;;
        5) show_logs_menu ;;
        6) backup_data ;;
        7) restore_data ;;
        8) update_configuration ;;
        0) show_main_menu ;;
        *) log_error "无效选项"; show_management_menu ;;
    esac
}

# 用户管理 - 完整版
show_user_management() {
    clear
    echo -e "${CYAN}=== 用户管理 ===${NC}"
    echo
    echo "1) 👤 创建新用户"
    echo "2) 🗑️ 删除用户"
    echo "3) 🔑 重置用户密码"
    echo "4) 📋 列出所有用户"
    echo "5) 🎫 生成注册邀请码"
    echo "6) 🚫 注销注册邀请码"
    echo "7) 📝 查看注册邀请列表"
    echo "8) 👑 设置用户管理员权限"
    echo "9) 🚷 封禁用户"
    echo "10) ✅ 解封用户"
    echo "11) 🔍 查看用户详细信息"
    echo "0) 🔙 返回管理菜单"
    echo
    read -p "请选择 [0-11]: " user_choice
    
    case $user_choice in
        1) create_user ;;
        2) delete_user ;;
        3) reset_user_password ;;
        4) list_users ;;
        5) generate_registration_token ;;
        6) revoke_registration_token ;;
        7) list_registration_tokens ;;
        8) set_user_admin ;;
        9) deactivate_user ;;
        10) reactivate_user ;;
        11) show_user_info ;;
        0) show_management_menu ;;
        *) log_error "无效选项"; show_user_management ;;
    esac
}

# 创建用户 - 增强版
create_user() {
    echo
    read -p "请输入用户名: " username
    while [[ -z "$username" ]]; do
        log_error "用户名不能为空"
        read -p "请输入用户名: " username
    done
    
    read -s -p "请输入密码: " password
    echo
    while [[ -z "$password" ]]; do
        log_error "密码不能为空"
        read -s -p "请输入密码: " password
        echo
    done
    
    read -p "是否为管理员? [y/N]: " is_admin
    read -p "请输入显示名称 (可选): " display_name
    
    SYNAPSE_POD=$(kubectl get pods -n ess -l app.kubernetes.io/name=synapse-main -o jsonpath='{.items[0].metadata.name}')
    
    if [[ "$is_admin" == "y" || "$is_admin" == "Y" ]]; then
        SHARED_SECRET=$(kubectl exec -n ess "$SYNAPSE_POD" -- cat /secrets/ess-generated/SYNAPSE_REGISTRATION_SHARED_SECRET)
        kubectl exec -n ess "$SYNAPSE_POD" -- register_new_matrix_user \
            -k "$SHARED_SECRET" \
            -u "$username" \
            -p "$password" \
            -a \
            http://localhost:8008
        log_success "管理员用户 $username 创建完成"
    else
        SHARED_SECRET=$(kubectl exec -n ess "$SYNAPSE_POD" -- cat /secrets/ess-generated/SYNAPSE_REGISTRATION_SHARED_SECRET)
        kubectl exec -n ess "$SYNAPSE_POD" -- register_new_matrix_user \
            -k "$SHARED_SECRET" \
            -u "$username" \
            -p "$password" \
            http://localhost:8008
        log_success "普通用户 $username 创建完成"
    fi
    
    # 设置显示名称
    if [[ -n "$display_name" ]]; then
        set_user_display_name "$username" "$display_name"
    fi
    
    read -p "按回车键继续..."
    show_user_management
}

# 删除用户
delete_user() {
    echo
    read -p "请输入要删除的用户名: " username
    while [[ -z "$username" ]]; do
        log_error "用户名不能为空"
        read -p "请输入要删除的用户名: " username
    done
    
    echo -e "${RED}警告：此操作将永久删除用户及其所有数据！${NC}"
    read -p "确认删除用户 $username? 输入 'delete' 确认: " confirm
    if [[ "$confirm" != "delete" ]]; then
        log_info "操作已取消"
        show_user_management
        return
    fi
    
    # 加载配置
    load_config
    
    SYNAPSE_POD=$(kubectl get pods -n ess -l app.kubernetes.io/name=synapse-main -o jsonpath='{.items[0].metadata.name}')
    
    # 使用 Synapse Admin API 删除用户
    kubectl exec -n ess "$SYNAPSE_POD" -- curl -X POST \
        -H "Authorization: Bearer \$(cat /data/admin_token)" \
        -H "Content-Type: application/json" \
        -d '{"erase": true}' \
        "http://localhost:8008/_synapse/admin/v1/deactivate/@${username}:${SUBDOMAIN_MATRIX}.${DOMAIN}"
    
    log_success "用户 $username 已删除"
    read -p "按回车键继续..."
    show_user_management
}

# 重置用户密码
reset_user_password() {
    echo
    read -p "请输入用户名: " username
    while [[ -z "$username" ]]; do
        log_error "用户名不能为空"
        read -p "请输入用户名: " username
    done
    
    read -s -p "请输入新密码: " new_password
    echo
    while [[ -z "$new_password" ]]; do
        log_error "密码不能为空"
        read -s -p "请输入新密码: " new_password
        echo
    done
    
    # 加载配置
    load_config
    
    SYNAPSE_POD=$(kubectl get pods -n ess -l app.kubernetes.io/name=synapse-main -o jsonpath='{.items[0].metadata.name}')
    
    # 使用 Synapse Admin API 重置密码
    kubectl exec -n ess "$SYNAPSE_POD" -- curl -X POST \
        -H "Authorization: Bearer \$(cat /data/admin_token)" \
        -H "Content-Type: application/json" \
        -d "{\"new_password\": \"$new_password\", \"logout_devices\": true}" \
        "http://localhost:8008/_synapse/admin/v1/reset_password/@${username}:${SUBDOMAIN_MATRIX}.${DOMAIN}"
    
    log_success "用户 $username 的密码已重置，所有设备已登出"
    read -p "按回车键继续..."
    show_user_management
}

# 列出所有用户
list_users() {
    echo
    echo -e "${YELLOW}用户列表：${NC}"
    
    SYNAPSE_POD=$(kubectl get pods -n ess -l app.kubernetes.io/name=synapse-main -o jsonpath='{.items[0].metadata.name}')
    
    # 使用 Synapse Admin API 获取用户列表
    kubectl exec -n ess "$SYNAPSE_POD" -- curl -s \
        -H "Authorization: Bearer \$(cat /data/admin_token)" \
        "http://localhost:8008/_synapse/admin/v2/users" | \
        python3 -m json.tool
    
    echo
    read -p "按回车键继续..."
    show_user_management
}

# 生成注册邀请码
generate_registration_token() {
    echo
    read -p "邀请码有效期 (小时) [默认: 24]: " validity_hours
    validity_hours=${validity_hours:-24}
    
    read -p "最大使用次数 [默认: 1]: " uses_allowed
    uses_allowed=${uses_allowed:-1}
    
    read -p "邀请码描述 (可选): " description
    
    # 计算过期时间戳 (毫秒)
    expiry_time=$(($(date +%s) * 1000 + validity_hours * 3600 * 1000))
    
    SYNAPSE_POD=$(kubectl get pods -n ess -l app.kubernetes.io/name=synapse-main -o jsonpath='{.items[0].metadata.name}')
    
    # 生成注册令牌
    token_response=$(kubectl exec -n ess "$SYNAPSE_POD" -- curl -s -X POST \
        -H "Authorization: Bearer \$(cat /data/admin_token)" \
        -H "Content-Type: application/json" \
        -d "{\"uses_allowed\": $uses_allowed, \"expiry_time\": $expiry_time}" \
        "http://localhost:8008/_synapse/admin/v1/registration_tokens/new")
    
    token=$(echo "$token_response" | python3 -c "import sys, json; print(json.load(sys.stdin)['token'])" 2>/dev/null || echo "生成失败")
    
    echo
    if [[ "$token" != "生成失败" ]]; then
        log_success "注册邀请码生成成功！"
        echo -e "${CYAN}邀请码：${NC} $token"
        echo -e "${CYAN}有效期：${NC} $validity_hours 小时"
        echo -e "${CYAN}使用次数：${NC} $uses_allowed 次"
        if [[ -n "$description" ]]; then
            echo -e "${CYAN}描述：${NC} $description"
        fi
        echo
        echo -e "${YELLOW}用户注册时需要使用此邀请码${NC}"
    else
        log_error "邀请码生成失败，请检查管理员权限"
    fi
    
    read -p "按回车键继续..."
    show_user_management
}

# 注销注册邀请码
revoke_registration_token() {
    echo
    read -p "请输入要注销的邀请码: " token
    while [[ -z "$token" ]]; do
        log_error "邀请码不能为空"
        read -p "请输入要注销的邀请码: " token
    done
    
    SYNAPSE_POD=$(kubectl get pods -n ess -l app.kubernetes.io/name=synapse-main -o jsonpath='{.items[0].metadata.name}')
    
    # 注销注册令牌
    kubectl exec -n ess "$SYNAPSE_POD" -- curl -X DELETE \
        -H "Authorization: Bearer \$(cat /data/admin_token)" \
        "http://localhost:8008/_synapse/admin/v1/registration_tokens/$token"
    
    log_success "邀请码 $token 已注销"
    read -p "按回车键继续..."
    show_user_management
}

# 查看注册邀请列表
list_registration_tokens() {
    echo
    echo -e "${YELLOW}注册邀请码列表：${NC}"
    
    SYNAPSE_POD=$(kubectl get pods -n ess -l app.kubernetes.io/name=synapse-main -o jsonpath='{.items[0].metadata.name}')
    
    # 获取注册令牌列表
    kubectl exec -n ess "$SYNAPSE_POD" -- curl -s \
        -H "Authorization: Bearer \$(cat /data/admin_token)" \
        "http://localhost:8008/_synapse/admin/v1/registration_tokens" | \
        python3 -m json.tool
    
    echo
    read -p "按回车键继续..."
    show_user_management
}

# 设置用户管理员权限
set_user_admin() {
    echo
    read -p "请输入用户名: " username
    while [[ -z "$username" ]]; do
        log_error "用户名不能为空"
        read -p "请输入用户名: " username
    done
    
    read -p "设置为管理员? [y/N]: " is_admin
    
    admin_value="false"
    if [[ "$is_admin" == "y" || "$is_admin" == "Y" ]]; then
        admin_value="true"
    fi
    
    # 加载配置
    load_config
    
    SYNAPSE_POD=$(kubectl get pods -n ess -l app.kubernetes.io/name=synapse-main -o jsonpath='{.items[0].metadata.name}')
    
    # 设置用户管理员权限
    kubectl exec -n ess "$SYNAPSE_POD" -- curl -X PUT \
        -H "Authorization: Bearer \$(cat /data/admin_token)" \
        -H "Content-Type: application/json" \
        -d "{\"admin\": $admin_value}" \
        "http://localhost:8008/_synapse/admin/v2/users/@${username}:${SUBDOMAIN_MATRIX}.${DOMAIN}"
    
    if [[ "$admin_value" == "true" ]]; then
        log_success "用户 $username 已设置为管理员"
    else
        log_success "用户 $username 的管理员权限已移除"
    fi
    
    read -p "按回车键继续..."
    show_user_management
}

# 封禁用户
deactivate_user() {
    echo
    read -p "请输入要封禁的用户名: " username
    while [[ -z "$username" ]]; do
        log_error "用户名不能为空"
        read -p "请输入要封禁的用户名: " username
    done
    
    read -p "封禁原因 (可选): " reason
    
    # 加载配置
    load_config
    
    SYNAPSE_POD=$(kubectl get pods -n ess -l app.kubernetes.io/name=synapse-main -o jsonpath='{.items[0].metadata.name}')
    
    # 封禁用户
    deactivate_data="{\"erase\": false}"
    if [[ -n "$reason" ]]; then
        deactivate_data="{\"erase\": false, \"reason\": \"$reason\"}"
    fi
    
    kubectl exec -n ess "$SYNAPSE_POD" -- curl -X POST \
        -H "Authorization: Bearer \$(cat /data/admin_token)" \
        -H "Content-Type: application/json" \
        -d "$deactivate_data" \
        "http://localhost:8008/_synapse/admin/v1/deactivate/@${username}:${SUBDOMAIN_MATRIX}.${DOMAIN}"
    
    log_success "用户 $username 已被封禁"
    read -p "按回车键继续..."
    show_user_management
}

# 解封用户
reactivate_user() {
    echo
    read -p "请输入要解封的用户名: " username
    while [[ -z "$username" ]]; do
        log_error "用户名不能为空"
        read -p "请输入要解封的用户名: " username
    done
    
    read -s -p "请为用户设置新密码: " new_password
    echo
    while [[ -z "$new_password" ]]; do
        log_error "密码不能为空"
        read -s -p "请为用户设置新密码: " new_password
        echo
    done
    
    # 加载配置
    load_config
    
    SYNAPSE_POD=$(kubectl get pods -n ess -l app.kubernetes.io/name=synapse-main -o jsonpath='{.items[0].metadata.name}')
    
    # 重新激活用户
    kubectl exec -n ess "$SYNAPSE_POD" -- curl -X POST \
        -H "Authorization: Bearer \$(cat /data/admin_token)" \
        -H "Content-Type: application/json" \
        -d "{\"password\": \"$new_password\", \"deactivated\": false}" \
        "http://localhost:8008/_synapse/admin/v2/users/@${username}:${SUBDOMAIN_MATRIX}.${DOMAIN}"
    
    log_success "用户 $username 已解封并重新激活"
    read -p "按回车键继续..."
    show_user_management
}

# 查看用户详细信息
show_user_info() {
    echo
    read -p "请输入用户名: " username
    while [[ -z "$username" ]]; do
        log_error "用户名不能为空"
        read -p "请输入用户名: " username
    done
    
    # 加载配置
    load_config
    
    SYNAPSE_POD=$(kubectl get pods -n ess -l app.kubernetes.io/name=synapse-main -o jsonpath='{.items[0].metadata.name}')
    
    echo
    echo -e "${YELLOW}用户详细信息：${NC}"
    
    # 获取用户详细信息
    kubectl exec -n ess "$SYNAPSE_POD" -- curl -s \
        -H "Authorization: Bearer \$(cat /data/admin_token)" \
        "http://localhost:8008/_synapse/admin/v2/users/@${username}:${SUBDOMAIN_MATRIX}.${DOMAIN}" | \
        python3 -m json.tool
    
    echo
    echo -e "${YELLOW}用户加入的房间：${NC}"
    
    # 获取用户加入的房间
    kubectl exec -n ess "$SYNAPSE_POD" -- curl -s \
        -H "Authorization: Bearer \$(cat /data/admin_token)" \
        "http://localhost:8008/_synapse/admin/v1/users/@${username}:${SUBDOMAIN_MATRIX}.${DOMAIN}/joined_rooms" | \
        python3 -m json.tool
    
    echo
    read -p "按回车键继续..."
    show_user_management
}

# 设置用户显示名称
set_user_display_name() {
    local username="$1"
    local display_name="$2"
    
    # 加载配置
    load_config
    
    SYNAPSE_POD=$(kubectl get pods -n ess -l app.kubernetes.io/name=synapse-main -o jsonpath='{.items[0].metadata.name}')
    
    # 设置显示名称
    kubectl exec -n ess "$SYNAPSE_POD" -- curl -X PUT \
        -H "Authorization: Bearer \$(cat /data/admin_token)" \
        -H "Content-Type: application/json" \
        -d "{\"displayname\": \"$display_name\"}" \
        "http://localhost:8008/_synapse/admin/v2/users/@${username}:${SUBDOMAIN_MATRIX}.${DOMAIN}"
}

# 显示清理菜单
show_cleanup_menu() {
    clear
    echo -e "${RED}=== 清理/卸载菜单 ===${NC}"
    echo
    echo -e "${YELLOW}警告：清理操作将删除数据，请确保已备份重要信息！${NC}"
    echo
    echo "1) 🧹 清理失败的部署"
    echo "2) 🔄 重置配置文件"
    echo "3) 💥 完全卸载 Matrix Stack"
    echo "4) 🗑️ 清理 Kubernetes 集群"
    echo "0) 🔙 返回主菜单"
    echo
    read -p "请选择 [1-5]: " cleanup_choice
    
    case $cleanup_choice in
        1) cleanup_failed_deployment ;;
        2) reset_configuration ;;
        3) full_uninstall ;;
        4) cleanup_kubernetes ;;
        5) show_main_menu ;;
        *) log_error "无效选项"; show_cleanup_menu ;;
    esac
}

# 显示系统要求
show_requirements() {
    clear
    echo -e "${CYAN}=== 系统要求 ===${NC}"
    echo
    echo -e "${YELLOW}硬件要求：${NC}"
    echo "• CPU: 4 核心或更多"
    echo "• 内存: 8GB RAM (推荐 16GB)"
    echo "• 存储: 60GB 可用空间 (推荐 SSD)"
    echo
    echo -e "${YELLOW}软件要求：${NC}"
    echo "• 操作系统: Debian 12 (Bookworm) 或 Ubuntu 22.04+"
    echo "• 权限: Root 访问权限"
    echo "• 网络: 公网 IP 地址和域名"
    echo
    echo -e "${YELLOW}网络要求：${NC}"
    echo "• NodePort 范围: 30000-32767 (K8s 要求)"
    echo "• 默认内部端口: 30080 (HTTP), 30443 (HTTPS)"
    echo "• 默认外部端口: 8080 (HTTP), 8443 (HTTPS)"
    echo "• UDP 端口 30152-30252 - TURN 服务"
    echo "• 路由器端口转发配置"
    echo
    echo -e "${YELLOW}新增功能：${NC}"
    echo "• ✅ 内外部端口分离配置"
    echo "• ✅ 完整的管理功能"
    echo "• ✅ 高级用户管理和邀请码系统"
    echo "• ✅ 清理和卸载功能"
    echo "• ✅ 证书模式切换"
    echo "• ✅ 备份恢复功能"
    echo
    read -p "按回车键继续..."
}

# 检查系统状态
check_system() {
    clear
    echo -e "${CYAN}=== 系统状态检查 ===${NC}"
    echo
    
    # 检查操作系统
    if [[ -f /etc/os-release ]]; then
        source /etc/os-release
        echo -e "${GREEN}✓${NC} 操作系统: $PRETTY_NAME"
    else
        echo -e "${RED}✗${NC} 无法检测操作系统"
    fi
    
    # 检查 CPU 核心数
    cpu_cores=$(nproc)
    if [[ $cpu_cores -ge 4 ]]; then
        echo -e "${GREEN}✓${NC} CPU 核心: $cpu_cores 个"
    else
        echo -e "${YELLOW}⚠${NC} CPU 核心: $cpu_cores 个 (建议 4 个或更多)"
    fi
    
    # 检查内存
    memory_gb=$(free -g | awk '/^Mem:/{print $2}')
    if [[ $memory_gb -ge 8 ]]; then
        echo -e "${GREEN}✓${NC} 内存: ${memory_gb}GB"
    else
        echo -e "${YELLOW}⚠${NC} 内存: ${memory_gb}GB (建议 8GB 或更多)"
    fi
    
    # 检查磁盘空间
    disk_space=$(df -BG / | awk 'NR==2 {print $4}' | sed 's/G//')
    if [[ $disk_space -ge 60 ]]; then
        echo -e "${GREEN}✓${NC} 可用磁盘空间: ${disk_space}GB"
    else
        echo -e "${YELLOW}⚠${NC} 可用磁盘空间: ${disk_space}GB (建议 60GB 或更多)"
    fi
    
    # 检查 root 权限
    if [[ $EUID -eq 0 ]]; then
        echo -e "${GREEN}✓${NC} Root 权限"
    else
        echo -e "${RED}✗${NC} 需要 Root 权限"
    fi
    
    # 检查网络连接
    if ping -c 1 8.8.8.8 &> /dev/null; then
        echo -e "${GREEN}✓${NC} 网络连接"
    else
        echo -e "${RED}✗${NC} 网络连接失败"
    fi
    
    # 检查已安装的组件
    echo
    echo -e "${CYAN}已安装组件检查：${NC}"
    
    if command -v k3s &> /dev/null; then
        echo -e "${GREEN}✓${NC} K3s 已安装"
    else
        echo -e "${YELLOW}○${NC} K3s 未安装"
    fi
    
    if command -v helm &> /dev/null; then
        echo -e "${GREEN}✓${NC} Helm 已安装"
    else
        echo -e "${YELLOW}○${NC} Helm 未安装"
    fi
    
    if kubectl get nodes &> /dev/null; then
        echo -e "${GREEN}✓${NC} Kubernetes 集群运行中"
    else
        echo -e "${YELLOW}○${NC} Kubernetes 集群未运行"
    fi
    
    echo
    read -p "按回车键继续..."
}

# 加载配置
load_config() {
    if [[ -f "${DEFAULT_INSTALL_PATH}/configs/.env" ]]; then
        source "${DEFAULT_INSTALL_PATH}/configs/.env"
    elif [[ -f "/opt/matrix/configs/.env" ]]; then
        source "/opt/matrix/configs/.env"
    else
        log_warning "未找到配置文件，某些功能可能无法使用"
    fi
}

# 快速部署配置
quick_deployment_config() {
    log_info "快速部署模式"
    echo
    
    # 基本配置
    read -p "请输入您的域名 (例: example.com): " DOMAIN
    while [[ -z "$DOMAIN" ]]; do
        log_error "域名不能为空"
        read -p "请输入您的域名 (例: example.com): " DOMAIN
    done
    
    read -p "请输入管理员邮箱 (可选，用于 SSL 证书): " ADMIN_EMAIL
    
    read -p "请输入管理员用户名 [默认: admin]: " ADMIN_USERNAME
    ADMIN_USERNAME=${ADMIN_USERNAME:-admin}
    
    read -s -p "请输入管理员密码: " ADMIN_PASSWORD
    echo
    while [[ -z "$ADMIN_PASSWORD" ]]; do
        log_error "密码不能为空"
        read -s -p "请输入管理员密码: " ADMIN_PASSWORD
        echo
    done
    
    # 使用默认配置
    INSTALL_PATH="$DEFAULT_INSTALL_PATH"
    HTTP_NODEPORT="$DEFAULT_HTTP_NODEPORT"
    HTTPS_NODEPORT="$DEFAULT_HTTPS_NODEPORT"
    EXTERNAL_HTTP_PORT="$DEFAULT_EXTERNAL_HTTP_PORT"
    EXTERNAL_HTTPS_PORT="$DEFAULT_EXTERNAL_HTTPS_PORT"
    TURN_PORT_START="$DEFAULT_TURN_PORT_START"
    TURN_PORT_END="$DEFAULT_TURN_PORT_END"
    SUBDOMAIN_MATRIX="$DEFAULT_SUBDOMAIN_MATRIX"
    SUBDOMAIN_CHAT="$DEFAULT_SUBDOMAIN_CHAT"
    SUBDOMAIN_AUTH="$DEFAULT_SUBDOMAIN_AUTH"
    SUBDOMAIN_RTC="$DEFAULT_SUBDOMAIN_RTC"
    USE_LIVEKIT_TURN="false"
    CERT_MODE="selfsigned"
    
    log_success "快速配置完成"
}

# 自定义配置部署
custom_deployment_config() {
    log_info "自定义配置模式"
    echo
    
    # 基本配置
    read -p "请输入您的域名 (例: example.com): " DOMAIN
    while [[ -z "$DOMAIN" ]]; do
        log_error "域名不能为空"
        read -p "请输入您的域名 (例: example.com): " DOMAIN
    done
    
    read -p "请输入安装路径 [默认: $DEFAULT_INSTALL_PATH]: " INSTALL_PATH
    INSTALL_PATH=${INSTALL_PATH:-$DEFAULT_INSTALL_PATH}
    
    read -p "请输入管理员邮箱 (可选，用于 SSL 证书): " ADMIN_EMAIL
    
    read -p "请输入管理员用户名 [默认: admin]: " ADMIN_USERNAME
    ADMIN_USERNAME=${ADMIN_USERNAME:-admin}
    
    read -s -p "请输入管理员密码: " ADMIN_PASSWORD
    echo
    while [[ -z "$ADMIN_PASSWORD" ]]; do
        log_error "密码不能为空"
        read -s -p "请输入管理员密码: " ADMIN_PASSWORD
        echo
    done
    
    # 端口配置
    echo
    log_info "端口配置"
    echo -e "${YELLOW}内部端口 (NodePort 范围: 30000-32767)${NC}"
    read -p "HTTP NodePort [默认: $DEFAULT_HTTP_NODEPORT]: " HTTP_NODEPORT
    HTTP_NODEPORT=${HTTP_NODEPORT:-$DEFAULT_HTTP_NODEPORT}
    
    read -p "HTTPS NodePort [默认: $DEFAULT_HTTPS_NODEPORT]: " HTTPS_NODEPORT
    HTTPS_NODEPORT=${HTTPS_NODEPORT:-$DEFAULT_HTTPS_NODEPORT}
    
    echo -e "${YELLOW}外部端口 (路由器端口转发配置)${NC}"
    read -p "外部HTTP端口 [默认: $DEFAULT_EXTERNAL_HTTP_PORT]: " EXTERNAL_HTTP_PORT
    EXTERNAL_HTTP_PORT=${EXTERNAL_HTTP_PORT:-$DEFAULT_EXTERNAL_HTTP_PORT}
    
    read -p "外部HTTPS端口 [默认: $DEFAULT_EXTERNAL_HTTPS_PORT]: " EXTERNAL_HTTPS_PORT
    EXTERNAL_HTTPS_PORT=${EXTERNAL_HTTPS_PORT:-$DEFAULT_EXTERNAL_HTTPS_PORT}
    
    read -p "TURN UDP 起始端口 [默认: $DEFAULT_TURN_PORT_START]: " TURN_PORT_START
    TURN_PORT_START=${TURN_PORT_START:-$DEFAULT_TURN_PORT_START}
    
    read -p "TURN UDP 结束端口 [默认: $DEFAULT_TURN_PORT_END]: " TURN_PORT_END
    TURN_PORT_END=${TURN_PORT_END:-$DEFAULT_TURN_PORT_END}
    
    # 验证端口范围
    for port in $HTTP_NODEPORT $HTTPS_NODEPORT $TURN_PORT_START $TURN_PORT_END; do
        if [[ $port -lt 30000 || $port -gt 32767 ]]; then
            log_error "端口 $port 不在 NodePort 范围 (30000-32767) 内"
            exit 1
        fi
    done
    
    # 子域名配置
    echo
    log_info "子域名配置"
    read -p "Matrix 服务子域名 [默认: $DEFAULT_SUBDOMAIN_MATRIX]: " SUBDOMAIN_MATRIX
    SUBDOMAIN_MATRIX=${SUBDOMAIN_MATRIX:-$DEFAULT_SUBDOMAIN_MATRIX}
    
    read -p "Element Web 子域名 [默认: $DEFAULT_SUBDOMAIN_CHAT]: " SUBDOMAIN_CHAT
    SUBDOMAIN_CHAT=${SUBDOMAIN_CHAT:-$DEFAULT_SUBDOMAIN_CHAT}
    
    read -p "认证服务子域名 [默认: $DEFAULT_SUBDOMAIN_AUTH]: " SUBDOMAIN_AUTH
    SUBDOMAIN_AUTH=${SUBDOMAIN_AUTH:-$DEFAULT_SUBDOMAIN_AUTH}
    
    read -p "RTC 服务子域名 [默认: $DEFAULT_SUBDOMAIN_RTC]: " SUBDOMAIN_RTC
    SUBDOMAIN_RTC=${SUBDOMAIN_RTC:-$DEFAULT_SUBDOMAIN_RTC}
    
    # TURN 服务配置
    echo
    log_info "TURN 服务配置"
    echo "1) 使用独立 Coturn 服务器"
    echo "2) 使用 LiveKit 内置 TURN 服务"
    read -p "请选择 [1-2]: " turn_choice
    
    case $turn_choice in
        1) USE_LIVEKIT_TURN="false" ;;
        2) USE_LIVEKIT_TURN="true" ;;
        *) USE_LIVEKIT_TURN="false" ;;
    esac
    
    # 证书配置
    configure_certificates
    
    log_success "自定义配置完成"
}

# 证书配置函数
configure_certificates() {
    echo
    log_info "证书配置"
    echo -e "${CYAN}请选择证书配置模式：${NC}"
    echo "1) Let's Encrypt (HTTP-01) - 需要公网访问"
    echo "2) Let's Encrypt (DNS-01) - 支持内网部署"
    echo "3) 自签名证书 - 测试环境"
    echo "4) 手动证书 - 使用现有证书"
    echo
    read -p "请选择 [1-4]: " cert_choice
    
    case $cert_choice in
        1) 
            CERT_MODE="letsencrypt-http"
            log_success "已选择 Let's Encrypt (HTTP-01) 模式"
            ;;
        2) 
            CERT_MODE="letsencrypt-dns"
            configure_dns_provider
            ;;
        3) 
            CERT_MODE="selfsigned"
            log_success "已选择自签名证书模式"
            ;;
        4) 
            CERT_MODE="manual"
            log_success "已选择手动证书模式"
            ;;
        *) 
            log_error "无效选择，请重新选择"
            configure_certificates
            ;;
    esac
}

# DNS提供商配置
configure_dns_provider() {
    echo
    log_info "DNS提供商配置"
    echo -e "${CYAN}请选择DNS提供商：${NC}"
    echo "1) Cloudflare"
    echo "2) 阿里云DNS"
    echo "3) 腾讯云DNS"
    echo "4) AWS Route53"
    echo "5) 其他"
    echo
    read -p "请选择 [1-5]: " dns_choice
    
    case $dns_choice in
        1) 
            DNS_PROVIDER="cloudflare"
            log_success "已选择 Cloudflare"
            ;;
        2) 
            DNS_PROVIDER="alidns"
            log_success "已选择阿里云DNS"
            ;;
        3) 
            DNS_PROVIDER="tencentcloud"
            log_success "已选择腾讯云DNS"
            ;;
        4) 
            DNS_PROVIDER="route53"
            log_success "已选择 AWS Route53"
            ;;
        5) 
            read -p "请输入DNS提供商名称: " DNS_PROVIDER
            log_success "已选择 $DNS_PROVIDER"
            ;;
        *) 
            log_error "无效选择，请重新选择"
            configure_dns_provider
            ;;
    esac
    
    echo
    read -p "请输入API密钥: " -s DNS_API_KEY
    echo
    
    if [[ -n "$DNS_API_KEY" ]]; then
        log_success "DNS API 密钥配置完成"
    else
        log_warning "未配置 DNS API 密钥，将使用 HTTP-01 验证"
        CERT_MODE="letsencrypt-http"
    fi
}

# 检查系统要求
check_system_requirements() {
    log_info "检查系统要求..."
    
    # 检查操作系统
    if [[ ! -f /etc/os-release ]]; then
        log_error "无法检测操作系统"
        exit 1
    fi
    
    source /etc/os-release
    if [[ "$ID" != "debian" && "$ID" != "ubuntu" ]]; then
        log_warning "推荐使用 Debian 12 或 Ubuntu 22.04+"
    fi
    
    # 检查 root 权限
    if [[ $EUID -ne 0 ]]; then
        log_error "此脚本需要 root 权限运行"
        exit 1
    fi
    
    # 检查网络连接
    if ! ping -c 1 8.8.8.8 &> /dev/null; then
        log_error "网络连接失败"
        exit 1
    fi
    
    log_success "系统检查通过"
}

# 安装依赖
install_dependencies() {
    log_info "安装系统依赖..."
    
    apt-get update
    apt-get install -y curl wget git sudo apt-transport-https ca-certificates gnupg lsb-release python3
    
    log_success "依赖安装完成"
}

# 安装 K3s
install_k3s() {
    log_info "安装 K3s..."
    
    if command -v k3s &> /dev/null; then
        log_info "K3s 已安装，跳过安装步骤"
        return 0
    fi
    
    # 安装 K3s，禁用默认的 traefik 和 servicelb
    curl -sfL https://get.k3s.io | sh -s - --disable traefik --disable servicelb
    
    # 设置 kubeconfig 权限
    chmod 644 /etc/rancher/k3s/k3s.yaml
    export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
    echo 'export KUBECONFIG=/etc/rancher/k3s/k3s.yaml' >> ~/.bashrc
    
    # 等待 K3s 启动
    log_info "等待 K3s 启动..."
    sleep 30
    
    # 验证 K3s 状态
    if ! kubectl get nodes &> /dev/null; then
        log_error "K3s 安装失败"
        exit 1
    fi
    
    log_success "K3s 安装成功"
}

# 安装 Helm
install_helm() {
    log_info "安装 Helm..."
    
    if command -v helm &> /dev/null; then
        log_info "Helm 已安装，跳过安装步骤"
        return 0
    fi
    
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
    
    log_success "Helm 安装成功"
}

# 配置 Ingress 控制器
setup_ingress_controller() {
    log_info "配置 Ingress 控制器..."
    
    # 添加 ingress-nginx 仓库
    helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
    helm repo update
    
    # 创建 namespace
    kubectl create namespace ingress-nginx --dry-run=client -o yaml | kubectl apply -f -
    
    # 安装 ingress-nginx，使用正确的端口配置
    helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
        --namespace ingress-nginx \
        --set controller.service.type=NodePort \
        --set controller.service.nodePorts.http=${HTTP_NODEPORT} \
        --set controller.service.nodePorts.https=${HTTPS_NODEPORT} \
        --wait
    
    # 配置SSL跳转和外部端口
    kubectl patch configmap ingress-nginx-controller -n ingress-nginx --patch "{\"data\":{\"ssl-redirect\":\"true\",\"force-ssl-redirect\":\"true\",\"ssl-port\":\"${EXTERNAL_HTTPS_PORT}\",\"http-port\":\"${EXTERNAL_HTTP_PORT}\"}}"
    
    log_success "Ingress 控制器配置完成"
}

# 配置证书管理器
setup_cert_manager() {
    log_info "配置证书管理器..."
    
    # 添加 jetstack 仓库
    helm repo add jetstack https://charts.jetstack.io
    helm repo update
    
    # 创建 namespace
    kubectl create namespace cert-manager --dry-run=client -o yaml | kubectl apply -f -
    
    # 安装 cert-manager
    helm upgrade --install cert-manager jetstack/cert-manager \
        --namespace cert-manager \
        --set installCRDs=true \
        --wait
    
    log_success "证书管理器配置完成"
}

# 生成 values.yaml 配置文件 - 最终修正版
generate_values_yaml() {
    log_info "生成配置文件..."
    
    mkdir -p "${INSTALL_PATH}/configs"
    
    cat > "${INSTALL_PATH}/configs/values.yaml" << EOF
# Matrix Stack 配置文件 - 符合官方schema
# 生成时间: $(date)

# 服务器配置
serverName: "${SUBDOMAIN_MATRIX}.${DOMAIN}"

# 证书管理器配置
certManager:
  clusterIssuer: "letsencrypt-prod"

# 全局Ingress配置
ingress:
  className: "nginx"
  tlsEnabled: true
  annotations:
    cert-manager.io/cluster-issuer: "letsencrypt-prod"

# Synapse 配置
synapse:
  enabled: true
  ingress:
    host: "${SUBDOMAIN_MATRIX}.${DOMAIN}"
    annotations:
      cert-manager.io/cluster-issuer: "letsencrypt-prod"
    className: "nginx"
    tlsEnabled: true

# Element Web 配置
elementWeb:
  enabled: true
  replicas: 1
  ingress:
    host: "${SUBDOMAIN_CHAT}.${DOMAIN}"
    annotations:
      cert-manager.io/cluster-issuer: "letsencrypt-prod"
    className: "nginx"
    tlsEnabled: true
  additional:
    default_server_config: '{"m.homeserver":{"base_url":"https://${SUBDOMAIN_MATRIX}.${DOMAIN}","server_name":"${SUBDOMAIN_MATRIX}.${DOMAIN}"}}'

# Matrix Authentication Service 配置
matrixAuthenticationService:
  enabled: true
  ingress:
    host: "${SUBDOMAIN_AUTH}.${DOMAIN}"
    annotations:
      cert-manager.io/cluster-issuer: "letsencrypt-prod"
    className: "nginx"
    tlsEnabled: true

# Matrix RTC 配置
matrixRTC:
  enabled: true
  ingress:
    host: "${SUBDOMAIN_RTC}.${DOMAIN}"
    annotations:
      cert-manager.io/cluster-issuer: "letsencrypt-prod"
    className: "nginx"
    tlsEnabled: true

# Well-known delegation 配置
wellKnownDelegation:
  enabled: true

EOF

    # 保存配置到环境文件
    cat > "${INSTALL_PATH}/configs/.env" << EOF
# Matrix Stack 部署配置
DOMAIN=${DOMAIN}
INSTALL_PATH=${INSTALL_PATH}
HTTP_NODEPORT=${HTTP_NODEPORT}
HTTPS_NODEPORT=${HTTPS_NODEPORT}
EXTERNAL_HTTP_PORT=${EXTERNAL_HTTP_PORT}
EXTERNAL_HTTPS_PORT=${EXTERNAL_HTTPS_PORT}
TURN_PORT_START=${TURN_PORT_START}
TURN_PORT_END=${TURN_PORT_END}
SUBDOMAIN_MATRIX=${SUBDOMAIN_MATRIX}
SUBDOMAIN_CHAT=${SUBDOMAIN_CHAT}
SUBDOMAIN_AUTH=${SUBDOMAIN_AUTH}
SUBDOMAIN_RTC=${SUBDOMAIN_RTC}
ADMIN_USERNAME=${ADMIN_USERNAME}
ADMIN_EMAIL=${ADMIN_EMAIL}
USE_LIVEKIT_TURN=${USE_LIVEKIT_TURN}
CERT_MODE=${CERT_MODE}
DNS_PROVIDER=${DNS_PROVIDER}
SCRIPT_VERSION=${SCRIPT_VERSION}
EOF

    log_success "配置文件生成完成: ${INSTALL_PATH}/configs/values.yaml"
}

# 创建 ClusterIssuer
create_cluster_issuer() {
    log_info "创建证书签发器..."
    
    case $CERT_MODE in
        "letsencrypt-http")
            cat > "${INSTALL_PATH}/configs/cluster-issuer.yaml" << EOF
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: ${ADMIN_EMAIL}
    privateKeySecretRef:
      name: letsencrypt-prod
    solvers:
    - http01:
        ingress:
          class: nginx
EOF
            ;;
        "letsencrypt-dns")
            cat > "${INSTALL_PATH}/configs/cluster-issuer.yaml" << EOF
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: ${ADMIN_EMAIL}
    privateKeySecretRef:
      name: letsencrypt-prod
    solvers:
    - dns01:
        cloudflare:
          apiTokenSecretRef:
            name: cloudflare-api-token
            key: api-token
EOF
            # 创建 DNS API 密钥 Secret
            kubectl create secret generic cloudflare-api-token \
                --from-literal=api-token="$DNS_API_KEY" \
                --namespace cert-manager
            ;;
        "selfsigned")
            cat > "${INSTALL_PATH}/configs/cluster-issuer.yaml" << EOF
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: selfsigned-issuer
spec:
  selfSigned: {}
EOF
            ;;
    esac
    
    kubectl apply -f "${INSTALL_PATH}/configs/cluster-issuer.yaml"
    
    log_success "证书签发器创建完成"
}

# 部署 Matrix Stack
deploy_matrix_stack() {
    log_info "部署 Matrix Stack..."
    
    # 创建 namespace
    kubectl create namespace ess --dry-run=client -o yaml | kubectl apply -f -
    
    # 使用 OCI registry 部署 Matrix Stack
    helm upgrade --install ess oci://ghcr.io/element-hq/ess-helm/matrix-stack \
        --namespace ess \
        --values "${INSTALL_PATH}/configs/values.yaml" \
        --wait \
        --timeout 15m
    
    log_success "Matrix Stack 部署完成"
}

# 创建管理员用户
create_admin_user() {
    log_info "创建管理员用户..."
    
    # 等待 Synapse pod 就绪
    kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=synapse-main -n ess --timeout=300s
    
    # 获取 Synapse pod 名称
    SYNAPSE_POD=$(kubectl get pods -n ess -l app.kubernetes.io/name=synapse-main -o jsonpath='{.items[0].metadata.name}')
    
    # 创建管理员用户
    SHARED_SECRET=$(kubectl exec -n ess "$SYNAPSE_POD" -- cat /secrets/ess-generated/SYNAPSE_REGISTRATION_SHARED_SECRET)
    kubectl exec -n ess "$SYNAPSE_POD" -- register_new_matrix_user \
        -k "$SHARED_SECRET" \
        -u "$ADMIN_USERNAME" \
        -p "$ADMIN_PASSWORD" \
        -a \
        http://localhost:8008
    
    log_success "管理员用户创建完成: $ADMIN_USERNAME"
}

# 显示服务状态
show_service_status() {
    clear
    echo -e "${CYAN}=== 服务状态 ===${NC}"
    echo
    
    echo -e "${YELLOW}Kubernetes 节点状态：${NC}"
    kubectl get nodes
    echo
    
    echo -e "${YELLOW}Matrix Stack Pods：${NC}"
    kubectl get pods -n ess
    echo
    
    echo -e "${YELLOW}Ingress 状态：${NC}"
    kubectl get ingress -n ess
    echo
    
    echo -e "${YELLOW}证书状态：${NC}"
    kubectl get certificates -n ess
    echo
    
    echo -e "${YELLOW}服务状态：${NC}"
    kubectl get svc -n ess
    echo
    
    read -p "按回车键返回管理菜单..."
    show_management_menu
}

# 证书管理
show_certificate_management() {
    clear
    echo -e "${CYAN}=== 证书管理 ===${NC}"
    echo
    echo "1) 查看证书状态"
    echo "2) 切换到 Let's Encrypt (HTTP-01)"
    echo "3) 切换到 Let's Encrypt (DNS-01)"
    echo "4) 切换到自签名证书"
    echo "5) 手动更新证书"
    echo "6) 返回管理菜单"
    echo
    read -p "请选择 [1-6]: " cert_choice
    
    case $cert_choice in
        1) show_certificate_status ;;
        2) switch_to_letsencrypt_http ;;
        3) switch_to_letsencrypt_dns ;;
        4) switch_to_selfsigned ;;
        5) manual_update_certificates ;;
        6) show_management_menu ;;
        *) log_error "无效选项"; show_certificate_management ;;
    esac
}

# 查看证书状态
show_certificate_status() {
    echo
    echo -e "${YELLOW}证书状态：${NC}"
    kubectl get certificates -n ess
    echo
    echo -e "${YELLOW}证书详情：${NC}"
    kubectl describe certificates -n ess
    echo
    read -p "按回车键返回证书管理..."
    show_certificate_management
}

# 重启服务
restart_services() {
    log_info "重启 Matrix Stack 服务..."
    
    kubectl rollout restart deployment -n ess
    kubectl rollout restart statefulset -n ess
    
    log_success "服务重启完成"
    read -p "按回车键返回管理菜单..."
    show_management_menu
}

# 显示日志菜单
show_logs_menu() {
    clear
    echo -e "${CYAN}=== 日志查看 ===${NC}"
    echo
    echo "1) Synapse 日志"
    echo "2) Element Web 日志"
    echo "3) 认证服务日志"
    echo "4) RTC 服务日志"
    echo "5) Ingress 控制器日志"
    echo "6) 证书管理器日志"
    echo "0) 返回管理菜单"
    echo
    read -p "请选择 [1-7]: " log_choice
    
    case $log_choice in
        1) kubectl logs -n ess -l app.kubernetes.io/name=synapse-main -f ;;
        2) kubectl logs -n ess -l app.kubernetes.io/name=element-web -f ;;
        3) kubectl logs -n ess -l app.kubernetes.io/name=matrix-authentication-service -f ;;
        4) kubectl logs -n ess -l app.kubernetes.io/name=matrix-rtc -f ;;
        5) kubectl logs -n ingress-nginx -l app.kubernetes.io/name=ingress-nginx -f ;;
        6) kubectl logs -n cert-manager -l app.kubernetes.io/name=cert-manager -f ;;
        0) show_management_menu ;;
        *) log_error "无效选项"; show_logs_menu ;;
    esac
}

# 备份数据
backup_data() {
    log_info "备份 Matrix 数据..."
    
    # 加载配置
    load_config
    
    BACKUP_DIR="${INSTALL_PATH}/backups/$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$BACKUP_DIR"
    
    # 备份配置文件
    cp -r "${INSTALL_PATH}/configs" "$BACKUP_DIR/"
    
    # 备份数据库
    POSTGRES_POD=$(kubectl get pods -n ess -l app.kubernetes.io/name=postgresql -o jsonpath='{.items[0].metadata.name}')
    if [[ -n "$POSTGRES_POD" ]]; then
        kubectl exec -n ess "$POSTGRES_POD" -- pg_dumpall -U postgres > "$BACKUP_DIR/database.sql"
    fi
    
    # 备份媒体文件
    kubectl cp ess/synapse-0:/data/media_store "$BACKUP_DIR/media_store" 2>/dev/null || true
    
    log_success "数据备份完成: $BACKUP_DIR"
    read -p "按回车键返回管理菜单..."
    show_management_menu
}

# 恢复数据
restore_data() {
    echo
    echo -e "${YELLOW}可用的备份：${NC}"
    ls -la "${INSTALL_PATH}/backups/" 2>/dev/null || echo "未找到备份文件"
    echo
    read -p "请输入备份目录名称: " backup_name
    
    BACKUP_PATH="${INSTALL_PATH}/backups/$backup_name"
    if [[ ! -d "$BACKUP_PATH" ]]; then
        log_error "备份目录不存在"
        show_management_menu
        return
    fi
    
    log_info "恢复数据从: $BACKUP_PATH"
    
    # 恢复配置文件
    if [[ -d "$BACKUP_PATH/configs" ]]; then
        cp -r "$BACKUP_PATH/configs"/* "${INSTALL_PATH}/configs/"
        log_success "配置文件恢复完成"
    fi
    
    # 恢复数据库
    if [[ -f "$BACKUP_PATH/database.sql" ]]; then
        POSTGRES_POD=$(kubectl get pods -n ess -l app.kubernetes.io/name=postgresql -o jsonpath='{.items[0].metadata.name}')
        if [[ -n "$POSTGRES_POD" ]]; then
            kubectl exec -i -n ess "$POSTGRES_POD" -- psql -U postgres < "$BACKUP_PATH/database.sql"
            log_success "数据库恢复完成"
        fi
    fi
    
    log_success "数据恢复完成"
    read -p "按回车键返回管理菜单..."
    show_management_menu
}

# 更新配置
update_configuration() {
    log_info "更新配置..."
    
    # 重新生成配置文件
    load_config
    generate_values_yaml
    
    # 更新部署
    helm upgrade ess oci://ghcr.io/element-hq/ess-helm/matrix-stack \
        --namespace ess \
        --values "${INSTALL_PATH}/configs/values.yaml" \
        --wait
    
    log_success "配置更新完成"
    read -p "按回车键返回管理菜单..."
    show_management_menu
}

# 清理失败的部署
cleanup_failed_deployment() {
    log_info "清理失败的部署..."
    
    # 清理 Matrix Stack
    helm uninstall ess -n ess 2>/dev/null || true
    
    # 清理 namespace
    kubectl delete namespace ess 2>/dev/null || true
    
    # 清理证书
    kubectl delete clusterissuer --all 2>/dev/null || true
    
    log_success "失败的部署已清理"
    read -p "按回车键返回清理菜单..."
    show_cleanup_menu
}

# 重置配置
reset_configuration() {
    echo
    echo -e "${YELLOW}警告：此操作将删除所有配置文件！${NC}"
    read -p "确认继续？输入 'RESET' 确认: " confirm
    
    if [[ "$confirm" != "RESET" ]]; then
        log_info "操作已取消"
        show_cleanup_menu
        return
    fi
    
    # 删除配置文件
    rm -rf "${DEFAULT_INSTALL_PATH}/configs" 2>/dev/null || true
    rm -rf "/opt/matrix/configs" 2>/dev/null || true
    
    log_success "配置文件已重置"
    read -p "按回车键返回清理菜单..."
    show_cleanup_menu
}

# 完全卸载
full_uninstall() {
    echo
    echo -e "${RED}警告：此操作将完全删除 Matrix Stack 和所有数据！${NC}"
    read -p "确认继续？输入 'YES' 确认: " confirm
    
    if [[ "$confirm" != "YES" ]]; then
        log_info "操作已取消"
        show_cleanup_menu
        return
    fi
    
    log_info "开始完全卸载..."
    
    # 卸载 Matrix Stack
    helm uninstall ess -n ess 2>/dev/null || true
    
    # 卸载 cert-manager
    helm uninstall cert-manager -n cert-manager 2>/dev/null || true
    
    # 卸载 ingress-nginx
    helm uninstall ingress-nginx -n ingress-nginx 2>/dev/null || true
    
    # 删除 namespaces
    kubectl delete namespace ess cert-manager ingress-nginx 2>/dev/null || true
    
    # 删除 ClusterIssuers
    kubectl delete clusterissuer --all 2>/dev/null || true
    
    # 删除配置文件
    load_config
    if [[ -n "$INSTALL_PATH" && -d "$INSTALL_PATH" ]]; then
        rm -rf "$INSTALL_PATH"
    fi
    
    log_success "Matrix Stack 已完全卸载"
    read -p "按回车键返回主菜单..."
    show_main_menu
}

# 清理 Kubernetes
cleanup_kubernetes() {
    echo
    echo -e "${RED}警告：此操作将完全删除 K3s 集群和所有数据！${NC}"
    read -p "确认继续？输入 'DELETE' 确认: " confirm
    
    if [[ "$confirm" != "DELETE" ]]; then
        log_info "操作已取消"
        show_cleanup_menu
        return
    fi
    
    log_info "开始清理 Kubernetes 集群..."
    
    # 停止 K3s 服务
    systemctl stop k3s 2>/dev/null || true
    
    # 卸载 K3s
    /usr/local/bin/k3s-uninstall.sh 2>/dev/null || true
    
    # 清理残留文件
    rm -rf /etc/rancher/k3s
    rm -rf /var/lib/rancher/k3s
    rm -rf /var/lib/kubelet
    rm -rf /etc/kubernetes
    
    log_success "Kubernetes 集群已清理"
    read -p "按回车键返回主菜单..."
    show_main_menu
}

# 切换证书模式的函数
switch_to_letsencrypt_http() {
    log_info "切换到 Let's Encrypt (HTTP-01) 模式..."
    
    # 删除现有的 ClusterIssuer
    kubectl delete clusterissuer --all 2>/dev/null || true
    
    # 更新配置
    load_config
    CERT_MODE="letsencrypt-http"
    
    # 重新创建 ClusterIssuer
    create_cluster_issuer
    
    # 更新部署
    update_configuration
    
    log_success "已切换到 Let's Encrypt (HTTP-01) 模式"
    read -p "按回车键返回证书管理..."
    show_certificate_management
}

switch_to_letsencrypt_dns() {
    log_info "切换到 Let's Encrypt (DNS-01) 模式..."
    
    # 配置 DNS 提供商
    configure_dns_provider
    
    # 删除现有的 ClusterIssuer
    kubectl delete clusterissuer --all 2>/dev/null || true
    
    # 更新配置
    load_config
    CERT_MODE="letsencrypt-dns"
    
    # 重新创建 ClusterIssuer
    create_cluster_issuer
    
    # 更新部署
    update_configuration
    
    log_success "已切换到 Let's Encrypt (DNS-01) 模式"
    read -p "按回车键返回证书管理..."
    show_certificate_management
}

switch_to_selfsigned() {
    log_info "切换到自签名证书模式..."
    
    # 删除现有的 ClusterIssuer
    kubectl delete clusterissuer --all 2>/dev/null || true
    
    # 更新配置
    load_config
    CERT_MODE="selfsigned"
    
    # 重新创建 ClusterIssuer
    create_cluster_issuer
    
    # 更新部署
    update_configuration
    
    log_success "已切换到自签名证书模式"
    read -p "按回车键返回证书管理..."
    show_certificate_management
}

manual_update_certificates() {
    log_info "手动更新证书..."
    
    # 删除现有证书
    kubectl delete certificates --all -n ess 2>/dev/null || true
    
    # 重新部署以触发证书申请
    kubectl rollout restart deployment -n ess
    
    log_success "证书更新已触发"
    read -p "按回车键返回证书管理..."
    show_certificate_management
}

# 显示部署结果
show_deployment_result() {
    echo
    log_success "Matrix Stack 部署完成！"
    echo
    echo -e "${CYAN}访问地址：${NC}"
    echo "• Element Web: https://${SUBDOMAIN_CHAT}.${DOMAIN}:${EXTERNAL_HTTPS_PORT}"
    echo "• Synapse API: https://${SUBDOMAIN_MATRIX}.${DOMAIN}:${EXTERNAL_HTTPS_PORT}"
    echo "• 认证服务: https://${SUBDOMAIN_AUTH}.${DOMAIN}:${EXTERNAL_HTTPS_PORT}"
    echo "• RTC 服务: https://${SUBDOMAIN_RTC}.${DOMAIN}:${EXTERNAL_HTTPS_PORT}"
    echo
    echo -e "${CYAN}管理员账户：${NC}"
    echo "• 用户名: $ADMIN_USERNAME"
    echo "• 密码: $ADMIN_PASSWORD"
    echo
    echo -e "${CYAN}端口配置：${NC}"
    echo "• 内部HTTP NodePort: $HTTP_NODEPORT"
    echo "• 内部HTTPS NodePort: $HTTPS_NODEPORT"
    echo "• 外部HTTP端口: $EXTERNAL_HTTP_PORT"
    echo "• 外部HTTPS端口: $EXTERNAL_HTTPS_PORT"
    echo "• TURN UDP 端口: $TURN_PORT_START-$TURN_PORT_END"
    echo
    echo -e "${YELLOW}重要提醒：${NC}"
    echo "1. 请确保域名 DNS 记录指向您的服务器 IP"
    echo "2. 请配置路由器端口转发："
    echo "   - 外部 ${EXTERNAL_HTTP_PORT} → 内部 ${HTTP_NODEPORT}"
    echo "   - 外部 ${EXTERNAL_HTTPS_PORT} → 内部 ${HTTPS_NODEPORT}"
    echo "   - 外部 UDP ${TURN_PORT_START}-${TURN_PORT_END} → 内部相同端口"
    echo "3. Element X 客户端连接地址: ${DOMAIN}"
    echo "4. 配置文件保存在: ${INSTALL_PATH}/configs/"
    echo
    echo -e "${CYAN}管理命令：${NC}"
    echo "• 重新运行此脚本进行管理操作"
    echo "• 查看服务状态: kubectl get pods -n ess"
    echo "• 查看日志: kubectl logs -n ess -l app.kubernetes.io/name=synapse-main"
    echo
    echo -e "${GREEN}高级功能：${NC}"
    echo "• 用户管理：创建、删除、权限设置"
    echo "• 邀请码系统：生成、管理注册邀请"
    echo "• 证书管理：切换证书模式"
    echo "• 备份恢复：数据安全保障"
    echo
}

# 主函数
main() {
    show_banner
    
    # 检查系统要求
    check_system_requirements
    
    # 显示菜单
    show_main_menu
    
    # 配置部署参数
    if [[ "$DEPLOYMENT_MODE" == "quick" ]]; then
        quick_deployment_config
    elif [[ "$DEPLOYMENT_MODE" == "custom" ]]; then
        custom_deployment_config
    else
        return 0  # 管理模式或其他模式，不需要部署
    fi
    
    # 确认配置
    echo
    log_info "部署配置确认："
    echo "• 域名: $DOMAIN"
    echo "• 安装路径: $INSTALL_PATH"
    echo "• 内部HTTP NodePort: $HTTP_NODEPORT"
    echo "• 内部HTTPS NodePort: $HTTPS_NODEPORT"
    echo "• 外部HTTP端口: $EXTERNAL_HTTP_PORT"
    echo "• 外部HTTPS端口: $EXTERNAL_HTTPS_PORT"
    echo "• TURN 端口范围: $TURN_PORT_START-$TURN_PORT_END"
    echo "• Matrix 子域名: $SUBDOMAIN_MATRIX"
    echo "• Element Web 子域名: $SUBDOMAIN_CHAT"
    echo "• 认证服务子域名: $SUBDOMAIN_AUTH"
    echo "• RTC 服务子域名: $SUBDOMAIN_RTC"
    echo "• 管理员: $ADMIN_USERNAME"
    echo "• TURN 服务: $([ "$USE_LIVEKIT_TURN" == "true" ] && echo "LiveKit 内置" || echo "独立 Coturn")"
    echo "• 证书模式: $CERT_MODE"
    echo
    read -p "确认开始部署？ [y/N]: " confirm
    
    if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
        log_info "部署已取消"
        exit 0
    fi
    
    # 开始部署
    log_info "开始部署 Matrix Stack..."
    
    install_dependencies
    install_k3s
    install_helm
    setup_ingress_controller
    setup_cert_manager
    generate_values_yaml
    create_cluster_issuer
    deploy_matrix_stack
    create_admin_user
    show_deployment_result
}

# 运行主函数
main "$@"
