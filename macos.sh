#!/bin/bash
# vim: set fileencoding=utf-8 :
export LANG=C.UTF-8
export LC_ALL=C.UTF-8

# 基本配置变量
BASE_PATH="/Applications/Cursor.app"
DEBUG=false
LANG_CODE=""
PORT=""
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
SKIP_HOSTS=false
SUFFIX=".local"
DOMAIN=""
WEBSITE_URL=""
WEBSITE_URL_SET=false
TMP_PATH="${BASE_PATH}.tmp"
BACKUP_PATH="${BASE_PATH}.bk.tar.gz"

# 检测系统语言，优先判断中文
detect_system_lang() {
  local lang_var=${LANGUAGE:-${LC_ALL:-${LC_MESSAGES:-$LANG}}}
  local lang_code=$(echo "${lang_var}" | cut -d'_' -f1 | cut -d'.' -f1 | tr '[:upper:]' '[:lower:]')

  if [[ "${lang_code}" == zh* ]]; then
    echo "zh"
  else
    echo "en"
  fi
}

# 调试输出函数
debug_print() {
  if $DEBUG; then
    echo "[DEBUG] $1"
  fi
}

# 显示帮助信息
show_help() {
  if [ "${LANG_CODE}" = "zh" ]; then
    cat << EOF
用法: $0 [选项]

选项:
  -h, --help              显示帮助信息
  -l, --lang CODE         设置语言 (zh/en)
  -p, --port <PORT>       指定端口号 (可选，默认由 modifier 处理)
  -s, --suffix <SUFFIX>   指定域名后缀 (默认: .local)
  -d, --domain <DOMAIN>   替换域名（与 --suffix 互斥）
  --website-url [URL]     自定义登录 URL（可选值）
  --skip-hosts            跳过 hosts 文件修改
  --debug                 启用调试输出

注意事项:
  1. 脚本会自动备份原始应用为压缩包 (.bk.tar.gz)
  2. 需要管理员权限进行应用签名
  3. 如使用自签名证书，请使用生成的 launch-cursor.sh 启动脚本
  4. 再次运行脚本将从备份恢复原始应用

示例:
  # 基本修补（HTTPS模式）
  $0

  # 指定端口和后缀
  $0 -p 443 -s .example.com

  # 使用完整域名替换
  $0 -d api.example.com

  # 跳过 hosts 修改（手动管理域名解析）
  $0 --skip-hosts
EOF
  else
    cat << EOF
Usage: $0 [options]

Options:
  -h, --help              Show this message
  -l, --lang CODE         Set language (zh/en)
  -p, --port <PORT>       Specify port number (optional, modifier will handle default)
  -s, --suffix <SUFFIX>   Specify domain suffix (default: .local)
  -d, --domain <DOMAIN>   Replacement domain (mutually exclusive with --suffix)
  --website-url [URL]     Custom login URL (optional value)
  --skip-hosts            Skip hosts file modification
  --debug                 Enable debug output

Notes:
  1. Original app will be backed up as compressed archive (.bk.tar.gz)
  2. Administrator permission required for app signing
  3. Use generated launch-cursor.sh script for self-signed certificates
  4. Run script again to restore original app

Examples:
  # Basic patching (HTTPS mode)
  $0

  # Specify port and suffix
  $0 -p 443 -s .example.com

  # Use full domain replacement
  $0 -d api.example.com

  # Skip hosts modification (manual DNS management)
  $0 --skip-hosts
EOF
  fi
}

# 显示当前配置信息
show_info() {
  if [ "${LANG_CODE}" = "zh" ]; then
    echo "当前配置:"
    echo "  语言: ${LANG_CODE}"
    echo "  应用路径: ${BASE_PATH}"
    echo "  协议: HTTPS (固定)"
    if [ -n "${PORT}" ]; then
      echo "  端口: ${PORT}"
    else
      echo "  端口: (使用默认)"
    fi
    if [ -n "${DOMAIN}" ]; then
      echo "  域名模式: 完整域名"
      echo "  域名: ${DOMAIN}"
    else
      echo "  域名模式: 后缀"
      echo "  域名后缀: ${SUFFIX}"
    fi
    if [ "${WEBSITE_URL_SET}" = true ]; then
      if [ -n "${WEBSITE_URL}" ]; then
        echo "  登录 URL: ${WEBSITE_URL}"
      else
        echo "  登录 URL: (使用默认)"
      fi
    fi
    echo "  跳过hosts修改: $([ "${SKIP_HOSTS}" = "true" ] && echo "是" || echo "否")"
    echo "  临时路径: ${TMP_PATH}"
    echo "  备份路径: ${BACKUP_PATH}"
    if $DEBUG; then
      echo "  调试模式: 启用"
    fi
  else
    echo "Current Configuration:"
    echo "  Language: ${LANG_CODE}"
    echo "  App Path: ${BASE_PATH}"
    echo "  Protocol: HTTPS (fixed)"
    if [ -n "${PORT}" ]; then
      echo "  Port: ${PORT}"
    else
      echo "  Port: (use default)"
    fi
    if [ -n "${DOMAIN}" ]; then
      echo "  Domain Mode: full domain"
      echo "  Domain: ${DOMAIN}"
    else
      echo "  Domain Mode: suffix"
      echo "  Domain Suffix: ${SUFFIX}"
    fi
    if [ "${WEBSITE_URL_SET}" = true ]; then
      if [ -n "${WEBSITE_URL}" ]; then
        echo "  Website URL: ${WEBSITE_URL}"
      else
        echo "  Website URL: (use default)"
      fi
    fi
    echo "  Skip Hosts Modification: $([ "${SKIP_HOSTS}" = "true" ] && echo "Yes" || echo "No")"
    echo "  Temporary Path: ${TMP_PATH}"
    echo "  Backup Path: ${BACKUP_PATH}"
    if $DEBUG; then
      echo "  Debug Mode: Enabled"
    fi
  fi
  echo ""
}

