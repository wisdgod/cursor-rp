#!/bin/bash
# vim: set fileencoding=utf-8 :
# 使用 UTF-8 编码处理文本
export LANG=C.UTF-8
export LC_ALL=C.UTF-8

# 基本配置
APPIMAGE_PATH=""
APPIMAGETOOL_PATH=""
APPIMAGETOOL_DOWNLOADING=""
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
DEBUG=false
LANG_CODE=""
MODIFIER_EXTRA_PARAMS=""
MODIFIER_PATH=""
PORT="3000"
SKIP_HOSTS=false
SUDO="sudo "
SUFFIX=".local"
TEMP_DIR="/tmp/cursor-patcher-$(date +%s)"
TOOL_NAME="$(basename "$0")"

# 检测系统语言
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

# 帮助信息
show_help() {
  if [ "${LANG_CODE}" = "zh" ]; then
    echo "用法: $0 [选项]"
    echo "选项:"
    echo "  -h, --help          显示帮助信息"
    echo "  -l, --lang CODE       设置语言 (zh/en)"
    echo "  -a, --appimage <PATH>     指定 AppImage 路径"
    echo "  -p, --port <PORT>       指定端口号 (默认: 3000)"
    echo "  -s, --suffix <SUFFIX>     指定后缀 (默认: .local)"
    echo "  --patch           执行修补操作"
    echo "  --restore           执行恢复操作"
    echo "  --skip-hosts        跳过 modifier 的 hosts 文件操作"
    echo "  --debug           启用调试输出"
    echo ""
    echo "注意: --patch 和 --restore 必须指定一个"
  else
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  -h, --help          Show this message"
    echo "  -l, --lang CODE       Set language (zh/en)"
    echo "  -a, --appimage <PATH>     Cursor AppImage path"
    echo "  -p, --port <PORT>       Specify port number (default: 3000)"
    echo "  -s, --suffix <SUFFIX>     Specify suffix (default: .local)"
    echo "  --patch           Apply patch"
    echo "  --restore           Restore original"
    echo "  --skip-hosts        Skip modify hosts file pass to modifier"
    echo "  --debug           Enable debug output"
    echo ""
    echo "Note: Either --patch or --restore must be specified"
  fi
}

# 显示当前配置
show_info() {
  if [ "${LANG_CODE}" = "zh" ]; then
    echo "当前配置:"
    echo "  语言(Lang): ${LANG_CODE}"
    echo "  AppImage路径: ${APPIMAGE_PATH:-未设置}"
    echo "  端口: ${PORT}"
    echo "  后缀: ${SUFFIX}"
    echo "  跳过hosts修改: $([ "${SKIP_HOSTS}" = "true" ] && echo "是" || echo "否")"
    echo "  临时目录: ${TEMP_DIR}"
    if $DEBUG; then
      echo "  调试模式: 启用"
    fi
  else
    echo "Current Configuration:"
    echo "  Language: ${LANG_CODE}"
    echo "  AppImage Path: ${APPIMAGE_PATH:-Not set}"
    echo "  Port: ${PORT}"
    echo "  Suffix: ${SUFFIX}"
    echo "  Skip Hosts Modification: $([ "${SKIP_HOSTS}" = "true" ] && echo "Yes" || echo "No")"
    echo "  Temporary Directory: ${TEMP_DIR}"
    if $DEBUG; then
      echo "  Debug Mode: Enabled"
    fi
  fi
  echo ""
}

