phantom = require 'phantom'
cheerio = require 'cheerio'
temp = require 'temp'
fs = require 'fs'
slackClient = require 'slack-client'

module.exports = (robot) ->
  robot.hear /^image (.+)/i, (res) ->
    temp.track()
    phantom.create().then (ph) ->
      ph.createPage().then (page) ->
        page.setting('userAgent', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/50.0.2650.0 Safari/537.36').then ->
          page.open("https://www.google.co.jp/search?q=#{encodeURIComponent res.match[1]}&tbm=isch").then (status) ->
            if status == 'success'
              page.evaluate(() ->
                element = document.querySelector('div#isr_mc div.ivg-i a')
                ret = undefined
                if element
                  matches = element.getAttribute('href').match(/imgurl=(.*?)&/)
                  if matches != null
                    ret = decodeURIComponent(decodeURIComponent(matches[1]))
                ret
              ).then (url) ->
                if url != null
                  res.send url
                else
                  res.send('みつかりませんでした')
                ph.exit()