# 初始化语言文本
init_lang() {
  if [ "${LANG_CODE}" = "zh" ]; then
    # 基本错误消息
    MSG_ERROR_NOT_FOUND="错误：未找到 Cursor.app 在"
    MSG_ERROR_MODIFIER_NOT_FOUND="错误：未找到 modifier 在"
    MSG_ERROR_MODIFIER_FAILED="错误：modifier 执行失败"
    MSG_INVALID_PORT="错误：端口必须是有效的数字"

    # 备份与恢复相关消息
    MSG_BACKUP_EXISTS="发现备份文件..."
    MSG_CREATING_BACKUP="正在创建应用备份..."
    MSG_BACKUP_CREATED="已创建应用备份到"
    MSG_NO_BACKUP="未发现备份文件，执行修补操作"
    MSG_RESTORING="正在恢复 Cursor.app..."
    MSG_REMOVING_ORIGINAL="正在移除原始应用..."
    MSG_EXTRACTING_BACKUP="正在从备份恢复应用..."
    MSG_REMOVING_BACKUP="正在删除备份文件..."
    MSG_RESTORING_COMPLETE="恢复完成！"
    MSG_EXISTING_MODIFICATION="检测到已有HTTPS修改，执行恢复逻辑..."

    # 修补相关消息
    MSG_PATCHING="正在修补 Cursor.app..."
    MSG_REMOVING_EXISTING="正在移除已存在的"
    MSG_COPYING_TO="正在复制到"
    MSG_REMOVING_SIGNATURE="正在移除签名..."
    MSG_PATCHING_WITH_MODIFIER="正在使用 modifier 修补..."
    MSG_SIGNING="正在签名应用..."
    MSG_NEED_SUDO="需要管理员权限来签名应用..."
    MSG_REPLACING_ORIGINAL="正在替换原始应用..."
    MSG_PATCHING_COMPLETE="修补完成！"
    MSG_PROCESS_COMPLETE="处理完成！"

    # 启动脚本相关
    MSG_GENERATING_LAUNCHER="正在生成启动脚本..."
    MSG_LAUNCHER_CREATED="已生成启动脚本："
    MSG_LAUNCHER_HINT="如果使用自签名证书，请使用此脚本启动 Cursor"
  else
    # Basic error messages
    MSG_ERROR_NOT_FOUND="Error: Cursor.app not found at"
    MSG_ERROR_MODIFIER_NOT_FOUND="Error: modifier not found at"
    MSG_ERROR_MODIFIER_FAILED="Error: modifier execution failed"
    MSG_INVALID_PORT="Error: Port must be a valid number"

    # Backup and restore messages
    MSG_BACKUP_EXISTS="Backup file found..."
    MSG_CREATING_BACKUP="Creating app backup..."
    MSG_BACKUP_CREATED="App backup created at"
    MSG_NO_BACKUP="No backup file found, performing patch operation"
    MSG_RESTORING="Restoring Cursor.app..."
    MSG_REMOVING_ORIGINAL="Removing original app..."
    MSG_EXTRACTING_BACKUP="Extracting app from backup..."
    MSG_REMOVING_BACKUP="Removing backup file..."
    MSG_RESTORING_COMPLETE="Restore complete!"
    MSG_EXISTING_MODIFICATION="Detected existing HTTPS modification, performing restore..."

    # Patching messages
    MSG_PATCHING="Patching Cursor.app..."
    MSG_REMOVING_EXISTING="Removing existing"
    MSG_COPYING_TO="Copying to"
    MSG_REMOVING_SIGNATURE="Removing signature..."
    MSG_PATCHING_WITH_MODIFIER="Patching with modifier..."
    MSG_SIGNING="Signing application..."
    MSG_NEED_SUDO="Administrator permission required for signing..."
    MSG_REPLACING_ORIGINAL="Replacing original app..."
    MSG_PATCHING_COMPLETE="Patching complete!"
    MSG_PROCESS_COMPLETE="Process complete!"

    # Launcher script messages
    MSG_GENERATING_LAUNCHER="Generating launcher script..."
    MSG_LAUNCHER_CREATED="Generated launcher script:"
    MSG_LAUNCHER_HINT="Use this script to launch Cursor with self-signed certificates"
  fi
}

