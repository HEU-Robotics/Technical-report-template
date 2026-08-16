# HEU Robotics 技术报告模板

供 HEU Robotics 成员编写中文技术报告的 LaTeX 模板。推荐职责分工是：

> 成员负责事实、观点、数据和结论；AI 负责结构整理、LaTeX 排版与规范检查。

AI 不得替作者补造经历、实验、数据、引用或结论。作者必须审阅最终 PDF，并对报告内容负责。

## 推荐工作流

1. 在 GitHub 页面点击 Use this template，为具体报告创建独立仓库。
2. 克隆新建的报告仓库，而不是把个人报告提交回模板仓库。
3. 将已写好的草稿复制到 draft/；Markdown 或纯文本最方便 AI 处理。
4. 将图片复制到 figures/，文件名使用简短英文和连字符。
5. 让 AI 先读取 AGENTS.md，再执行 prompts/format-report.md 中的任务。
6. 作者核对正文、数字、图表、结论与草稿是否一致。
7. 运行编译检查，通过后再提交和推送。

也可以直接克隆本仓库做本地试用：

~~~powershell
git clone https://github.com/HEU-Robotics/Technical-report-template.git
cd Technical-report-template
~~~

如果要继续推送具体报告，请把 origin 改为该报告自己的仓库地址。

## 快速开始

1. 编辑 report-info.tex 中的标题、作者、日期、版本和状态。
2. 将草稿放入 draft/，不要覆盖或改写原始草稿。
3. 使用 AI 将内容整理到 sections/。
4. 将图片放入 figures/，正文使用相对路径引用。
5. 执行：

~~~powershell
powershell -ExecutionPolicy Bypass -File .\scripts\verify.ps1
~~~

成功后 PDF 位于 build/main.pdf。正式发布前可启用严格检查：

~~~powershell
powershell -ExecutionPolicy Bypass -File .\scripts\verify.ps1 -Strict
~~~

严格模式会拒绝仍含“待填写”、TODO 或 TBD 的报告。

## 目录结构

~~~text
.
├── AGENTS.md                    # 仓库级 AI 工作规范
├── report-info.tex             # 报告元数据
├── main.tex                    # 正文装配入口
├── styles/
│   └── heu-technical-report.sty
├── sections/                   # 正文章节
├── figures/                    # 报告图片
├── draft/                      # 本地原始草稿，默认不提交
├── prompts/
│   └── format-report.md        # 可直接交给 AI 的任务说明
└── scripts/
    └── verify.ps1              # 编译与完整性检查
~~~

section-template.tex 提供单图、并排图、公式、三线表和 TikZ 流程图片段，默认不进入最终报告。

## 排版约定

- 使用 XeLaTeX 编译，A4 纸张、1 英寸页边距、1.5 倍行距。
- 中文正文优先宋体，标题优先黑体；缺少字体时自动回退。
- 图片、表格和公式必须有唯一标签，分别使用 fig:、tab:、eq: 前缀。
- 正文交叉引用使用 \xref{标签}，重点文字使用 \imp{内容}。
- 图片必须使用项目内相对路径，不允许引用本机绝对路径。
- 表格优先使用 booktabs 三线表，不使用竖线堆叠。
- 不提交 build/、临时文件或未公开的原始草稿。

## 作者与 AI 的责任边界

| 项目 | 成员 | AI |
| --- | --- | --- |
| 事实、数据、引用与结论 | 提供并确认 | 不得编造或擅改 |
| 章节组织 | 确认逻辑 | 可在不改变原意的前提下整理 |
| LaTeX 排版 | 最终验收 | 负责实现和修复 |
| 图片与图注 | 提供来源并确认含义 | 负责布局和编号 |
| 最终 PDF | 审阅并批准 | 负责编译检查 |

## 模板维护

对模板本身的修改请阅读 CONTRIBUTING.md，并通过独立分支和 Pull Request 提交。模板仓库不接收具体项目报告。
