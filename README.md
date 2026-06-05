# cursor-rp

> **⚠️ 项目已归档 | Project Archived**
>
> 本项目已停止维护，最后版本为 v0.3.5 (2026-04-26)。感谢您的关注和支持。
>
> This project is no longer maintained. The final version is v0.3.5 (2026-04-26). Thank you for your attention and support.

[English](README.en.md) | [Русский](README.ru.md) | [Français](README.fr.md) | [Español](README.es.md) | [العربية](README.ar.md)

## 简介
本地反向代理工具。简洁的介绍是刻意为之。

## 安装
1. 访问 https://github.com/wisdgod/cursor-rp/releases 下载 dbwriter、modifier 和 ccursor
2. 将文件重命名为标准名称并放置在同一目录下

## 配置与使用

### 1. 账号管理 (dbwriter)

dbwriter 是一个账号管理工具，用于快速切换 Cursor 的账号信息。支持直接应用、账号池管理、当前账号导入等多种模式。

#### 基本用法

```bash
# 直接应用账号（不保存）
dbwriter apply -a <TOKEN> -m pro -s google
dbwriter apply -a <ACCESS_TOKEN> -r <REFRESH_TOKEN> -e user@example.com -m pro_plus -s auth0

# 保存账号到账号池
dbwriter save -a <TOKEN> -e user@example.com -m pro -s google
dbwriter save -a <TOKEN> -e user@example.com -m free_trial -s github --apply

# 从账号池切换账号
dbwriter use -e user@example.com
dbwriter use -m pro
dbwriter use -m pro --interactive
dbwriter use --interactive

# 查看当前 Cursor 账号
dbwriter cursor show
dbwriter cursor import

# 查看账号池
dbwriter list
dbwriter list -m pro
dbwriter list --verbose

# 管理账号池
dbwriter manage remove user@example.com
dbwriter manage disable user@example.com
dbwriter manage stats

# 全局静默模式
dbwriter -q list
dbwriter --quiet cursor import
```

#### 命令参数

**全局参数**

| 参数 | 简写 | 说明 | 默认值 |
|------|------|------|--------|
| `--pool-db` | | 账号池数据库路径 | `./accounts.db` |
| `--quiet` | `-q` | 静默模式（减少输出） | - |

**子命令：apply**（直接应用账号，不保存）

| 参数 | 简写 | 说明 | 必需 |
|------|------|------|------|
| `--access-token` | `-a` | Access Token | ✅ |
| `--refresh-token` | `-r` | Refresh Token | ❌ |
| `--email` | `-e` | 账号邮箱 | ❌ |
| `--membership` | `-m` | 会员类型 | ✅ |
| `--signup-type` | `-s` | 注册方式 | ✅ |

**子命令：save**（保存到账号池）

| 参数 | 简写 | 说明 | 必需 |
|------|------|------|------|
| `--access-token` | `-a` | Access Token | ✅ |
| `--refresh-token` | `-r` | Refresh Token | ❌ |
| `--email` | `-e` | 账号邮箱 | ❌ |
| `--membership` | `-m` | 会员类型 | ✅ |
| `--signup-type` | `-s` | 注册方式 | ✅ |
| `--apply` | | 保存后立即应用 | ❌ |

**子命令：use**（从账号池选择并应用）

| 参数 | 简写 | 说明 | 备注 |
|------|------|------|------|
| `--email` | `-e` | 通过邮箱选择 | 与 `-m` 互斥 |
| `--membership` | `-m` | 通过会员类型选择 | 与 `-e` 互斥 |
| `--interactive` | `-i` | 交互式选择 | - |

**子命令：cursor**（当前账号操作）

| 子命令 | 说明 |
|--------|------|
| `show` | 显示当前 Cursor 账号信息 |
| `import` | 将当前账号导入到账号池 |

**子命令：list**（查看账号池）

| 参数 | 简写 | 说明 |
|------|------|------|
| `--membership` | `-m` | 按会员类型筛选 |
| `--verbose` | `-v` | 显示详细信息 |

**子命令：manage**（账号池管理）

| 子命令 | 说明 |
|--------|------|
| `remove <EMAIL>` | 删除账号 |
| `disable <EMAIL>` | 禁用账号 |
| `stats` | 显示统计信息 |

**支持的类型值**

- **会员类型**：`free`, `pro`, `pro_plus`, `enterprise`, `free_trial`, `ultra`
- **注册方式**：`unknown`, `auth0`, `google`, `github`

#### 使用场景

**场景1：首次使用 - 导入现有账号**

```bash
# 1. 在 Cursor 中正常登录
# 2. 导入当前账号到账号池
dbwriter cursor import

# 3. 查看账号池
dbwriter list
```

**场景2：添加多个账号**

```bash
# 方式1：手动添加
dbwriter save -a <TOKEN1> -e work@company.com -m enterprise -s auth0
dbwriter save -a <TOKEN2> -e personal@gmail.com -m pro -s google

# 方式2：在 Cursor 中切换登录，然后导入
dbwriter cursor import  # 登录账号1后执行
# 在 Cursor 中切换到账号2
dbwriter cursor import  # 登录账号2后执行
```