# 解析命令行参数 (macOS 原生方式)
parse_params() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -h|--help)
        LANG_CODE=${LANG_CODE:-$(detect_system_lang)}
        init_lang
        show_help
        exit 0
        ;;
      -l|--lang)
        if [ -z "$2" ] || [[ "$2" == -* ]]; then
          echo "Error: --lang requires a value"
          exit 1
        fi
        LANG_CODE="$2"
        shift 2
        ;;
      -p|--port)
        if [ -z "$2" ] || [[ "$2" == -* ]]; then
          echo "Error: --port requires a value"
          exit 1
        fi
        PORT="$2"
        if ! [[ "${PORT}" =~ ^[0-9]+$ ]]; then
          LANG_CODE=${LANG_CODE:-$(detect_system_lang)}
          init_lang
          echo "${MSG_INVALID_PORT}: ${PORT}"
          exit 1
        fi
        shift 2
        ;;
      -s|--suffix)
        if [ -z "$2" ] || [[ "$2" == -* ]]; then
          echo "Error: --suffix requires a value"
          exit 1
        fi
        SUFFIX="$2"
        shift 2
        ;;
      -d|--domain)
        if [ -z "$2" ] || [[ "$2" == -* ]]; then
          echo "Error: --domain requires a value"
          exit 1
        fi
        DOMAIN="$2"
        shift 2
        ;;
      --website-url)
        WEBSITE_URL_SET=true
        if [ -n "$2" ] && [[ "$2" != -* ]]; then
          WEBSITE_URL="$2"
          shift 2
        else
          shift
        fi
        ;;
      --skip-hosts)
        SKIP_HOSTS=true
        shift
        ;;
      --debug)
        DEBUG=true
        shift
        ;;
      *)
        echo "Unknown option: $1"
        echo "Use -h or --help for usage information"
        exit 1
        ;;
    esac
  done

  # 验证 --domain 与 --suffix 互斥
  if [ -n "${DOMAIN}" ] && [ "${SUFFIX}" != ".local" ]; then
    echo "Error: --domain and --suffix are mutually exclusive"
    exit 1
  fi
  if [ -n "${DOMAIN}" ]; then
    SUFFIX=""
  fi

  # 初始化语言
  LANG_CODE=${LANG_CODE:-$(detect_system_lang)}
  init_lang

  # 检查 Cursor.app 是否存在
  if [ ! -d "${BASE_PATH}" ]; then
    echo "${MSG_ERROR_NOT_FOUND} ${BASE_PATH}"
    exit 1
  fi

  # 定义 modifier 路径
  MODIFIER_PATH="${SCRIPT_DIR}/modifier"

  # 检查 modifier 是否存在
  if [ ! -f "${MODIFIER_PATH}" ]; then
    echo "${MSG_ERROR_MODIFIER_NOT_FOUND} ${MODIFIER_PATH}"
    exit 1
  fi

  show_info
}

# 生成 Cursor 启动脚本
generate_launcher_script() {
  local launcher_path="${SCRIPT_DIR}/launch-cursor.sh"

  echo "${MSG_GENERATING_LAUNCHER}"

  cat > "${launcher_path}" << 'EOF'
#!/bin/bash
# Cursor Launcher with CA Certificate Support for macOS
# This script sets up the environment for Cursor with self-signed certificates

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
CA_CERT="${SCRIPT_DIR}/ca.crt"

# Check if CA certificate exists
if [ -f "${CA_CERT}" ]; then
    export NODE_EXTRA_CA_CERTS="${CA_CERT}"
    echo "Using CA certificate: ${CA_CERT}"
else
    echo "No CA certificate found, launching without custom CA"
fi

# Launch Cursor on macOS
echo "Launching Cursor..."
open -a "Cursor"
EOF

  chmod +x "${launcher_path}"

  echo "${MSG_LAUNCHER_CREATED} ${launcher_path}"
  echo "${MSG_LAUNCHER_HINT}"
  echo ""
}