# 初始化语言文本
init_lang() {
  if [ "${LANG_CODE}" = "zh" ]; then
    MSG_ERROR_NOT_FOUND="错误：未找到 Cursor AppImage"
    MSG_ERROR_INVALID_MODE="错误：必须指定 --patch 或 --restore"
    MSG_ERROR_MODE_CONFLICT="错误：--patch 和 --restore 不能同时使用"
    MSG_PATCHING="正在修补 Cursor AppImage..."
    MSG_RESTORING="正在恢复 Cursor AppImage..."
    MSG_UNPACKING="正在解压 AppImage..."
    MSG_UNPACKED_TO="AppImage 已解压 ->"
    MSG_PATCHING_WITH_MODIFIER="正在使用 modifier 修补..."
    MSG_ERROR_MODIFIER_FAILED="错误：modifier 执行失败"
    MSG_REPACKING="正在重新打包 AppImage..."
    MSG_REPACK_FAILED="重新打包 AppImage 失败"
    MSG_REPACK_SUCCESS="AppImage 已重新打包，覆盖"
    MSG_REMOVING_TEMP_DIR="已移除临时目录"
    MSG_FOUND_APPIMAGE="找到 AppImage："
    MSG_COPYING_APPIMAGE="正在复制 AppImage 到临时目录..."
    MSG_FAILED_UNPACK="解压 AppImage 失败"
    MSG_APPIMAGETOOL_NOT_FOUND="未找到 appimagetool"
    MSG_DOWNLOAD_PROMPT="下载 appimagetool？(Y/n)："
    MSG_DOWNLOADING="正在下载 appimagetool..."
    MSG_DOWNLOAD_FAILED="下载失败。您可以手动下载并保存到"
    MSG_DOWNLOAD_LINK="链接："
    MSG_APPIMAGETOOL_DOWNLOADED="appimagetool 已下载"
    MSG_MANUAL_DOWNLOAD="请下载 appimagetool 并将其放置到"
    MSG_TO_CONTINUE="以继续"
    MSG_WGET_CURL_NOT_FOUND="错误：未安装 wget 或 curl。请先安装其中一个。"
    MSG_RESTORING_COMPLETE="恢复完成！"
    MSG_PATCHING_COMPLETE="修补完成！"
    MSG_PROCESS_COMPLETE="处理完成！"
    MSG_CREATE_TEMP_DIR="创建临时目录"
    MSG_ERROR_TEMP_DIR="无法创建临时目录"
    MSG_ERROR_MODIFIER_NOT_FOUND="错误：未找到修改器程序"
    MSG_INVALID_PORT="错误：端口必须是有效的数字"
  else
    MSG_ERROR_NOT_FOUND="Error: Cursor AppImage not found"
    MSG_ERROR_INVALID_MODE="Error: Invalid mode. Use '--patch' or '--restore'."
    MSG_ERROR_MODE_CONFLICT="Error: Conflicting options - please use either --patch or --restore, not both"
    MSG_PATCHING="Patching Cursor AppImage..."
    MSG_RESTORING="Restoring Cursor AppImage..."
    MSG_UNPACKING="Unpacking AppImage..."
    MSG_UNPACKED_TO="AppImage unpacked ->"
    MSG_PATCHING_WITH_MODIFIER="Patching with modifier..."
    MSG_ERROR_MODIFIER_FAILED="Error: modifier failed"
    MSG_REPACKING="Repacking AppImage..."
    MSG_REPACK_FAILED="Failed to repack AppImage"
    MSG_REPACK_SUCCESS="AppImage repacked, overwrite"
    MSG_REMOVING_TEMP_DIR="Removed temporary directory"
    MSG_FOUND_APPIMAGE="Found AppImage:"
    MSG_COPYING_APPIMAGE="Copying AppImage to temporary directory..."
    MSG_FAILED_UNPACK="Failed to unpack AppImage"
    MSG_APPIMAGETOOL_NOT_FOUND="appimagetool not found"
    MSG_DOWNLOAD_PROMPT="Download appimagetool? (Y/n):"
    MSG_DOWNLOADING="Downloading appimagetool..."
    MSG_DOWNLOAD_FAILED="Download failed. You can manually download and save it to"
    MSG_DOWNLOAD_LINK="Link:"
    MSG_APPIMAGETOOL_DOWNLOADED="Appimagetool downloaded"
    MSG_MANUAL_DOWNLOAD="Please download appimagetool and put it to"
    MSG_TO_CONTINUE="to continue"
    MSG_WGET_CURL_NOT_FOUND="Error: Neither wget nor curl is installed. Please install one of them first."
    MSG_RESTORING_COMPLETE="Restoring complete!"
    MSG_PATCHING_COMPLETE="Patching complete!"
    MSG_PROCESS_COMPLETE="AppImage process complete!"
    MSG_CREATE_TEMP_DIR="Creating temporary directory"
    MSG_ERROR_TEMP_DIR="Cannot create temporary directory"
    MSG_ERROR_MODIFIER_NOT_FOUND="Error: Modifier program not found"
    MSG_INVALID_PORT="Error: Port must be a valid number"
  fi
}

