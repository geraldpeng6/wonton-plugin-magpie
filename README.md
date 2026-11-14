# magpie · Wonton 模型设置

Wonton 的系统模型网关插件。主人在 magpie 网页里配置一次服务商和 API key，Bot 和其他获准使用模型的插件共用网关，不接触服务商密钥。

## 上游与插件行为

使用 [yetone/magpie](https://github.com/yetone/magpie) 的官方镜像 `ghcr.io/yetone/magpie`（MIT），具体版本和摘要固定在 `docker-compose.yml`，本仓库不修改或重建上游镜像。版本由插件固定，更新随插件发布（换镜像摘要）：`web.sh` 在每次启动时关掉 magpie 的自动更新检查和网页顶栏的 Update 气泡（magpie 的设置 `noAutoUpdate`、`noUpdatePill`，每次启动重设）。网页 Settings 里仍可手动检查更新，但固定镜像里的 magpie 装不进自己，会如实报错。

- 手机上的网页页面头收成一行：固定版本把品牌和页面标签分成两行，上面一行近 50px 只有标志和两个图标，页面内容被压到 110px 以下；上游 v0.1.3608 起改成底部标签栏。`web.sh` 起的 `inject.pl` 在网页 HTML 里插入 `layout.css`，不改镜像。
- 核心经模型网关转发 OpenAI、Anthropic 和 Gemini 请求；`credentials.sh` 为调用方签发、吊销独立网关凭据。
- 网页由核心网关代登录（`sso: proxy`），服务商配置和密钥保存在插件数据目录中。
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


## 图标

图标来自 [yetone/magpie](https://github.com/yetone/magpie) 的上游标志，仅用于识别应用，不表示合作或背书，MIT 不授予商标权；来源、处理方式和许可全文见 [NOTICE](NOTICE)。
