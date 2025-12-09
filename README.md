# Claude Code Sandbox Settings

このプロジェクトでは Claude Code のサンドボックスモードの設定を行います。

## 設定ファイル

| ファイル | 説明 |
|----------|------|
| `.claude/settings.json` | サンドボックスとフックの設定 |
| `CLAUDE.md` | Claude Code への指示（プロンプト） |

## sandbox オプション

`.claude/settings.json` で設定します。

| オプション | 値 | 説明 |
|-----------|-----|------|
| `enabled` | `true` | サンドボックスモードを有効化。Bashコマンドの実行がサンドボックス内に制限され、ファイルシステムへのアクセスが制御されます。 |
| `autoAllowBashIfSandboxed` | `false` | サンドボックス有効時でも、Bashコマンド実行前にユーザー確認を求めます。`true` にすると確認なしで自動実行されます。 |
| `allowUnsandboxedCommands` | `true` | サンドボックス外でのコマンド実行を許可します。Git リモート操作など、ネットワークアクセスが必要なコマンドに必要です。 |

## permissions オプション

### allow（許可されたパーミッション）

| パーミッション | 説明 |
|---------------|------|
| `Read(./**)` | 現在のプロジェクトディレクトリ配下のファイル読み取りを許可 |
| `Edit(./**)` | 現在のプロジェクトディレクトリ配下のファイル編集を許可 |
| `Write(./**)` | 現在のプロジェクトディレクトリ配下へのファイル書き込みを許可 |
| `Edit(/tmp/claude/**)` | `/tmp/claude/` 配下のファイル編集を許可（一時ファイル用） |
| `Write(/tmp/claude/**)` | `/tmp/claude/` 配下へのファイル書き込みを許可（一時ファイル用） |
| `Read(~/.gitconfig)` | Git のグローバル設定ファイルの読み取りを許可（コミット時のユーザー情報参照用） |

### deny（拒否されたパーミッション）

| パーミッション | 説明 |
|---------------|------|
| `Read(~/**)` | ホームディレクトリ配下の読み取りを拒否 |
| `Read(../)`, `Read(../**)` | 親ディレクトリへのアクセスを拒否（ディレクトリトラバーサル防止） |
| `Edit(~/**)` | ホームディレクトリ配下の編集を拒否 |
| `Edit(../)`, `Edit(../**)` | 親ディレクトリの編集を拒否 |
| `Edit(.claude/settings.local.json)` | ローカル設定ファイルの編集を拒否（設定の改ざん防止） |
| `Write(~/**)` | ホームディレクトリ配下への書き込みを拒否 |
| `Write(../)`, `Write(../**)` | 親ディレクトリへの書き込みを拒否 |
| `Write(.claude/settings.local.json)` | ローカル設定ファイルへの書き込みを拒否 |

## セキュリティ上の目的

この設定により以下のセキュリティが確保されます：

1. **プロジェクト外へのアクセス制限** - Claude Code がプロジェクトディレクトリ外のファイルにアクセスすることを防止
2. **ディレクトリトラバーサル防止** - `../` を使った親ディレクトリへの脱出を防止
3. **ホームディレクトリ保護** - 個人ファイルや認証情報などへのアクセスを防止
4. **設定ファイル保護** - Claude Code が自身の設定を変更することを防止

## MCP サーバー設定

`.mcp.json` ファイルで MCP（Model Context Protocol）サーバーを設定できます。

### GitHub MCP サーバー

GitHub MCP サーバーを使用すると、Claude Code から直接 GitHub の操作（リポジトリ作成、Issue 管理、PR 作成など）が可能になります。

#### セットアップ手順

1. `.mcp.json.example` を `.mcp.json` にコピー：

```bash
cp .mcp.json.example .mcp.json
```

