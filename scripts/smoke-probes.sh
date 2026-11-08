# shellcheck shell=bash
# 跟着插件走的冒烟探针。网页、数据两项都真的请求插件。
#
# magpie 是系统插件（kind: system）：dev.sh install 拒绝安装，通用冒烟在“装得上”就停下，
# 这些探针供核心镜像集成实例（README 的 magpiedev 流程）和 dev.sh probes 用。
# magpie 是模型网关：网页由核心网关代登录（sso: proxy，代为带网页密钥 Cookie），应用自己
# 没有账号体系，也没有自己的 MCP 服务。
export IDENTITY_NA=1
export SMOKE_NOTE="magpie 的网页由核心网关代登录，应用没有账号体系；也没有自己的 MCP 服务。网页、身份、插件工具三项不适用或在网关侧验证。"

# 网页密钥 Cookie（magpie_web_<端口>）带上后回的就是应用真实页面。
web_assert() { grep -q '<title>magpie</title>'; }

# 数据：服务商配置和 key 都存在数据目录（compose 挂在 /config）。写一个标记文件进去，
# 重装/升级后还在才算数。
magpie_container() { printf 'wonton-%s--%s--magpie' "$SMOKE_INSTANCE" "$SMOKE_SLUG"; }

data_write() {
  local marker
  marker="smoke-$(head -c 8 /dev/urandom | od -An -tx1 | tr -d ' \n')"
  docker exec "$(magpie_container)" sh -c "printf %s '$marker' > /config/smoke-marker" ||
    { echo "写标记失败"; return 1; }
  printf '%s\n' "$marker" >"$SMOKE_STATE/magpie-marker"
}

data_check() {
  local marker want
  [[ -s "$SMOKE_STATE/magpie-marker" ]] || { echo "标记文件不在：data_write 没跑成？"; return 1; }
  read -r marker <"$SMOKE_STATE/magpie-marker"
  want="$(docker exec "$(magpie_container)" cat /config/smoke-marker 2>&1)" ||
    { echo "标记读不到：$want"; return 1; }
  [[ "$want" == "$marker" ]] || { echo "标记对不上：$want != $marker"; return 1; }
}