# 解析命令参数
parse_params() {
  options=$(getopt -o hl:a:p:s: --long help,lang:,appimage:,port:,suffix:,patch,restore,skip-hosts,debug -n '$TOOL_NAME' -- "$@")
  if [ $? -ne 0 ]; then
    echo "错误的选项" >&2
    exit 1
  fi

  eval set -- "$options"

  while true; do
    case "$1" in
      -h|--help)
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
        # 验证端口是数字
        if ! [[ "${PORT}" =~ ^[0-9]+$ ]]; then
          echo "${MSG_INVALID_PORT}: ${PORT}"
          exit 1
        fi
        shift 2
        ;;
      -s|--suffix)
        SUFFIX="$2"
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

  # 设置语言代码
  LANG_CODE=${LANG_CODE:-$(detect_system_lang)}
  init_lang

  # 检查 AppImage 路径
  if [ -z "${APPIMAGE_PATH}" ]; then
    echo "${MSG_ERROR_NOT_FOUND}"
    exit 1
  fi

  if [ ! -f "${APPIMAGE_PATH}" ]; then
    echo "${MSG_ERROR_NOT_FOUND}: (${APPIMAGE_PATH})"
    exit 1
  fi

  # 设置工具路径
  APPIMAGETOOL_PATH="${BASE_DIR}/appimagetool"
  APPIMAGETOOL_DOWNLOADING="${BASE_DIR}/appimagetool_downloading"

  show_info
}

