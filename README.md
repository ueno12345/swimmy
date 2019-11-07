# swimmy
swimmyとは，B4新人課題で作成した各々のSlackBotを1つにまとめたものである．本プロジェクト名は，絵本作家レオ・レオニ作の絵本「swimmy」に由来し，各々のプログラムをまとめた1つの成果物を表している．

# Description
## How it works
本プログラムは，SlackBot プログラムである．チャットツールである [Slack](https://slack.com/) 上で発言された内容に応じた処理を行う．Slack 上での発言を契機に SlackBot プログラムが処理し，処理結果を Slack に発言するまでの処理の流れを以下に示す．

![発言を契機に処理の流れ SlackBot プログラムが処理し，処理結果を Slack に発言するまでの処理の流れ](./fig/fig.png)

1. クライアントは Slack サーバに POST する．
2. Slack サーバは Outgoing WebHooks を用いて SlackBot サーバに POST する．
3. SlackBot サーバは POST された発言内容に応じた処理を行う．
4. SlackBot サーバは処理結果をレスポンスとして返す．
5. Slack サーバはクライアントに結果を送信する．

## Function
本プログラムは以下に示す機能を提供する．

- ユーザが"「〇〇」と言って"と発言すると，SlackBotが"〇〇"と発言する機能
- 移動手段，出発地点，および到着地点から以下の情報を発言する機能 
  - 出発地点から到着地点までの距離
  - 出発地点から到着地点までの移動にかかる時間
  - 出発地点から到着地点までの経路の詳細を示した Google Map へのリンク
- 直近60分後の降水強度予測を発言する機能
- 設定された GitHub リポジトリに issue を作成，または issue の一覧を発言する機能
- 入力された飲食店の情報を発言する機能
- Slackに写真がアップロードされた際，写真をGoogle Photonにもアップロードする機能
- いいねが100をqiitaの記事をお知らせする機能
- ノムニチの記事を書く人を選ぶ機能
- 投票を作成する機能
- 上記のどの機能にも該当しない場合に使用方法を発言する機能


# Settings
- このリポジトリを clone する．

  ```
  $ git clone https://github.com/nomlab/swimmy.git
  ```

- gem のインストール
  - 以下のコマンドを実行し，gemをインストール
 
   ```
   $ gem install bundler
   $ bundle install --path vendor/bundle
   ```

- Outgoing WebHooks の設定
  - [Custome Integrations](https://nomlab.slack.com/apps/manage/custom-integrations) へアクセスし，「Outgoing WebHooks」をクリック
  - 「Add Configuration」から，新たな Outgoing WebHook を追加
  - 「Add Outgoing WebHooks integration」をクリック
  - Outgoing WebHook に関して以下を設定
    - Channel: 発言を監視する channel
    - Trigger Word(s): WebHook が動作する契機となる単語
    - URL(s): WebHook が動作した際にPOSTを行うURL
  - 必要であれば， Customize Name もしくは Customize Icon を設定
  
- APIキーの取得
  - Google Maps API の API キー取得
    - [Google Maps API](https://developers.google.com/maps/web/) へアクセスし，「キーの取得」をクリックする．
    - 「Select or create project」をクリックする．
    - 「Create a new project」をクリックし，プロジェクト名を付ける．
    - 「NEXT」をクリックすると，Google Maps APIキーが作成される．
    
  - Google Places API の API キー取得
    - [Google Place API](https://developers.google.com/places/web-service)へアクセスし， 「キーの取得」をクリックする．
    - 「Create a new project」を選択し，プロジェクト名を決定する．
    - 「Next」をクリックすると API キーが生成される．

  - Yahoo! JAPAN デベロッパーネットワーク Web API の Client ID の取得
    - [Yahoo! JAPAN デベロッパーネットワーク](https://developer.yahoo.co.jp/)にアクセスする．
    - ページ上部の「機能」をクリックし，「アプリケーションの開発」をクリックする．
    - 本プログラムの使用者の Yahoo!JAPAN アカウントにログインする．
    - 「新しいアプリケーションの開発」をクリックする．
    - アプリケーション情報を入力し，「ガイドラインに同意する」にチェックを入れ，「確認」をクリックする．
    - Client ID を取得する．なお，Client ID を API キーとして用いる．

- APIキーの設定
  - 以下のコマンドを実行し，settings.yml.sample を settings.yml に変更

    ```
    $ cp settings.yml.sample settings.yml
    ```
    取得したAPIキーをファイルに記述する．

- sheetqの設定
  https://github.com/nomlab/sheetqにしたがって設定を行う．

- systemdの設定
  - 以下のコマンドを実行する．
    ```
	# root ユーザ
    $ cp systemd_conf/swimmy.service /etc/systemd/system/swimmy.service
    $ cp systemd_conf/swimmy_env /etc/default/swimmy_env

	# 非 root ユーザ
	$ cp systemd_conf/user/swimmy.service ~/.config/systemd/user/swimmy.service
    $ cp systemd_conf/swimmy_env ~/.config/systemd/user/swimmy_env
    ```

  - コピーした`swimmy.service`について，以下の項目を環境に合わせて設定する．
    ```
    5 WorkingDirectory=/home/nomlab/swimmy
    6 ExecStart=/bin/sh -c 'exec /home/nomlab/swimmy/exe/swimmy >> /var/log/swimmy.log 2>&1'
    7 User=nomlab
    8 Group=nomlab
    ```

  - コピーした`swimmy_env`について，PATHを環境に合わせて設定する．


# Run
以下のコマンドを実行することでswimmyを起動できる．
```
# root ユーザ
$ sudo systemctl start swimmy

# 非 root ユーザ
$ systemctl --user start swimmy
```

また，以下のコマンドを実行することでswimmyを停止できる．
```
# root ユーザ
$ sudo systemctl stop swimmy

# 非 root ユーザ
$ systemctl --user stop swimmy
```

