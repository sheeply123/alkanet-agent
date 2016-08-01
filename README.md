alkanet-agent
===

トレースログの取得やAlkanetServerへのアップロードを行います

## 環境
* ruby 2.2以上
* bundler
* alk-logcat、alk-analyze2

## パッケージのインストール
```bash
$ bundle install --path vendor/bundle
```

## パッケージの作成
```bash
$ bundle exec rake build
```

## 作成したパッケージのインストール
パッケージの作成後に実行する。  
`x.x.x`は適宜正しいバージョンに置き換える。

```bash
$ cd pkg
$ gem install -b alkanet-agent-x.x.x.gem
```

## コマンドの使い方
`--url`オプションで接続先のAlkanetServerを指定する。

例:

```bash
$ alkanet-agent --url http://localhost:3000
```

`--analyze`オプションをつけると、ログ取得後に解析を行う。