**场景3：快速切换账号**

```bash
# 通过邮箱切换
dbwriter use -e work@company.com

# 通过会员类型切换
dbwriter use -m pro

# 交互式选择
dbwriter use --interactive
```

**场景4：查看当前使用的账号**

```bash
dbwriter cursor show
```

**场景5：临时使用账号（不保存）**

```bash
dbwriter apply -a <TOKEN> -m pro -s google
```

**场景6：在脚本中使用**

```bash
# 静默模式，减少输出
dbwriter -q use -e user@example.com
```

#### 注意事项

- 修改账号前请**关闭 Cursor**
- 建议为每个账号设置邮箱，便于管理
- Token 可以相同（只提供 `-a`）或不同（同时提供 `-a` 和 `-r`）
- 无邮箱账号在列表中显示为 `<无邮箱>`
- 使用 `--interactive` 时不能同时使用 `--quiet`
- 相同邮箱的账号会自动更新（不会重复）

#### 快速参考

```bash
# 常用命令速查
dbwriter cursor import             # 导入当前账号
dbwriter use -e <EMAIL>            # 切换账号
dbwriter list                      # 查看所有账号
dbwriter cursor show               # 查看当前账号

# 账号池管理
dbwriter manage stats              # 查看统计
dbwriter manage remove <EMAIL>     # 删除账号
```

### 2. 修补 Cursor (modifier)
关闭 Cursor，执行修补（每次更新后需重新执行）：
```bash
# 应用修改（子命令：apply）
# 方式1：域名替换模式（推荐）
modifier apply --domain your.domain -p 3000 --skip-hosts
# 方式2：后缀模式
modifier apply --suffix .local -p 3000 --skip-hosts

# 指定 Cursor 路径
modifier -C /path/to/cursor apply --domain your.domain

# 带 token bypass
modifier apply --domain your.domain -p 3000 --skip-hosts --pass-token

# 自定义登录 URL（自建登录服务时使用，默认 https://{domain}{:port}）
modifier apply --domain your.domain -p 3000 --skip-hosts --website-url
modifier apply --domain your.domain -p 3000 --skip-hosts --website-url https://login.custom.com

# 恢复原始状态（子命令：restore）
modifier restore --skip-hosts

# 查看当前状态（子命令：status）
modifier status

# 强制重新应用（已有修改或文件被篡改时）
modifier apply --domain your.domain -p 3000 --skip-hosts -f
modifier restore --skip-hosts -f
```

### 命令参数说明

**全局参数**
| 参数 | 简写 | 说明 |
|------|------|------|
| `--cursor-path` | `-C` | Cursor 安装路径（可选，自动检测） |
| `--debug` | | 调试模式 |

**子命令：apply**
| 参数 | 简写 | 说明 | 备注 |
|------|------|------|------|
| `--domain` | | 替换域名 | 与 `--suffix` 互斥 |
| `--suffix` | | 域名后缀 | 与 `--domain` 互斥 |
| `--port` | `-p` | 端口 | 可选 |
| `--skip-hosts` | | 跳过 hosts 文件修改 | |
| `--pass-token` | | 过 Token 校验 | |
| `--website-url` | | 自定义登录 URL（默认 `https://{domain}{:port}`） | 可选值 |
| `--force` | `-f` | 强制重新应用 | |

**子命令：restore**
| 参数 | 简写 | 说明 |
|------|------|------|
| `--skip-hosts` | | 跳过 hosts 文件 |
| `--force` | `-f` | 强制恢复（篡改检测或未检测到修改时） |

**子命令：status**

无额外参数，显示当前修改状态和文件完整性。

### 平台特别注意事项
- **Windows**：直接执行即可
- **macOS**：由于 SIP 机制需要手动签名（关闭 SIP 后可直接执行）
  - 参考脚本：[macos.sh](macos.sh)
- **Linux**：需处理 AppImage 打包格式
  - 参考脚本：[linux.sh](linux.sh)

欢迎提交 PR 改进平台适配脚本！

### 3. 配置 Hosts
若使用 `--skip-hosts` 参数，需手动添加 hosts 记录。具体域名取决于使用的模式：

**后缀模式** (`--suffix .local`)：
```
127.0.0.1 api2.cursor.sh.local api3.cursor.sh.local api4.cursor.sh.local repo42.cursor.sh.local us-asia.gcpp.cursor.sh.local us-eu.gcpp.cursor.sh.local us-only.gcpp.cursor.sh.local agent.api5.cursor.sh.local agentn.api5.cursor.sh.local agent-gcpp-uswest.api5.cursor.sh.local agentn-gcpp-uswest.api5.cursor.sh.local agent-gcpp-eucentral.api5.cursor.sh.local agentn-gcpp-eucentral.api5.cursor.sh.local agent-gcpp-apsoutheast.api5.cursor.sh.local agentn-gcpp-apsoutheast.api5.cursor.sh.local
```

**替换模式** (`--domain your.domain`)：将上述域名中的 `cursor.sh` 替换为你的域名。

