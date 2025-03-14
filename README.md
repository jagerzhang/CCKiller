# CCkiller
Linux attack defense scripts tool --- Linux CC攻击防御工具脚本

[![Hits](https://hits.seeyoufarm.com/api/count/incr/badge.svg?url=https%3A%2F%2Fgithub.com%2Fjagerzhang%2FCCKiller&count_bg=%2379C83D&title_bg=%23555555&icon=&icon_color=%23E7E7E7&title=hits&edge_flat=false)](https://hits.seeyoufarm.com)

1. 请执行如下命令在线安装：

```
curl -ko install.sh https://zhang.ge/wp-content/uploads/files/cckiller/install.sh?ver=1.0.8 && sh install.sh -i
```

2015-09-23 Ver 1.0.1：

- 支持白名单为IP段，格式为IP段通用格式，比如 192.168.1.0/24；
- 新增拉黑改为判断 iptables 是否已存在操作IP的判断方式；
- 增加日志记录功能，每天一个日志文件，位于安装目录下的log文件内；
- 集成手动拉黑IP和解封IP功能，使用cckiller -b IP 拉黑，使用 cckiller -u IP 解封。

2015-11-29 Ver 1.0.2：

- 新增在线更新功能，执行 ./install.sh -u 即可检测是否有新版本：CCKiller：Linux轻量级CC攻击防御工具，秒级检查、自动拉黑和释放
- 如果发现有新版本则显示更新内容，并提示是否执行更新。选择之后将会更新到新版本，需要重新配置，但是IP或端口白名单会保持不变。
- 新增端口白名单功能
- 应网友需求，新增了这个端口白名单功能。在配置CCKiller的最后一项会提示输入端口白名单

如果需要排除某些端口，请如图最后一行所示，输入端口并已逗号分隔，比如 21,2121,8000
本次更新为非必须功能，在用的朋友可以按需更新，当然新增了在线更新这个功能，也强力推荐更新一下，方便后续检测CCKiller是否是最新版本。
更新难免存在不可意料的纰漏，使用中存在任何问题请留言告知，谢谢！

2016-06-20 Ver 1.0.3：

- 增加“永久”拉黑时长
- 有网友反馈，需要设置更长的拉黑时间。原先的机制来看，如果设置拉黑时间过长，那么可能会产生很多后台释放黑名单脚本，占用系统资源。
- 因此，1.0.3版本加入永久拉黑设置。只要在安装的时候，设置拉黑时长为0，则CCKiller不会再产生后台释放脚本，也不会释放已拉黑的IP了

但是，考虑到灵活性问题，并没有在新版中加入 service iptables save 的保存命令，所以当你重启系统或者重启iptables，这些拉黑的IP都将得到释放。当然，如果你真的想永久拉黑，请手动执行 service iptables save 即可。
注册开机启动
新版本已将CCKiller服务注册到了开机启动服务列表，重启系统不用在担心未启动CCKiller了。
兼容 Centos 7
目前博客运行在Centos 7 系统，所以将CCKiller也做了一下兼容，其实就是在Centos 7上安装了iptables。并且修复了Centos7系统对已拉黑IP的判断问题。
Ps：以上功能如果你觉得有用，可以执行 install.sh -u 进行在线更新，记得是小写u哦。

2016-10-09 Ver 1.0.4：

- BUG修复
根据网友反馈，发现攻防测试中一个IP不能被拉黑，经过分析发现命中了白名单。而实际上白名单中并没有IP段，只因IP同属于一个网段。因此，在是否属于IP段的判断中，加入对斜杠的筛选，也就是说只判断白名单中存在斜杠(/)的条目，简单粗暴！

2017-05-20 Ver 1.07 (中间漏记了2个小版本，也不记得修复了啥)

- 日志级别、开关

根据网友建议，新增日志控制开关，参数为LOG_LEVEL，支持 INFO、DEBUG和OFF 3个参数，其中INFO表示仅记录拉黑和释放IP，DEBUG记录全部日志，包括拉黑、释放的报错信息，OFF表示关闭日志。
如果需要使用该功能，可以执行 ./install.sh -u 在线更新或直接重新安装。

2019-07-11 Ver 1.0.8
- 支持IPv6检查;
- 优化在线安装脚本，减少下载失败几率；
- 基于/proc/net检查，替换netstat，避免在高并发时netstat导致CPU高负载的问题，感谢Late Winter指出，检查代码来自DDoS-Defender-v2.1.0。
