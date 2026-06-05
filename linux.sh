#!/bin/bash
# vim: set fileencoding=utf-8 :
export LANG=C.UTF-8
export LC_ALL=C.UTF-8

# 基本配置变量
APPIMAGE_PATH=""
APPIMAGETOOL_PATH=""
APPIMAGETOOL_DOWNLOADING=""
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
BACKUP_DIR="${BASE_DIR}/backups"
DEBUG=false
LANG_CODE=""
MODIFIER_EXTRA_PARAMS=""
MODIFIER_PATH=""
PORT=""
SKIP_HOSTS=false
SUDO="sudo "
SUFFIX=".local"
DOMAIN=""
WEBSITE_URL=""
WEBSITE_URL_SET=false
TEMP_DIR="/tmp/cursor-$(date +%s)"

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

# 检测系统架构
detect_arch() {
  local arch=$(uname -m)
  case "$arch" in
    x86_64)
      echo "x86_64"
      ;;
    aarch64|arm64)
      echo "aarch64"
      ;;
    *)
      echo "unknown"
      ;;
  esac
}

# 调试输出函数，仅在DEBUG模式下输出信息
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
  -a, --appimage <PATH>   指定 AppImage 路径
  -p, --port <PORT>       指定端口号 (可选，默认由 modifier 处理)
  -s, --suffix <SUFFIX>   指定域名后缀 (默认: .local)
  -d, --domain <DOMAIN>   替换域名（与 --suffix 互斥）
  --website-url [URL]     自定义登录 URL（可选值）
  --skip-hosts            跳过 hosts 文件修改
  --debug                 启用调试输出

注意事项:
  1. 脚本会自动备份原始 AppImage 文件
  2. 需要管理员权限修改 hosts 文件（除非使用 --skip-hosts）
  3. 支持 x86_64 和 aarch64 架构
  4. 再次运行脚本将检测现有修改并决定是否需要恢复

示例:
  # 基本修补（HTTPS模式）
  $0 -a /path/to/cursor.appimage

  # 指定端口和后缀
  $0 -a /path/to/cursor.appimage -p 443 -s .example.com

  # 使用域名替换
  $0 -a /path/to/cursor.appimage -d example.com

  # 跳过 hosts 修改（手动管理域名解析）
  $0 -a /path/to/cursor.appimage --skip-hosts
EOF
  else
    cat << EOF
Usage: $0 [options]

Options:
  -h, --help              Show this message
  -l, --lang CODE         Set language (zh/en)
  -a, --appimage <PATH>   Cursor AppImage path
  -p, --port <PORT>       Specify port number (optional, modifier will handle default)
  -s, --suffix <SUFFIX>   Specify domain suffix (default: .local)
  -d, --domain <DOMAIN>   Replacement domain (mutually exclusive with --suffix)
  --website-url [URL]     Custom login URL (optional value)
  --skip-hosts            Skip hosts file modification
  --debug                 Enable debug output

Notes:
  1. Original AppImage will be automatically backed up
  2. Administrator permission required for hosts modification (unless --skip-hosts)
  3. Supports x86_64 and aarch64 architectures
  4. Run script again to check existing modifications and restore if needed

Examples:
  # Basic patching (HTTPS mode)
  $0 -a /path/to/cursor.appimage

  # Specify port and suffix
  $0 -a /path/to/cursor.appimage -p 443 -s .example.com

  # Use domain replacement
  $0 -a /path/to/cursor.appimage -d example.com

  # Skip hosts modification (manual DNS management)
  $0 -a /path/to/cursor.appimage --skip-hosts
EOF
  fi
}

