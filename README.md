# Claude Code Sandbox Settings

このプロジェクトでは Claude Code のサンドボックスモードの設定を行います。

## 設定ファイル

`.claude/settings.json` に以下の設定を記述しています。

## sandbox オプション

| オプション | 値 | 説明 |
|-----------|-----|------|
| `enabled` | `true` | サンドボックスモードを有効化。Bashコマンドの実行がサンドボックス内に制限され、ファイルシステムへのアクセスが制御されます。 |
| `autoAllowBashIfSandboxed` | `false` | サンドボックス有効時でも、Bashコマンド実行前にユーザー確認を求めます。`true` にすると確認なしで自動実行されます。 |
| `allowUnsandboxedCommands` | `false` | サンドボックス外でのコマンド実行を禁止します。`true` にするとサンドボックスを無効化したコマンド実行が許可されます。 |

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