# 构建 modifier 命令
build_modifier_cmd() {
  local cursor_path="$1"
  local extra_flags="$2"  # e.g. "-f --pass-token"

  local cmd="${MODIFIER_PATH} -C ${cursor_path}"
  if [ "${DEBUG}" = true ]; then
    cmd="${cmd} --debug"
  fi
  cmd="${cmd} apply"

  if [ -n "${DOMAIN}" ]; then
    cmd="${cmd} --domain ${DOMAIN}"
  else
    cmd="${cmd} --suffix ${SUFFIX}"
  fi

  if [ -n "${PORT}" ]; then
    cmd="${cmd} -p ${PORT}"
  fi
  if [ "${SKIP_HOSTS}" = "true" ]; then
    cmd="${cmd} --skip-hosts"
  fi
  if [ "${WEBSITE_URL_SET}" = true ]; then
    if [ -n "${WEBSITE_URL}" ]; then
      cmd="${cmd} --website-url ${WEBSITE_URL}"
    else
      cmd="${cmd} --website-url"
    fi
  fi

  if [ -n "${extra_flags}" ]; then
    cmd="${cmd} ${extra_flags}"
  fi

  echo "${cmd}"
}

# 修补应用
patch_app() {
  echo "${MSG_PATCHING}"

  # 创建压缩备份（如果不存在）
  if [ ! -f "${BACKUP_PATH}" ]; then
    echo "${MSG_CREATING_BACKUP}"
    debug_print "Creating backup: tar -czf ${BACKUP_PATH} -C /Applications Cursor.app"
    tar -czf "${BACKUP_PATH}" -C /Applications Cursor.app
    echo "${MSG_BACKUP_CREATED} ${BACKUP_PATH}"
  fi

  # 如果存在临时目录就移除
  if [ -d "${TMP_PATH}" ]; then
    echo "${MSG_REMOVING_EXISTING} ${TMP_PATH}..."
    rm -rf "${TMP_PATH}"
  fi

  # 复制到临时目录
  echo "${MSG_COPYING_TO} ${TMP_PATH}..."
  cp -a "${BASE_PATH}" "${TMP_PATH}"

  # 移除签名
  echo "${MSG_REMOVING_SIGNATURE}"
  codesign --remove-signature "${TMP_PATH}"

  # 构建 modifier 命令
  local modifier_cmd=$(build_modifier_cmd "${TMP_PATH}/Contents/Resources/app" "")

  # 使用 modifier 修补
  echo "${MSG_PATCHING_WITH_MODIFIER}"
  debug_print "Executing: ${modifier_cmd}"
  ${modifier_cmd}

  if [ $? -ne 0 ]; then
    echo "${MSG_ERROR_MODIFIER_FAILED}"
    # 清理临时文件
    rm -rf "${TMP_PATH}"
    exit 1
  fi

  # 签名应用（需要 sudo）
  echo "${MSG_SIGNING}"
  echo "${MSG_NEED_SUDO}"
  sudo codesign --force --deep --sign - "${TMP_PATH}"

  # 替换原始应用
  echo "${MSG_REPLACING_ORIGINAL}"
  rm -rf "${BASE_PATH}"
  mv "${TMP_PATH}" "${BASE_PATH}"

  # 生成启动脚本
  generate_launcher_script

  echo "${MSG_PATCHING_COMPLETE}"
  echo "${MSG_PROCESS_COMPLETE}"
}

# 恢复应用
restore_app() {
  echo "${MSG_RESTORING}"

  # 删除当前应用
  if [ -d "${BASE_PATH}" ]; then
    echo "${MSG_REMOVING_ORIGINAL}"
    rm -rf "${BASE_PATH}"
  fi

  # 从压缩包恢复
  echo "${MSG_EXTRACTING_BACKUP}"
  tar -xzf "${BACKUP_PATH}" -C /Applications

  # 删除备份文件
  echo "${MSG_REMOVING_BACKUP}"
  rm -f "${BACKUP_PATH}"

  echo "${MSG_RESTORING_COMPLETE}"
  echo "${MSG_PROCESS_COMPLETE}"
}

process_app() {
  if [ -f "${BACKUP_PATH}" ]; then
    echo "${MSG_BACKUP_EXISTS}"

    local modifier_cmd=$(build_modifier_cmd "${BASE_PATH}/Contents/Resources/app" "-f --pass-token")

    debug_print "Executing with confirm: ${modifier_cmd}"

    # 执行 modifier，失败则退出
    ${modifier_cmd}
    if [ $? -ne 0 ]; then
      echo "${MSG_ERROR_MODIFIER_FAILED}"
      exit 1
    fi

    echo "${MSG_PROCESS_COMPLETE}"
  else
    echo "${MSG_NO_BACKUP}"
    patch_app
  fi
}

# 主函数
main() {
  parse_params "$@"
  process_app
}

# 执行主函数
main "$@"
