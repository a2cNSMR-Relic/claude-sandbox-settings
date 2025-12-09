# Git リモート操作

git push, git pull, git fetch, git clone などリモートリポジトリへの接続が必要なコマンドは、
サンドボックスモードではDNS解決ができないため、`dangerouslyDisableSandbox: true` で実行すること。