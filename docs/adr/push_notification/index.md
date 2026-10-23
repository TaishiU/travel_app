# Push Notification ADR Index

## 概要

| Topic                                  | Path                                                    |
|----------------------------------------|---------------------------------------------------------|
| デザインドック（タスク分割・全体設計） | `docs/adr/push_notification/design_doc.md`              |
| Push通知カテゴリ定義                   | `docs/adr/push_notification/notification_categories.md` |

## Phase 1: 調査・設計

| Topic                           | Path                                                                 |
|---------------------------------|----------------------------------------------------------------------|
| BRAZE-001 Braze連携の現状調査   | `docs/adr/push_notification/phase1_research_and_design/braze_001.md` |
| BRAZE-002 通知カテゴリの確定    | `docs/adr/push_notification/phase1_research_and_design/braze_002.md` |
| BRAZE-003 データスキーマ設計    | `docs/adr/push_notification/phase1_research_and_design/braze_003.md` |
| BRAZE-004 Deep Linkスキーマ設計 | `docs/adr/push_notification/phase1_research_and_design/braze_004.md` |
| BRAZE-005 権限・同意フロー設計  | `docs/adr/push_notification/phase1_research_and_design/braze_005.md` |

## Phase 2: 基盤実装

| Topic                                        | Path                                                                           |
|----------------------------------------------|--------------------------------------------------------------------------------|
| Phase 2 概要（スコープ・方針・残課題）       | `docs/adr/push_notification/phase2_infrastructure_implementation/overview.md`  |
| BRAZE-010 Braze SDK 導入                     | `docs/adr/push_notification/phase2_infrastructure_implementation/braze_010.md` |
| BRAZE-011 環境別設定（`--dart-define` 注入） | `docs/adr/push_notification/phase2_infrastructure_implementation/braze_011.md` |
| BRAZE-012 Push権限管理                       | `docs/adr/push_notification/phase2_infrastructure_implementation/braze_012.md` |
| BRAZE-013 Pushトークン登録                   | `docs/adr/push_notification/phase2_infrastructure_implementation/braze_013.md` |
| BRAZE-014 ユーザー識別                       | `docs/adr/push_notification/phase2_infrastructure_implementation/braze_014.md` |
| BRAZE-015 属性送信Repository                 | `docs/adr/push_notification/phase2_infrastructure_implementation/braze_015.md` |
| BRAZE-016 カスタムイベント送信（縮小版）      | `docs/adr/push_notification/phase2_infrastructure_implementation/braze_016.md` |