# 显示当前配置信息
show_info() {
  if [ "${LANG_CODE}" = "zh" ]; then
    echo "当前配置:"
    echo "  语言: ${LANG_CODE}"
    echo "  AppImage路径: ${APPIMAGE_PATH:-未设置}"
    echo "  协议: HTTPS (固定)"
    if [ -n "${PORT}" ]; then
      echo "  端口: ${PORT}"
    else
      echo "  端口: (使用默认)"
    fi
    if [ -n "${DOMAIN}" ]; then
      echo "  域名: ${DOMAIN}"
    else
      echo "  域名后缀: ${SUFFIX}"
    fi
    if [ "${WEBSITE_URL_SET}" = true ]; then
      if [ -n "${WEBSITE_URL}" ]; then
        echo "  登录URL: ${WEBSITE_URL}"
      else
        echo "  登录URL: (使用默认)"
      fi
    fi
    echo "  跳过hosts修改: $([ "${SKIP_HOSTS}" = "true" ] && echo "是" || echo "否")"
    echo "  临时目录: ${TEMP_DIR}"
    echo "  备份目录: ${BACKUP_DIR}"
    if $DEBUG; then
      echo "  调试模式: 启用"
    fi
  else
    echo "Current Configuration:"
    echo "  Language: ${LANG_CODE}"
    echo "  AppImage Path: ${APPIMAGE_PATH:-Not set}"
    echo "  Protocol: HTTPS (fixed)"
    if [ -n "${PORT}" ]; then
      echo "  Port: ${PORT}"
    else
      echo "  Port: (use default)"
    fi
    if [ -n "${DOMAIN}" ]; then
      echo "  Domain: ${DOMAIN}"
    else
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
    echo "  Temporary Directory: ${TEMP_DIR}"
    echo "  Backup Directory: ${BACKUP_DIR}"
    if $DEBUG; then
      echo "  Debug Mode: Enabled"
    fi
  fi
  echo ""
}

# 初始化语言文本，按逻辑分组排序
init_lang() {
  if [ "${LANG_CODE}" = "zh" ]; then
    # 基本错误消息
    MSG_ERROR_NOT_FOUND="错误：未找到 Cursor AppImage"
    MSG_ERROR_TEMP_DIR="无法创建临时目录"
    MSG_ERROR_MODIFIER_NOT_FOUND="错误：未找到 modifier 在"
    MSG_ERROR_MODIFIER_FAILED="错误：modifier 执行失败"
    MSG_INVALID_PORT="错误：端口必须是有效的数字"
    MSG_WGET_CURL_NOT_FOUND="错误：未安装 wget 或 curl。请先安装其中一个。"
    MSG_UNSUPPORTED_ARCH="错误：不支持的架构"

    # 备份与恢复相关消息
    MSG_BACKUP_CREATED="已创建 AppImage 备份到"
    MSG_BACKUP_EXISTS="发现备份文件..."
    MSG_NO_BACKUP="未发现备份文件，执行修补操作"
    MSG_CREATING_BACKUP_DIR="创建备份目录"

    # AppImage处理消息
    MSG_FOUND_APPIMAGE="找到 AppImage："
    MSG_CREATE_TEMP_DIR="创建临时目录"
    MSG_COPYING_APPIMAGE="正在复制 AppImage 到临时目录..."
    MSG_UNPACKING="正在解压 AppImage..."
    MSG_UNPACKED_TO="AppImage 已解压到"
    MSG_FAILED_UNPACK="解压 AppImage 失败"
    MSG_PATCHING_WITH_MODIFIER="正在使用 modifier 修补..."
    MSG_REPACKING="正在重新打包 AppImage..."
    MSG_REPACK_FAILED="重新打包 AppImage 失败"
    MSG_REPACK_SUCCESS="AppImage 已重新打包，覆盖"
    MSG_REMOVING_TEMP_DIR="已移除临时目录"
    MSG_PROCESS_COMPLETE="处理完成！"

    # appimagetool相关消息
    MSG_APPIMAGETOOL_NOT_FOUND="未找到 appimagetool"
    MSG_DOWNLOAD_PROMPT="下载 appimagetool？(Y/n)："
    MSG_DOWNLOADING="正在下载 appimagetool..."
    MSG_DOWNLOAD_FAILED="下载失败。您可以手动下载并保存到"
    MSG_DOWNLOAD_LINK="链接："
    MSG_APPIMAGETOOL_DOWNLOADED="appimagetool 已下载"
    MSG_MANUAL_DOWNLOAD="请下载 appimagetool 并将其放置到"
    MSG_TO_CONTINUE="以继续"
  else
    # Basic error messages
    MSG_ERROR_NOT_FOUND="Error: Cursor AppImage not found"
    MSG_ERROR_TEMP_DIR="Cannot create temporary directory"
    MSG_ERROR_MODIFIER_NOT_FOUND="Error: modifier not found at"
    MSG_ERROR_MODIFIER_FAILED="Error: modifier execution failed"
    MSG_INVALID_PORT="Error: Port must be a valid number"
    MSG_WGET_CURL_NOT_FOUND="Error: Neither wget nor curl is installed. Please install one of them first."
    MSG_UNSUPPORTED_ARCH="Error: Unsupported architecture"

    # Backup and restore messages
    MSG_BACKUP_CREATED="AppImage backup created at"
    MSG_BACKUP_EXISTS="Backup file found..."
    MSG_NO_BACKUP="No backup file found, performing patch operation"
    MSG_CREATING_BACKUP_DIR="Creating backup directory"

    # AppImage processing messages
    MSG_FOUND_APPIMAGE="Found AppImage:"
    MSG_CREATE_TEMP_DIR="Creating temporary directory"
    MSG_COPYING_APPIMAGE="Copying AppImage to temporary directory..."
    MSG_UNPACKING="Unpacking AppImage..."
    MSG_UNPACKED_TO="AppImage unpacked to"
    MSG_FAILED_UNPACK="Failed to unpack AppImage"
    MSG_PATCHING_WITH_MODIFIER="Patching with modifier..."
    MSG_REPACKING="Repacking AppImage..."
    MSG_REPACK_FAILED="Failed to repack AppImage"
    MSG_REPACK_SUCCESS="AppImage repacked, overwriting"
    MSG_REMOVING_TEMP_DIR="Removed temporary directory"
    MSG_PROCESS_COMPLETE="Process complete!"

    # appimagetool related messages
    MSG_APPIMAGETOOL_NOT_FOUND="appimagetool not found"
    MSG_DOWNLOAD_PROMPT="Download appimagetool? (Y/n):"
    MSG_DOWNLOADING="Downloading appimagetool..."
    MSG_DOWNLOAD_FAILED="Download failed. You can manually download and save it to"
    MSG_DOWNLOAD_LINK="Link:"
    MSG_APPIMAGETOOL_DOWNLOADED="appimagetool downloaded"
    MSG_MANUAL_DOWNLOAD="Please download appimagetool and place it at"
    MSG_TO_CONTINUE="to continue"
  fi
}