2. GitHub Personal Access Token を作成：
   - [GitHub Settings > Developer settings > Personal access tokens](https://github.com/settings/tokens) にアクセス
   - 「Tokens (classic)」で新しいトークンを作成
   - `Note` に「MCP Token」など分かりやすい名前を設定
   - 必要なスコープ: `repo`, `read:org`, `read:user` など（使用する機能に応じて設定）

   **★注意!! : トークンは一度しか表示されないため、必ず控えておいてください。**

3. `.mcp.json` を編集し、環境変数を設定：

- `args` セクションの解説
  - `--name github-mcp-server` ... コンテナ名を指定（任意の名前に変更可）
  - `-e GITHUB_PERSONAL_ACCESS_TOKEN` ... GitHub トークンを環境変数として渡す指定
- `env` セクションの解説
  - `GITHUB_OWNER` ... 自分のGitHubユーザー名に置き換え
  - `GITHUB_REPO` ... 操作対象のリポジトリ名に置き換え。全てのリポジトリを操作する場合は不要。

```json
{
  "mcpServers": {
    "github": {
      "command": "docker",
      "args": [
        "run",
        "-i",
        "--rm",
        "--name",
        "github-mcp-server",
        "-e",
        "GITHUB_PERSONAL_ACCESS_TOKEN",
        "-e",
        "GITHUB_OWNER",
        "ghcr.io/github/github-mcp-server"
      ],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "${GITHUB_ACCESS_TOKEN_FOR_MCP}",
        "GITHUB_OWNER": "your_github_username",
        "GITHUB_REPO": "repository_name"
      }
    }
  }
}
```

4. 環境変数 `GITHUB_ACCESS_TOKEN_FOR_MCP` を設定：

GitHub トークンを環境変数に設定します。

```bash
export GITHUB_ACCESS_TOKEN_FOR_MCP="ghp_xxxxxxxxxxxx"
```

または `.zshrc` / `.bashrc` に追加して永続化します。

#### 主な機能

| 機能 | 説明 |
|------|------|
| リポジトリ管理 | リポジトリの作成、フォーク、ファイル操作 |
| Issue 管理 | Issue の作成、更新、コメント追加、検索 |
| Pull Request | PR の作成、レビュー、マージ |
| ブランチ管理 | ブランチの作成、一覧取得 |
| コード検索 | GitHub 上のコード検索 |

#### 注意事項

- `.mcp.json` には認証情報が含まれる可能性があるため、`.gitignore` に追加してください
- Docker が必要です（MCP サーバーはコンテナとして実行されます）
- `--rm` と `--name` を併用しているため、コンテナ終了時に自動削除されます。ただし、同じ名前のコンテナが既に実行中の場合はエラーになります

### GitHub CLI（gh）と GitHub MCP サーバーの比較

GitHub CLI（`gh`）がインストールされている環境で GitHub MCP サーバーを導入した場合、両者の役割と使い分けについて説明します。

#### 比較表

| 観点 | GitHub MCP サーバー | GitHub CLI（gh） |
|------|---------------------|------------------|
| サンドボックス制限 | **影響を受けない** | Bash ツール経由のため制限を受ける |
| カバー範囲 | 主要な API 操作（Issues, PRs, リポジトリ等） | GitHub API のほぼ全機能 |
| 認証 | MCP 設定（`.mcp.json`）で管理 | `gh auth` で管理 |
| 実行方法 | Claude Code が直接ツールとして呼び出し | Bash コマンドとして実行 |

#### GitHub MCP サーバーでカバーできる主な操作

- リポジトリの検索・作成・フォーク
- Issues / PR の作成・更新・検索・コメント
- ブランチ・タグ・リリースの管理
- ファイルの読み書き（リモートリポジトリ上）
- コミット履歴の取得

#### GitHub CLI（gh）が必要になるケース

- MCP サーバーが提供していない API エンドポイント
- GitHub Actions のワークフロー操作
- Gist 操作
- より複雑なクエリやカスタム操作

#### サンドボックス環境での推奨

サンドボックスモードでプロジェクトフォルダ外へのアクセスが制限されている場合、**GitHub MCP サーバーの方が制約なく動作します**。MCP サーバーはサンドボックスの制限を受けないため、日常的な GitHub 操作のほとんどをカバーできます。

ただし、`gh` を完全にアンインストールする必要はありません。MCP サーバーでカバーできない操作が必要になった場合のバックアップとして残しておくのが実用的です。

## PreToolUse フック

### 概要

PreToolUse フックは、Claude Code がツール（Bash、Read、Write、Edit）を実行する**直前**に呼び出されるカスタムスクリプトです。これにより、機密ファイルへのアクセスをブロックできます。

### なぜフックが必要か

サンドボックスモードでは**書き込み**は制限されますが、**読み込み**は制限されません。また、`permissions.deny` 設定には複数のバグが報告されており、確実に動作しない可能性があります。

#### 関連する既知の問題（GitHub Issues）

| Issue | 概要 |
|-------|------|
| [#6699](https://github.com/anthropics/claude-code/issues/6699) | **Critical Security Bug**: `settings.json` の `deny` パーミッション設定が完全に機能しない |
| [#6631](https://github.com/anthropics/claude-code/issues/6631) | Read/Write ツールに対して `deny` 設定が適用されない |
| [#4467](https://github.com/anthropics/claude-code/issues/4467) | `.env` ファイルや `secrets/` ディレクトリへのアクセスをブロックできない |

これらの issue では、**PreToolUse フックを回避策として使用する**ことが提案されています。

PreToolUse フックはこれらの問題を回避し、機密ファイルへのアクセスを確実にブロックします。

### 設定ファイル

#### `.claude/settings.json`

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash|Read|Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": ".claude/hooks/check-sensitive-paths.sh"
          }
        ]
      }
    ]
  }
}
```

#### `.claude/hooks/check-sensitive-paths.sh`

機密パスへのアクセスをブロックするスクリプトです。

### ブロック対象のパターン

デフォルトで以下のパターンがブロックされます：

| パターン | 説明 |
|----------|------|
| `.ssh` | SSH 秘密鍵・設定ファイル |
| `.aws` | AWS 認証情報 |
| `.gnupg` | GPG 鍵 |
| `.env` | 環境変数ファイル |
| `credentials` | 認証情報ファイル全般 |
| `secrets` | シークレットファイル全般 |

### パターンの追加方法

`.claude/hooks/check-sensitive-paths.sh` 内の `sensitive_patterns` 配列に追加します：

```bash
sensitive_patterns=(
  ".ssh"
  ".aws"
  ".gnupg"
  ".env"
  "credentials"
  "secrets"
  # 以下を追加
  ".kube"           # Kubernetes設定
  ".docker"         # Docker認証情報
  ".npmrc"          # npm認証トークン
  "password"        # パスワード関連
)
```

### フックの動作

1. Claude Code がツールを実行しようとする
2. フックスクリプトがツール情報（JSON）を受け取る
3. 対象パスが機密パターンに一致するかチェック
4. 一致した場合: `{"decision": "block", "reason": "..."}` を返してブロック
5. 一致しない場合: ツール実行を許可

### 注意事項

- フックの変更後は Claude Code の再起動が必要です
- `jq` コマンドが必要です（JSON パース用）
- フックスクリプトには実行権限が必要です（`chmod +x`）
- **フックは Bash コマンド全体をチェックするため、コミットメッセージに機密パターン（`.ssh` 等）が含まれているとブロックされます**
- **サンドボックスモードでは一時ファイルの作成が制限されるため、HEREDOC を使った複数行のコミットメッセージが使用できません**。シンプルな `-m` オプションでコミットしてください

## 既知の制限事項

### Git リモート操作（push / pull / fetch / clone）

サンドボックスモードでは**ネットワーク（DNS解決）が制限される**ため、リモートリポジトリへの接続が必要な Git コマンドは失敗します。

#### 症状

```bash
$ git push
ssh: Could not resolve hostname github.com: -65563
fatal: Could not read from remote repository.
```

#### 影響を受けるコマンド

| コマンド | サンドボックス内 | サンドボックス解除 |
|----------|-----------------|-------------------|
| `git push` | 失敗 | 成功 |
| `git pull` | 失敗 | 成功 |
| `git fetch` | 失敗 | 成功 |
| `git clone` | 失敗 | 成功 |
| `git status` | 成功 | - |
| `git commit` | 成功 | - |
| `git log` | 成功 | - |

#### 対応方法

`CLAUDE.md` に以下を記述することで、Claude Code がリモート操作時に自動でサンドボックスを解除します：

```markdown
# Git リモート操作

