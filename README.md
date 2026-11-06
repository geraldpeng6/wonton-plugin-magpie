# magpie · Wonton 模型设置

Wonton 的系统模型网关插件。主人在 magpie 网页里配置一次服务商和 API key，Bot 和其他获准使用模型的插件共用网关，不接触服务商密钥。

## 上游与插件行为

使用 [yetone/magpie](https://github.com/yetone/magpie) 的官方镜像 `ghcr.io/yetone/magpie`（MIT），具体版本和摘要固定在 `docker-compose.yml`，本仓库不修改或重建上游镜像。

- 核心经模型网关转发 OpenAI、Anthropic 和 Gemini 请求；`credentials.sh` 为调用方签发、吊销独立网关凭据。
- 网页由核心网关代登录（`sso: proxy`），服务商配置和密钥保存在插件数据目录中。
- `providers.sh` 提供服务商列表、保存和连通性测试命令。
- `default-model.sh` 维护 `group/wonton-default`，依据服务商和模型目录选择默认模型；主人改过该组后不覆盖，删除后按规则重建。维护容器不联网。

## 开发与检查

准备 Bash、Git、curl、Python 3、Docker Engine 和 Docker Compose；仓库放在运行 Docker 的本机，路径不要含空白或 shell 特殊字符。`scripts/` 来自 [wonton-plugin-template](https://github.com/geraldpeng6/wonton-plugin-template)，开发状态保存在忽略提交的 `.wonton/`。

在插件仓库根目录执行：

```sh
scripts/check.sh
```

检查使用核心镜像里的真实插件解析器；可用 `WONTON_CORE_IMAGE` 指定支持清单 spec 的核心镜像。`scripts/check.sh --official` 另外检查商店要求（许可证、作者、镜像摘要等），不代表本系统插件应加入社区商店。

本插件声明 `kind: system`，只能随核心镜像预装，不能经普通插件安装接口安装。因此模板的 `scripts/dev.sh install`、`reinstall` 和通用安装冒烟不能替代系统插件验证。集成开发需构建包含本仓库插件包的核心镜像，再以该镜像启动独立实例：

```sh
WONTON_CORE_IMAGE=<包含本插件的本地核心镜像> WONTON_PULL=never WONTON_INSTANCE=magpiedev scripts/dev.sh up
scripts/dev.sh status
scripts/dev.sh token
```

用令牌登录实例网页的“模型设置”，验证服务商配置和模型请求；重新创建插件容器后确认配置仍保留。只清理自己的实例，不执行全局 Docker prune。开发结束用 `scripts/dev.sh purge` 清理该实例。

## 服务商命令测试

`test-providers.sh` 需要 Docker，使用固定摘要的 magpie 镜像与仅存在于测试中的 OpenAI 兼容桩。测试容器只接入内部网络，不使用真实厂商或真实 key；退出时删除自己创建的容器、网络、卷和镜像标签。

在插件仓库根目录运行：

```sh
nice -n 19 sh ./test-providers.sh
```

共享 Docker 时先遵守所在开发环境的负载限制。可用 `WONTON_PROVIDER_STUB_IMAGE` 指定本地可用的 Python 3 测试镜像（默认 `python:3.12-alpine`）。

覆盖只测试不保存、自定义保存、拒绝 key、断连和超时，以及从另一容器用插件网关凭据请求 `group/wonton-default`，验证请求实际使用所填的服务商和模型；同时验证主人修改默认组后不被覆盖。

## 图标

图标来自 [yetone/magpie](https://github.com/yetone/magpie) 的上游标志，仅用于识别应用，不表示合作或背书，MIT 不授予商标权；来源、处理方式和许可全文见 [NOTICE](NOTICE)。