# 解析命令行参数
parse_params() {
  options=$(getopt -o hl:a:p:s:d: --long help,lang:,appimage:,port:,suffix:,domain:,website-url::,skip-hosts,debug -n "$(basename "$0")" -- "$@")
  if [ $? -ne 0 ]; then
    echo "Invalid options" >&2
    exit 1
  fi

  eval set -- "$options"

  while true; do
    case "$1" in
      -h|--help)
        LANG_CODE=${LANG_CODE:-$(detect_system_lang)}
        init_lang
        show_help
        exit 0
        ;;
      -l|--lang)
        LANG_CODE="$2"
        shift 2
        ;;
      -a|--appimage)
        APPIMAGE_PATH="$2"
        shift 2
        ;;
      -p|--port)
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
        SUFFIX="$2"
        shift 2
        ;;
      -d|--domain)
        DOMAIN="$2"
        shift 2
        ;;
      --website-url)
        WEBSITE_URL_SET=true
        if [ -n "$2" ]; then
          WEBSITE_URL="$2"
        fi
        shift 2
        ;;
      --skip-hosts)
        SKIP_HOSTS=true
        shift
        ;;
      --debug)
        DEBUG=true
        shift
        ;;
      --)
        shift
        break
        ;;
      *)
        show_help
        exit 1
        ;;
    esac
  done

  # 初始化语言
  LANG_CODE=${LANG_CODE:-$(detect_system_lang)}
  init_lang

  # 检查 --domain 和自定义 --suffix 互斥
  if [ -n "${DOMAIN}" ] && [ "${SUFFIX}" != ".local" ]; then
    if [ "${LANG_CODE}" = "zh" ]; then
      echo "错误：--domain 和 --suffix 不能同时使用"
    else
      echo "Error: --domain and --suffix are mutually exclusive"
    fi
    exit 1
  fi

  # 检查 AppImage 路径
  if [ -z "${APPIMAGE_PATH}" ]; then
    echo "${MSG_ERROR_NOT_FOUND}"
    exit 1
  fi

  if [ ! -f "${APPIMAGE_PATH}" ]; then
    echo "${MSG_ERROR_NOT_FOUND}: ${APPIMAGE_PATH}"
    exit 1
  fi

  APPIMAGETOOL_PATH="${BASE_DIR}/appimagetool"
  APPIMAGETOOL_DOWNLOADING="${BASE_DIR}/appimagetool_downloading"

  show_info
}

# 下载文件的通用函数，支持wget和curl
download_file() {
  local url="$1"
  local target="$2"

  debug_print "Downloading: $url to $target"

  if command -v wget &> /dev/null; then
    wget "$url" -O "$target"
    return $?
  elif command -v curl &> /dev/null; then
    curl -L "$url" -o "$target"
    return $?
  else
    echo "${MSG_WGET_CURL_NOT_FOUND}"
    return 1
  fi
}

