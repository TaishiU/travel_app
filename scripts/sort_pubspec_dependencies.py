import yaml
import sys
import os

# None を null ではなく空文字列として出力するカスタム Representer
# pubspec.yaml の慣習に合わせて `package_name:` の形式を保持する
class _PubspecDumper(yaml.SafeDumper):
    pass

def _represent_none(dumper, _):
    return dumper.represent_scalar('tag:yaml.org,2002:null', '')

_PubspecDumper.add_representer(type(None), _represent_none)

def sort_dependencies(file_path: str) -> None:
    """
    pubspec.yamlファイル内のdependenciesとdev_dependenciesセクションをアルファベット順にソートします。

    Args:
        file_path (str): pubspec.yamlファイルのパス。
    """
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            pubspec = yaml.safe_load(f)

        if pubspec:
            # dependenciesセクションをソート
            if 'dependencies' in pubspec and isinstance(pubspec['dependencies'], dict):
                sorted_deps = dict(sorted(pubspec['dependencies'].items(), key=lambda item: item[0]))
                pubspec['dependencies'] = sorted_deps

            # dev_dependenciesセクションをソート
            if 'dev_dependencies' in pubspec and isinstance(pubspec['dev_dependencies'], dict):
                sorted_dev_deps = dict(sorted(pubspec['dev_dependencies'].items(), key=lambda item: item[0]))
                pubspec['dev_dependencies'] = sorted_dev_deps

            with open(file_path, 'w', encoding='utf-8') as f:
                yaml.dump(pubspec, f, sort_keys=False, default_flow_style=False, indent=2, Dumper=_PubspecDumper)
            print(f"'{file_path}' のdependenciesとdev_dependenciesがソートされました。")
        else:
            print(f"エラー: '{file_path}' が空であるか、有効なYAMLファイルではありません。", file=sys.stderr)

    except FileNotFoundError:
        print(f"エラー: ファイル '{file_path}' が見つかりません。", file=sys.stderr)
        sys.exit(1)
    except yaml.YAMLError as e:
        print(f"エラー: YAMLファイルのパース中に問題が発生しました - {e}", file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        print(f"予期せぬエラーが発生しました: {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == '__main__':
    if len(sys.argv) != 2:
        print("使用法: python sort_pubspec_dependencies.py <pubspec_file_path>", file=sys.stderr)
        sys.exit(1)

    pubspec_path = sys.argv[1]
    
    # PyYAMLがインストールされているかチェック
    try:
        import yaml # この行は既に上で実行済みだが、念のため
    except ImportError:
        print("エラー: 'PyYAML' ライブラリがインストールされていません。", file=sys.stderr)
        print("以下のコマンドでインストールしてください: pip install PyYAML", file=sys.stderr)
        sys.exit(1)

    sort_dependencies(pubspec_path)
