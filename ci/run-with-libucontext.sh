#!/bin/sh
# 方案 B 兜底启动器：官方 TUI 的 libopentui.so 是 glibc 版，直接在本机 musl 下加载会
# 报 "getcontext: symbol not found"。musl 没有 getcontext/setcontext/makecontext 等
# ucontext 符号，用 libucontext 补上即可加载。已验证：Alpine 装 libucontext 后，
# LD_PRELOAD=/usr/lib/libucontext.so.1 能成功加载官方 .so。
#
# 依赖：apk add libucontext   （提供 /usr/lib/libucontext.so.1）
#
# 用法：安装好官方/社区 zcode 后，用本脚本替代直接运行 zcode：
#   ./run-with-libucontext.sh [zcode 参数...]
set -eu

LIBUCONTEXT=""
for c in /usr/lib/libucontext.so.1 /usr/lib/libucontext.so /lib/libucontext.so.1; do
  [ -e "$c" ] && { LIBUCONTEXT="$c"; break; }
done

if [ -z "$LIBUCONTEXT" ]; then
  echo "未找到 libucontext，请先安装：apk add libucontext" >&2
  exit 1
fi

if [ -n "${LD_PRELOAD:-}" ]; then
  export LD_PRELOAD="$LIBUCONTEXT:$LD_PRELOAD"
else
  export LD_PRELOAD="$LIBUCONTEXT"
fi

exec "$@"
