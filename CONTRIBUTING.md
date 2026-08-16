# 模板维护说明

本仓库用于维护技术报告模板，不用于保存具体项目报告。

## 提交流程

1. 从 main 创建独立分支。
2. 修改模板、说明或验证脚本。
3. 运行普通编译检查。
4. 确认没有加入个人草稿、真实项目数据、构建产物或本机绝对路径。
5. 提交 Pull Request，并说明排版变化和兼容性影响。

## 合并前检查

~~~powershell
powershell -ExecutionPolicy Bypass -File .\scripts\verify.ps1
~~~

模板本身保留占位符，因此维护模板时不使用 -Strict。严格模式仅用于具体报告定稿。