### 4. 启动服务
```bash
/path/to/ccursor
```

关于开发IDE的扩展或插件的开发者，启动ccursor后加上 `--debug` 参数以查看详细日志。

## 配置说明
配置文件 `config.toml` 中的不明参数请注释或删除，**切勿留空**。

### 基础配置项
| 配置项 | 说明 | 类型 | 必需 | 示例值 | 支持版本 |
|--------|------|------|------|--------|----------|
| `check-updates` | 启动时检查更新 | bool | ❌ | false | 0.2.0+ |
| `github-token` | GitHub访问令牌 | string | ❌ | "" | 0.2.0+ |
| ~~`usage-statistics`~~ | ~~模型使用统计~~ | ~~bool~~ | ❌ | true | 0.2.1-0.2.x，已废弃，未来在数据库实现 |

### 服务配置(`service-config`)
| 配置项 | 说明 | 类型 | 必需 | 示例值 | 支持版本 |
|--------|------|------|------|--------|----------|
| `tls` | TLS证书配置 | object | ✅ | {cert_path="", key_path=""} | 0.3.0+ |
| `ip-addr` | 服务监听IP地址 | object | ✅ | {ipv4="", ipv6=""} | 0.3.1+ |
| `port` | 服务监听端口 | u16 | ✅ | - | 所有版本 |
| `dns-resolver` | DNS解析器(gai/hickory) | string | ❌ | "gai" | 0.2.0+ |
| `lock-updates` | 锁定更新 | bool | ✅ | false | 所有版本 |
| `passthrough-unmatched` | 透传未匹配请求 | bool | ✅ | false | 0.3.3+ |
| `fake-email` | 虚假电子邮件配置 | object | ❌ | {email="", sign-up-type="unknown", enable=false} | 0.2.0+ |
| `service-addr` | 服务地址配置 | object | ❌ | {scheme="http", suffix="", port=0} | 0.2.0+ |
| ~~`proxy`~~ | ~~代理配置~~ | ~~string~~ | ❌ | - | 0.2.0-0.2.x，已废弃，请迁移到`proxies._` |

### 代理池配置(`proxies`) - 0.3.0新增
| 配置项 | 说明 | 类型 | 必需 | 示例值 |
|--------|------|------|------|--------|
| `键名` | 配置标识符，与`overrides.键名`对应 | string | ❌ | - |
| `_` | 默认代理配置 | string | ❌ | "" |

### 映射配置(`override-mapping`) - 0.3.0新增
| 配置项 | 说明 | 类型 | 必需 | 示例值 |
|--------|------|------|------|--------|
| `Bearer Token前缀` | 映射到配置名称 | string | ❌ | - |
| `_` | 默认映射 | string | ❌ | - |

### 覆盖配置(`overrides.配置名`)
| 配置项 | 说明 | 类型 | 必需 | 示例值 | 支持版本 |
|--------|------|------|------|--------|----------|
| `token` | JWT认证令牌 | string | ❌ | - | 所有版本 |
| `traceparent` | 保留追踪标识 | bool | ❌ | false | 0.2.0+ |
| `client-key` | 客户端密钥哈希 | string | ❌ | - | 0.2.0+ |
| `checksum` | 组合哈希校验值 | object | ❌ | - | 0.2.0+ |
| `client-version` | 客户端版本号 | string | ❌ | - | 0.2.0+ |
| `config-version` | 配置版本(UUID) | string | ❌ | - | 0.3.0+ |
| `timezone` | IANA时区标识 | string | ❌ | - | 所有版本 |
| `privacy-mode` | 隐私模式设置 | bool | ❌ | true | 0.3.0+ |
| `session-id` | 会话唯一标识符(UUID) | string | ❌ | - | 0.2.0+ |

### 版本迁移说明
#### 0.2.x → 0.3.0
- **重大变更**：
  - 移除 `current-override`，改为动态Bearer Token映射
  - `service-config.proxy` 迁移到 `proxies._`
  - 新增 `proxies` 和 `override-mapping` 配置节
  - `ghost-mode` 重命名为 `privacy-mode`，并增强其功能
  - 新增 `config-version` 字段
  - 新增 `tls` 配置支持HTTPS

- **配置关系**：
  1. 客户端发送Bearer Token (如 `sk-test123`)
  2. 通过 `override-mapping` 查找配置名 (如 `sk-test` → `example`)
  3. 使用 `proxies.example` 的代理设置
  4. 使用 `overrides.example` 的覆盖配置

**特殊说明**：
- 空字符串 `""` 表示不使用代理
- `_` 键用作默认/回退配置
- 建议注释掉可选配置项，避免潜在问题
- 配置文件总会在关闭ccursor被更新，如果需要修改配置文件，请选择GET /internal/ConfigUpdate或关闭再更新

## 内部接口

**限制**：无法通过域名访问触发，需要外部访问自行反代

### ConfigUpdate
**功能**：配置文件更新后触发服务重载，部分配置需重启服务器

### CppCount
**功能**：StreamCpp请求成功与响应成功的简易计数

---

*免责声明包含在 EULA 中。项目可能随时终止维护。*

Feel free!