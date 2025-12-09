#!/bin/bash
# PreToolUseフック: 機密ディレクトリへのアクセスをブロック

# 標準入力からツール情報をJSON形式で受け取る
input=$(cat)

# ツール名を取得
tool_name=$(echo "$input" | jq -r '.tool_name // ""')

# パスを抽出（Bashの場合はcommand、Read/Edit/Writeの場合はfile_path）
if [ "$tool_name" = "Bash" ]; then
  target=$(echo "$input" | jq -r '.tool_input.command // ""')
else
  target=$(echo "$input" | jq -r '.tool_input.file_path // ""')
fi

# 機密パスのパターン
sensitive_patterns=(
  ".ssh"
  ".aws"
  ".gnupg"
  ".env"
  "credentials"
  "secrets"
)

# パターンマッチング
for pattern in "${sensitive_patterns[@]}"; do
  if [[ "$target" == *"$pattern"* ]]; then
    echo "{\"decision\": \"block\", \"reason\": \"機密パス '$pattern' へのアクセスは禁止されています\"}"
    exit 0
  fi
done

# 許可
exit 0
