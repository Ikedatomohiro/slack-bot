import os

# 読み込みファイル名と書き込みディレクトリを設定
input_file = 'output.md'  # 入力ファイル名
output_dir = 'output_files'  # 出力ディレクトリ

# 出力ディレクトリが存在しない場合は作成
if not os.path.exists(output_dir):
    os.makedirs(output_dir)

# ファイルを読み込んで、SlackURLのブロックごとに分割
with open(input_file, 'r', encoding='utf-8') as file:
    data = file.read()

# "SlackURL:"で区切ってリストに変換
blocks = data.split('SlackURL:')[1:]  # 最初の要素は空なのでスキップ
blocks = ['SlackURL:' + block.strip() for block in blocks]  # 元の"SlackURL:"を付け直す

# 100個のブロックごとにファイルに分割して書き込み
for i in range(0, len(blocks), 100):
    chunk = blocks[i:i + 100]  # 100個のブロックを取得
    output_file = os.path.join(output_dir, f'output_{i // 100 + 1}.txt')

    # 出力ファイルに書き込み
    with open(output_file, 'w', encoding='utf-8') as out_file:
        out_file.write('\n\n'.join(chunk))  # 各ブロックを改行で区切って書き込み

print("ファイルが正常に分割されました。")