# 准备运行环境，创建临时目录并检查所需工具
prepare() {
  echo "${MSG_CREATE_TEMP_DIR}: ${TEMP_DIR}"
  mkdir -p "${TEMP_DIR}"
  if [ $? -ne 0 ]; then
    echo "${MSG_ERROR_TEMP_DIR}: ${TEMP_DIR}"
    exit 1
  fi

  echo "${MSG_CREATING_BACKUP_DIR}: ${BACKUP_DIR}"
  mkdir -p "${BACKUP_DIR}"

  MODIFIER_PATH="${BASE_DIR}/modifier"
  if [ ! -f "${MODIFIER_PATH}" ]; then
    echo "${MSG_ERROR_MODIFIER_NOT_FOUND} ${MODIFIER_PATH}"
    exit 1
  fi

  if [ -f "${APPIMAGETOOL_DOWNLOADING}" ]; then
    rm -f "${APPIMAGETOOL_DOWNLOADING}"
  fi

  if [ ! -f "${APPIMAGETOOL_PATH}" ]; then
    if command -v appimagetool &> /dev/null; then
      APPIMAGETOOL_PATH="appimagetool"
      debug_print "Using system appimagetool"
    else
      echo "${MSG_APPIMAGETOOL_NOT_FOUND}"

      # 检测架构
      local arch=$(detect_arch)
      if [ "$arch" = "unknown" ]; then
        echo "${MSG_UNSUPPORTED_ARCH}: $(uname -m)"
        exit 1
      fi

      read -p "${MSG_DOWNLOAD_PROMPT}" -r DOWNLOAD
      DOWNLOAD=${DOWNLOAD,,}

      if [[ ! "${DOWNLOAD}" =~ ^(n|no)$ ]]; then
        echo "${MSG_DOWNLOADING}"
        local appimagetool_url="https://github.com/AppImage/appimagetool/releases/download/continuous/appimagetool-${arch}.AppImage"
        download_file "${appimagetool_url}" "${APPIMAGETOOL_DOWNLOADING}"

        if [ $? -ne 0 ]; then
          echo "${MSG_DOWNLOAD_FAILED} ${APPIMAGETOOL_PATH}"
          echo "${MSG_DOWNLOAD_LINK} ${appimagetool_url}"
          rm -f "${APPIMAGETOOL_DOWNLOADING}"
          exit 1
        fi

        chmod +x "${APPIMAGETOOL_DOWNLOADING}"
        mv "${APPIMAGETOOL_DOWNLOADING}" "${APPIMAGETOOL_PATH}"
        echo "${MSG_APPIMAGETOOL_DOWNLOADED}"
      else
        echo "${MSG_MANUAL_DOWNLOAD} ${APPIMAGETOOL_PATH} ${MSG_TO_CONTINUE}"
        local appimagetool_url="https://github.com/AppImage/appimagetool/releases/download/continuous/appimagetool-${arch}.AppImage"
        echo "${MSG_DOWNLOAD_LINK} ${appimagetool_url}"
        exit 1
      fi
    fi
  fi

  debug_print "Environment prepared"
}

