---
allowed-tools: Task,Bash(gh pr view:*),Bash(gh pr diff:*),WebFetch,WebSearch,mcp__github_comment__update_claude_comment
description: Dependabot PRをバージョン差分・影響範囲・セキュリティの3観点からレビュー
---

# Dependabot PR レビュー

> **⚠️ 必須制約**: このコマンドは必ず `Task` ツールを3回呼び出してサブエージェントを起動すること。自分で分析を行ってはならない。

## 手順

### ステップ1: PR情報の取得

`gh pr view` でライブラリ名・旧バージョン・新バージョンを取得する。

### ステップ2: 進捗コメントを投稿

`mcp__github_comment__update_claude_comment` で以下のTodoリストを投稿する:

```
- [ ] バージョン差分・CHANGELOG・Breaking Changes 調査中
- [ ] セキュリティ影響（CVE・脆弱性）調査中
- [ ] コードベースへの影響範囲 調査中
- [ ] 結果統合・レビューコメント投稿
```

### ステップ3: Task ツールで3つのサブエージェントを同時起動（必須）

**必ず `Task` ツールを3回、同時に呼び出すこと。** 各Taskに以下を指示する:

**Task 1（dependabot-version-analyzer）への指示文:**
```
更新ライブラリ: <ライブラリ名> <旧バージョン> → <新バージョン>
CHANGELOG・リリースノート・Breaking Changesを調査してください。
```

**Task 2（dependabot-security-analyzer）への指示文:**
```
更新ライブラリ: <ライブラリ名> <旧バージョン> → <新バージョン>
CVE・セキュリティ脆弱性の有無と深刻度を調査してください。
```

**Task 3（dependabot-impact-analyzer）への指示文:**
```
更新ライブラリ: <ライブラリ名> <旧バージョン> → <新バージョン>
このリポジトリのコードベースへの影響範囲を調査してください。
```

### ステップ4: 結果統合・レビュー投稿

3つのサブエージェントの結果をまとめ、`mcp__github_comment__update_claude_comment` で最終レビューを投稿する。

## 最終判断の基準

| 判断 | 条件 | アクション |
|------|------|------------|
| 🔒 緊急マージ推奨 | Critical/High セキュリティ修正 | 即座にマージ、24時間以内デプロイ |
| ✅ 即座にマージ可能 | Breaking Changes なし/影響なし | 承認してマージ |
| ⚠️ 修正後にマージ | Breaking Changes がコードに影響あり | 修正後にマージ |
| ⚠️ マージ可能だが要対応 | 非推奨API使用（動作はする） | マージ後に別PRで対応 |