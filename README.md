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

## alkanet-toolsの準備
rbenvでrubyのバージョンを1.9.3-p484にした状態で、
alk-logcatやalk-analyze2をインストールしておく。
alk-logcatはsudo経由で使えるように設定しておく。

```bash
$ which alk-logcat
/usr/local/rbenv/shims/alk-logcat
$ sudo visudo
```

起動するユーザ名を指定する(ここではalkanetserver)
```
alkanetserver ALL=(ALL) NOPASSWD: /usr/local/rbenv/shims/alk-logcat
```


## コマンドの使い方
`--url`オプションで接続先のAlkanetServerを指定する。

例:

```bash
$ alkanet-agent --url http://localhost:3000
```

`--analyze`オプションをつけると、ログ取得後に解析を行う(alk-analyze2がある場合のみ)。

Alkanet10を使用する場合は`--addr`オプションでアドレスを指定する。

例:
```bash
$ alkanet-agent --addr 0x93440000
```
