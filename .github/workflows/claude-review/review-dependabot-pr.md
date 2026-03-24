---
allowed-tools: Bash(gh pr view:*),Bash(gh pr diff:*),WebFetch,WebSearch
description: Dependabot PRをバージョン差分・影響範囲・セキュリティの3観点からレビュー
---

# Dependabot PR レビュー

## レビューの流れ

### ステップ1: CLAUDE.md の読み込み
プロジェクトルールと設計方針を確認し、全サブエージェントに共有。

### ステップ2: PR情報の取得
`gh pr view --json number,title,body,author` で Dependabot PR であることを確認。

### ステップ3: 3つのサブエージェントによる並列レビュー

1. **dependabot-version-analyzer**: CHANGELOG/リリースノート調査、Breaking Changes特定
2. **dependabot-security-analyzer**: CVE/脆弱性の深刻度評価、緊急度判定
3. **dependabot-impact-analyzer**: コードベースへの影響分析、修正箇所特定

### ステップ4: 結果統合とコメント投稿

## 最終判断の4パターン

| 判断 | 条件 | アクション |
|------|------|------------|
| 🔒 緊急マージ推奨 | Critical/High セキュリティ修正 | 即座にマージ、24時間以内デプロイ |
| ✅ 即座にマージ可能 | Breaking Changes なし/影響なし | 承認してマージ |
| ⚠️ 修正後にマージ | Breaking Changes が影響あり | コード修正後にマージ |
| ⚠️ マージ可能だが要対応 | 非推奨API使用（動作はする） | マージ後に別PRで対応 |

## 注意事項

- **インラインコメント**: 依存関係ファイルのみの変更なので通常は不要
- **エラー時**: changelog未発見、影響判断困難な場合は人間のレビューを促す

主な省略箇所：
- 詳細なコメントテンプレート（60行以上あったMarkdown例）
- 各ケースの詳細な説明文
- レビューのポイント4項目の詳細説明