# Matrix Stack 安装管理工具

[![License: CC BY-NC-SA 4.0](https://img.shields.io/badge/License-CC%20BY--NC--SA%204.0-lightgrey.svg)](https://creativecommons.org/licenses/by-nc-sa/4.0/)
[![Version](https://img.shields.io/badge/version-2.5.0-blue.svg)](https://github.com/niublab/test)
[![Platform](https://img.shields.io/badge/platform-Debian%2012%20%7C%20Ubuntu%2022.04+-green.svg)](https://github.com/niublab/test)

一个功能完整的 Matrix Stack 自动化安装和管理工具，专为 NAT 环境和动态 IP 设计，支持完全自定义配置。

## ✨ 主要特性

### 🚀 核心功能
- **菜单式交互界面** - 简化部署流程，适合新手使用
- **完全自定义配置** - 支持自定义域名、端口、子域名等
- **NAT 环境优化** - 专为家庭网络和动态 IP 环境设计
- **内外部端口分离** - 解决 ISP 端口封锁问题
- **Element X 完全兼容** - 支持最新的 Element X 客户端

### 👤 高级用户管理
- **用户生命周期管理** - 创建、删除、重置密码
- **注册邀请码系统** - 生成、管理、注销邀请码
- **权限管理** - 设置/取消管理员权限
- **用户状态管理** - 封禁/解封用户
- **详细用户信息** - 查看用户详情和加入的房间

### 🛠️ 完整管理功能
- **服务状态监控** - 实时查看所有组件状态
- **证书管理** - 支持 Let's Encrypt、自签名证书切换
- **日志查看** - 分组件日志查看和实时监控
- **备份恢复** - 完整的数据备份和恢复功能
- **配置更新** - 在线更新配置无需重新部署

### 🧹 清理和维护
- **智能清理** - 清理失败的部署和残留文件
- **配置重置** - 重置配置文件到初始状态
- **完全卸载** - 安全卸载所有组件和数据
- **集群管理** - K3s 集群的完整生命周期管理

## 🔧 技术特性

### 修正的问题
- ✅ **OCI Registry 支持** - 使用最新的 element-hq/ess-helm 部署方式
- ✅ **Schema 验证修正** - 解决配置文件格式兼容性问题
- ✅ **端口配置优化** - 内外部端口分离，支持自定义端口
- ✅ **SSL 跳转修正** - 正确的 HTTP 到 HTTPS 跳转逻辑
- ✅ **联邦功能支持** - 支持 8448 端口和 SRV 记录配置

### 支持的服务
- **Synapse** - Matrix 主服务器
- **Element Web** - 网页版客户端
- **Matrix Authentication Service** - 统一认证服务
- **Matrix RTC** - 实时通信服务
- **LiveKit/Coturn** - TURN 服务选择
- **Well-known Delegation** - 域名委托配置

## 📋 系统要求

### 硬件要求
- **CPU**: 4 核心或更多
- **内存**: 8GB RAM (推荐 16GB)
- **存储**: 60GB 可用空间 (推荐 SSD)

### 软件要求
- **操作系统**: Debian 12 (Bookworm) 或 Ubuntu 22.04+
- **权限**: Root 访问权限
- **网络**: 公网 IP 地址和域名

### 网络要求
- **NodePort 范围**: 30000-32767 (K8s 要求)
- **默认内部端口**: 30080 (HTTP), 30443 (HTTPS)
- **默认外部端口**: 8080 (HTTP), 8443 (HTTPS)
- **TURN 服务**: UDP 端口 30152-30252
- **联邦端口**: 8448 (可选)

## 🚀 快速开始

### 1. 下载脚本
```bash
wget https://raw.githubusercontent.com/niublab/test/main/setup.sh
chmod +x setup.sh
```

### 2. 运行安装
```bash
sudo ./setup.sh
```

### 3. 选择部署模式
- **快速部署** - 使用默认配置，适合新手
- **自定义配置** - 完全自定义所有参数

### 4. 配置网络
根据脚本提示配置路由器端口转发：
- 外部 8080 → 内部 30080 (HTTP)
- 外部 8443 → 内部 30443 (HTTPS)
- 外部 UDP 30152-30252 → 内部相同端口 (TURN)

## 📖 详细使用说明

### 部署配置

#### 快速部署模式
适合新手用户，使用推荐的默认配置：
- 自动配置所有必要组件
- 使用自签名证书（测试环境）
- 默认端口配置
- 基本的 TURN 服务配置

#### 自定义配置模式
适合高级用户，可以自定义：
- 域名和子域名配置
- 内外部端口映射
- 证书类型选择
- TURN 服务类型
- DNS 提供商配置

### 证书配置

#### Let's Encrypt (HTTP-01)
- 适用于有公网 80/443 端口的环境
- 自动申请和续期 SSL 证书
- 需要域名正确解析到服务器

#### Let's Encrypt (DNS-01)
- 适用于端口受限的环境
- 通过 DNS API 验证域名所有权
- 支持 Cloudflare、阿里云等 DNS 提供商

#### 自签名证书
- 适用于测试和内网环境
- 浏览器会显示安全警告
- 不支持联邦功能

### 用户管理

#### 创建用户
```bash
# 通过管理菜单创建
./setup.sh
# 选择: 管理已部署的服务 → 用户管理 → 创建新用户
```

#### 生成邀请码
```bash
# 生成 24 小时有效的一次性邀请码
# 通过管理菜单: 用户管理 → 生成注册邀请码
```

#### 管理员权限
```bash
# 设置用户为管理员
# 通过管理菜单: 用户管理 → 设置用户管理员权限
```

### 服务管理

#### 查看状态
```bash
./setup.sh
# 选择: 管理已部署的服务 → 查看服务状态
```

#### 查看日志
```bash
# 实时查看 Synapse 日志
./setup.sh
# 选择: 管理已部署的服务 → 查看日志 → Synapse 日志
```

#### 备份数据
```bash
./setup.sh
# 选择: 管理已部署的服务 → 备份数据
```

### 清理和维护

#### 清理失败部署
```bash
./setup.sh
# 选择: 清理/卸载部署 → 清理失败的部署
```

#### 完全卸载
```bash
./setup.sh
# 选择: 清理/卸载部署 → 完全卸载 Matrix Stack
```

## 🌐 网络配置

### 端口转发配置

#### 路由器设置
在路由器管理界面配置端口转发：

| 外部端口 | 内部端口 | 协议 | 用途 |
|---------|---------|------|------|
| 8080 | 30080 | TCP | HTTP (自动跳转到 HTTPS) |
| 8443 | 30443 | TCP | HTTPS (主要访问端口) |
| 8448 | 30448 | TCP | Matrix 联邦 (可选) |
| 30152-30252 | 30152-30252 | UDP | TURN 服务 |

#### DNS 配置
在域名管理界面添加 A 记录：
```
@ IN A 您的公网IP
* IN A 您的公网IP
```

可选的 SRV 记录（支持联邦）：
```
_matrix._tcp IN SRV 10 0 8448 您的域名.
```

### 防火墙配置

#### UFW (Ubuntu)
```bash
sudo ufw allow 30080/tcp
sudo ufw allow 30443/tcp
sudo ufw allow 30448/tcp
sudo ufw allow 30152:30252/udp
```

#### iptables
```bash
iptables -A INPUT -p tcp --dport 30080 -j ACCEPT
iptables -A INPUT -p tcp --dport 30443 -j ACCEPT
iptables -A INPUT -p tcp --dport 30448 -j ACCEPT
iptables -A INPUT -p udp --dport 30152:30252 -j ACCEPT
```

## 🔍 故障排除

### 常见问题

#### 1. 部署失败
```bash
# 查看详细错误信息
kubectl get pods -n ess
kubectl describe pod <pod-name> -n ess

# 清理失败的部署
./setup.sh
# 选择: 清理/卸载部署 → 清理失败的部署
```

#### 2. 证书申请失败
```bash
# 查看证书状态
kubectl get certificates -n ess
kubectl describe certificate <cert-name> -n ess

# 手动更新证书
./setup.sh
# 选择: 管理已部署的服务 → 证书管理 → 手动更新证书
```

#### 3. 无法访问服务
- 检查域名 DNS 解析是否正确
- 确认路由器端口转发配置
- 验证防火墙规则
- 查看 Ingress 状态：`kubectl get ingress -n ess`

#### 4. 联邦功能不工作
- 确保使用有效的 SSL 证书（非自签名）
- 检查 8448 端口是否开放
- 验证 SRV 记录配置
- 测试联邦连接：`curl https://您的域名:8448/_matrix/federation/v1/version`

### 日志查看

#### 系统日志
```bash
# K3s 服务日志
journalctl -u k3s -f

# 系统资源使用
htop
df -h
```

#### 应用日志
```bash
# 通过脚本查看
./setup.sh
# 选择: 管理已部署的服务 → 查看日志

# 直接命令行查看
kubectl logs -n ess -l app.kubernetes.io/name=synapse -f
kubectl logs -n ess -l app.kubernetes.io/name=element-web -f
```

## 📁 文件结构

```
/opt/matrix/
├── configs/
│   ├── .env                 # 环境变量配置
│   ├── values.yaml          # Helm 配置文件
│   └── cluster-issuer.yaml  # 证书签发器配置
├── backups/                 # 备份文件目录
│   └── YYYYMMDD_HHMMSS/     # 按时间戳命名的备份
└── logs/                    # 日志文件目录
```

## 🔄 更新和升级

### 更新脚本
```bash
# 下载最新版本
wget https://raw.githubusercontent.com/niublab/test/main/setup.sh -O setup.sh
chmod +x setup.sh

# 查看版本信息
./setup.sh
# 脚本会显示当前版本号
```

### 更新 Matrix Stack
```bash
./setup.sh
# 选择: 管理已部署的服务 → 更新配置
```

### 升级 K3s
```bash
# 自动升级到最新稳定版
curl -sfL https://get.k3s.io | sh -s - --disable traefik --disable servicelb
```

## 🤝 贡献指南

我们欢迎社区贡献！请遵循以下步骤：

1. Fork 本仓库
2. 创建功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启 Pull Request

### 开发规范
- 所有用户界面使用中文
- 代码注释使用中文
- 遵循 Shell 脚本最佳实践
- 添加适当的错误处理

## 📄 许可证

本项目采用 [Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License](https://creativecommons.org/licenses/by-nc-sa/4.0/) 许可证。

### 许可证要点
- ✅ **允许** - 个人使用、学习、修改、分享
- ✅ **允许** - 非营利组织使用
- ✅ **允许** - 教育用途
- ❌ **禁止** - 商业用途
- ❌ **禁止** - 销售或商业分发
- 📋 **要求** - 署名原作者
- 📋 **要求** - 相同许可证分享衍生作品

### 商业使用
如需商业使用，请联系项目维护者获取商业许可证。

## 🆘 支持和帮助

### 获取帮助
- 📖 查看本 README 文档
- 🐛 [提交 Issue](https://github.com/niublab/test/issues)
- 💬 [讨论区](https://github.com/niublab/test/discussions)

### 常用资源
- [Matrix 官方文档](https://matrix.org/docs/)
- [Synapse 管理指南](https://matrix-org.github.io/synapse/latest/)
- [Element 用户指南](https://element.io/help)
- [K3s 官方文档](https://docs.k3s.io/)

## 🙏 致谢

感谢以下项目和社区：
- [Element Matrix Services](https://github.com/element-hq/ess-helm) - 提供 Helm Charts
- [Matrix.org](https://matrix.org/) - Matrix 协议和 Synapse 服务器
- [K3s](https://k3s.io/) - 轻量级 Kubernetes 发行版
- [cert-manager](https://cert-manager.io/) - Kubernetes 证书管理
- [NGINX Ingress Controller](https://kubernetes.github.io/ingress-nginx/) - Ingress 控制器

## 📊 项目状态

- **开发状态**: 活跃开发中
- **稳定性**: 生产就绪
- **维护状态**: 积极维护
- **最后更新**: 2025年6月

---

**注意**: 本项目仅供非商业用途使用。商业使用请联系项目维护者。

