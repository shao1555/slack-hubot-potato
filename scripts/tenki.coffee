phantom = require 'phantom'
cheerio = require 'cheerio'
temp = require 'temp'
fs = require 'fs'
slackClient = require 'slack-client'

# tenki.jp の天気画像を抜いてくる
module.exports = (robot) ->
  robot.hear /^tenki/i, (res) ->
    temp.track()
    phantom.create().then (ph) ->
      ph.createPage().then (page) ->
        # TODO: 地点検索
        page.open('http://www.tenki.jp/forecast/3/16/4410/13101-daily.html').then (status) ->
          if status == 'success'
            page.evaluate(() ->
              document.getElementById('townWeatherBox').getBoundingClientRect()
            ).then (rect) ->
              page.property('clipRect',
                top: rect.top,
                left: rect.left,
                width: rect.width,
                height: rect.height
              ).then ->
                screenShotFile = temp.path(suffix: '.png')
                res.send(screenShotFile)
                page.render(screenShotFile).then ->
                  # TODO: slack にアップロード
                  slackWebClient = new slackClient.WebClient(process.env.HUBOT_SLACK_TOKEN)
                  slackWebClient.files.upload {file: fs.createReadStream(screenShotFile), channels: "##{res.envelope.room}"}, (error, info) ->
                    if error != undefined
                      console.log(error)
                      res.send('アップロードに失敗しました')
                    temp.cleanupSync()
                    ph.exit()
