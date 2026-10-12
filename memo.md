flowchart LR
%% プレゼンテーション層：ViewModel を導入
subgraph P["1. プレゼンテーション層"]
View --> Notifier
subgraph VM["ViewModel"]
Notifier --> UC_s["UseCase\n（画面専用）"]
end
end

    subgraph D["2. ドメイン層"]
        Entity
        Interface
        UC_c["UseCase\n（複数画面共有用）"]
    end

    subgraph DA["3. データ層"]
        Repository --> Service
    end

    %% Web API をデータ層の外に配置
    WebAPI["Web API"]

    %% 層間の矢印を削除（P --> D などを削除）

    %% 内部の依存関係
    Notifier -.-> UC_c

    UC_s --> Entity
    UC_s --> Interface
    UC_c --> Entity
    UC_c --> Interface

    Repository -->|implements| Interface
    Service --> WebAPI