# 下载文件工具函数
download_file() {
  local url="$1"
  local target="$2"

  debug_print "开始下载: $url 到 $target"

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

# 准备环境
prepare() {
  # 创建临时目录
  echo "${MSG_CREATE_TEMP_DIR}: ${TEMP_DIR}"
  mkdir -p "${TEMP_DIR}"
  if [ $? -ne 0 ]; then
    echo "${MSG_ERROR_TEMP_DIR}: ${TEMP_DIR}"
    exit 1
  fi

  MODIFIER_PATH="${BASE_DIR}/modifier"
  if [ ! -f "${MODIFIER_PATH}" ]; then
    echo "${MSG_ERROR_MODIFIER_NOT_FOUND} ${MODIFIER_PATH}"
    exit 1
  fi

  if [ -f "${APPIMAGETOOL_DOWNLOADING}" ]; then
    rm -f "${APPIMAGETOOL_DOWNLOADING}"
  fi

  # 检查并准备 appimagetool
  if [ ! -f "${APPIMAGETOOL_PATH}" ]; then
    if command -v appimagetool &> /dev/null; then
      APPIMAGETOOL_PATH="appimagetool"
      debug_print "使用系统的 appimagetool"
    else
      echo "${MSG_APPIMAGETOOL_NOT_FOUND}"
      read -p "${MSG_DOWNLOAD_PROMPT}" -r DOWNLOAD
      DOWNLOAD=${DOWNLOAD,,}

      if [[ ! "${DOWNLOAD}" =~ ^(n|no)$ ]]; then
        echo "${MSG_DOWNLOADING}"
        download_file "https://github.com/AppImage/appimagetool/releases/download/continuous/appimagetool-x86_64.AppImage" "${APPIMAGETOOL_DOWNLOADING}"

        if [ $? -ne 0 ]; then
          echo "${MSG_DOWNLOAD_FAILED} ${APPIMAGETOOL_PATH}"
          echo "${MSG_DOWNLOAD_LINK} https://github.com/AppImage/appimagetool/releases/download/continuous/appimagetool-x86_64.AppImage"
          rm -f "${APPIMAGETOOL_DOWNLOADING}"
          exit 1
        fi

        chmod +x "${APPIMAGETOOL_DOWNLOADING}"
        mv "${APPIMAGETOOL_DOWNLOADING}" "${APPIMAGETOOL_PATH}"
        echo "${MSG_APPIMAGETOOL_DOWNLOADED}"
      else
        echo "${MSG_MANUAL_DOWNLOAD} ${APPIMAGETOOL_PATH} ${MSG_TO_CONTINUE}"
        echo "${MSG_DOWNLOAD_LINK} https://github.com/AppImage/appimagetool/releases/download/continuous/appimagetool-x86_64.AppImage"
        exit 1
      fi
    fi
  fi

  debug_print "环境准备完毕"
}

# 处理 AppImage
process_appimage() {
  echo "${MSG_FOUND_APPIMAGE} ${APPIMAGE_PATH}"

  # 复制 AppImage 到临时目录
  echo "${MSG_COPYING_APPIMAGE}"
  cp -f "${APPIMAGE_PATH}" "${TEMP_DIR}/"
  local temp_appimage="${TEMP_DIR}/$(basename "${APPIMAGE_PATH}")"
  debug_print "AppImage 已复制到: ${temp_appimage}"

  # 解压 AppImage
  echo "${MSG_UNPACKING}"
  cd "${TEMP_DIR}" || exit 1
  chmod +x "${temp_appimage}"
  "${temp_appimage}" --appimage-extract > /dev/null 2>&1

  if [ $? -ne 0 ]; then
    echo "${MSG_FAILED_UNPACK}"
    exit 1
  fi

  echo "${MSG_UNPACKED_TO} ${TEMP_DIR}/squashfs-root"

  # 使用 modifier 修补
  echo "${MSG_PATCHING_WITH_MODIFIER}"
  if $SKIP_HOSTS; then
    SUDO=""
    MODIFIER_EXTRA_PARAMS=" --skip-hosts"
    debug_print "跳过 hosts 修改，不使用 sudo"
  fi

  debug_print "执行命令: ${SUDO}${MODIFIER_PATH} --cursor-path ${TEMP_DIR}/squashfs-root/usr/share/cursor/resources/app --port ${PORT} --suffix ${SUFFIX} local${MODIFIER_EXTRA_PARAMS}"
  ${SUDO}${MODIFIER_PATH} --cursor-path "${TEMP_DIR}/squashfs-root/usr/share/cursor/resources/app" --port "${PORT}" --suffix "${SUFFIX}" local${MODIFIER_EXTRA_PARAMS}

  if [ $? -ne 0 ]; then
    echo "${MSG_ERROR_MODIFIER_FAILED}"
    exit 1
  fi

  # 重新打包 AppImage
  echo "${MSG_REPACKING}"
  "${APPIMAGETOOL_PATH}" squashfs-root "${temp_appimage}"

  if [ $? -ne 0 ]; then
    echo "${MSG_REPACK_FAILED}"
    exit 1
  fi

  # 将修改后的 AppImage 复制回原位置
  sudo cp -f "${APPIMAGE_PATH}" "${APPIMAGE_PATH}_$(date +%s)"
  sudo cp -f "${temp_appimage}" "${APPIMAGE_PATH}"
  echo "${MSG_REPACK_SUCCESS} ${APPIMAGE_PATH}"

  # 清理临时文件
  cd "${BASE_DIR}" || exit 1
  rm -rf "${TEMP_DIR}"
  echo "${MSG_REMOVING_TEMP_DIR}: ${TEMP_DIR}"

  echo "${MSG_PROCESS_COMPLETE}"

  exit 0
}

# 主函数
main() {
  parse_params "$@"
  prepare
  process_appimage
}

main "$@"
