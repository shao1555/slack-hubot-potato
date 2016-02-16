phantom = require 'phantom'
cheerio = require 'cheerio'

# tenki.jp の天気画像を抜いてくるnuitekuru
module.exports = (robot) ->
  robot.hear /tenki/i, (res) ->
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
                # TODO: slack にアップロード
                page.render('tmp/tenki.png');
                phantom.exit();