# 构建 modifier 命令
build_modifier_cmd() {
  local cursor_path="$1"
  local extra_flags="$2"

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

# 处理AppImage文件，自动检测是恢复还是修补
process_appimage() {
  echo "${MSG_FOUND_APPIMAGE} ${APPIMAGE_PATH}"
  local appimage_name=$(basename "${APPIMAGE_PATH}")
  local backup_file="${BACKUP_DIR}/${appimage_name}.bk"

  # 检测是否存在备份文件以决定操作
  if [ -f "${backup_file}" ]; then
    echo "${MSG_BACKUP_EXISTS}"

    # 复制到临时目录
    echo "${MSG_COPYING_APPIMAGE}"
    cp -f "${APPIMAGE_PATH}" "${TEMP_DIR}/"
    local temp_appimage="${TEMP_DIR}/$(basename "${APPIMAGE_PATH}")"
    debug_print "AppImage copied to: ${temp_appimage}"

    # 解压AppImage
    echo "${MSG_UNPACKING}"
    cd "${TEMP_DIR}" || exit 1
    chmod +x "${temp_appimage}"
    "${temp_appimage}" --appimage-extract > /dev/null 2>&1

    if [ $? -ne 0 ]; then
      echo "${MSG_FAILED_UNPACK}"
      cd "${BASE_DIR}" || exit 1
      rm -rf "${TEMP_DIR}"
      exit 1
    fi

    echo "${MSG_UNPACKED_TO} ${TEMP_DIR}/squashfs-root"

    local modifier_cmd=$(build_modifier_cmd "${TEMP_DIR}/squashfs-root/usr/share/cursor/resources/app" "-f --pass-token")

    if [ "${SKIP_HOSTS}" = "true" ]; then
      SUDO=""
    else
      SUDO="sudo "
    fi

    debug_print "Executing with confirm: ${SUDO}${modifier_cmd}"

    # 执行 modifier
    ${SUDO}${modifier_cmd}
    if [ $? -ne 0 ]; then
      echo "${MSG_ERROR_MODIFIER_FAILED}"
      cd "${BASE_DIR}" || exit 1
      rm -rf "${TEMP_DIR}"
      exit 1
    fi

    # 重新打包AppImage
    echo "${MSG_REPACKING}"
    "${APPIMAGETOOL_PATH}" squashfs-root "${temp_appimage}"

    if [ $? -ne 0 ]; then
      echo "${MSG_REPACK_FAILED}"
      cd "${BASE_DIR}" || exit 1
      rm -rf "${TEMP_DIR}"
      exit 1
    fi

    # 替换原始文件
    ${SUDO}cp -f "${temp_appimage}" "${APPIMAGE_PATH}"
    echo "${MSG_REPACK_SUCCESS} ${APPIMAGE_PATH}"

    # 清理临时文件
    cd "${BASE_DIR}" || exit 1
    rm -rf "${TEMP_DIR}"
    echo "${MSG_REMOVING_TEMP_DIR}: ${TEMP_DIR}"

  else
    echo "${MSG_NO_BACKUP}"

    # 创建备份
    mkdir -p "${BACKUP_DIR}"
    cp -f "${APPIMAGE_PATH}" "${backup_file}"
    echo "${MSG_BACKUP_CREATED} ${backup_file}"

    # 复制到临时目录准备修改
    echo "${MSG_COPYING_APPIMAGE}"
    cp -f "${APPIMAGE_PATH}" "${TEMP_DIR}/"
    local temp_appimage="${TEMP_DIR}/$(basename "${APPIMAGE_PATH}")"
    debug_print "AppImage copied to: ${temp_appimage}"

    # 解压AppImage
    echo "${MSG_UNPACKING}"
    cd "${TEMP_DIR}" || exit 1
    chmod +x "${temp_appimage}"
    "${temp_appimage}" --appimage-extract > /dev/null 2>&1

    if [ $? -ne 0 ]; then
      echo "${MSG_FAILED_UNPACK}"
      exit 1
    fi

    echo "${MSG_UNPACKED_TO} ${TEMP_DIR}/squashfs-root"

    # 使用modifier修补
    echo "${MSG_PATCHING_WITH_MODIFIER}"

    local modifier_cmd=$(build_modifier_cmd "${TEMP_DIR}/squashfs-root/usr/share/cursor/resources/app" "")

    if [ "${SKIP_HOSTS}" = "true" ]; then
      SUDO=""
    else
      SUDO="sudo "
    fi

    debug_print "Executing: ${SUDO}${modifier_cmd}"
    ${SUDO}${modifier_cmd}

    if [ $? -ne 0 ]; then
      echo "${MSG_ERROR_MODIFIER_FAILED}"
      exit 1
    fi

    # 重新打包AppImage
    echo "${MSG_REPACKING}"
    "${APPIMAGETOOL_PATH}" squashfs-root "${temp_appimage}"

    if [ $? -ne 0 ]; then
      echo "${MSG_REPACK_FAILED}"
      exit 1
    fi

    # 替换原始文件
    ${SUDO}cp -f "${temp_appimage}" "${APPIMAGE_PATH}"
    echo "${MSG_REPACK_SUCCESS} ${APPIMAGE_PATH}"

    # 清理临时文件
    cd "${BASE_DIR}" || exit 1
    rm -rf "${TEMP_DIR}"
    echo "${MSG_REMOVING_TEMP_DIR}: ${TEMP_DIR}"
  fi

  echo "${MSG_PROCESS_COMPLETE}"
  exit 0
}

# 主函数，脚本执行入口
main() {
  parse_params "$@"
  prepare
  process_appimage
}

main "$@"