git push, git pull, git fetch, git clone などリモートリポジトリへの接続が必要なコマンドは、
サンドボックスモードではDNS解決ができないため、`dangerouslyDisableSandbox: true` で実行すること。
```

この指示がない場合、Claude Code は：
1. サンドボックス内で実行を試みる
2. DNS解決エラーで失敗
3. サンドボックス解除を提案

という流れになり、**余分なトークンが消費されます**。

#### 設定要件

`.claude/settings.json` で `allowUnsandboxedCommands` を `true` に設定する必要があります：

```json
{
  "sandbox": {
    "enabled": true,
    "allowUnsandboxedCommands": true
  }
}
```

#### 補足：サンドボックス解除の動作

- `dangerouslyDisableSandbox: true` は**そのコマンドのみ**に適用
- 次のコマンドは自動的にサンドボックスモードに戻る
- 明示的に「戻す」操作は不要

### Git リモートリポジトリの追加

サンドボックスモードでは `~/.gitconfig` への書き込みが制限されているため、**初めてリモートリポジトリを追加する際に問題が発生する**場合があります。

#### 症状

```bash
$ git remote add origin https://github.com/user/repo.git
# または
$ git push -u origin main
```

上記のコマンド実行時に、Git が `~/.gitconfig` へ書き込もうとしてエラーになることがあります。

#### 回避策

1. **サンドボックス外で事前に設定する**：Claude Code を起動する前に、ターミナルで直接 Git の初期設定やリモートリポジトリの追加を行ってください。

```bash
# Claude Code 外のターミナルで実行
git remote add origin https://github.com/user/repo.git
git push -u origin main
```

2. **GitHub MCP サーバーを使用する**：リモートリポジトリの作成は GitHub MCP サーバー経由で行い、ローカルでのリモート追加のみ事前に設定しておく方法もあります。

#### 根本原因

サンドボックス設定で `~/.gitconfig` の**読み取りは許可**されていますが、**書き込みは許可されていません**。Git は初回のリモート操作時に認証情報のキャッシュ設定などを `~/.gitconfig` に書き込もうとすることがあり、これがブロックされます。
