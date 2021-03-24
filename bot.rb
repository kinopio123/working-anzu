require 'discordrb'
require 'date'
require 'nokogiri'
require 'open-uri'

token = 'とーくん'
client_id ='あいでー'
bot = Discordrb::Commands::CommandBot.new token: token,client_id: client_id,prefix: "/"

i = 1
output = ""
x = 0
hash = {}
kakopts = 0
sabunpts = 0
outpts= 0
y = 0

help = ">>> ボーダー監視bot 0.1 作:きのぴお\n
 概要\n
  15分ごとにaidoru.infoのランキングから\n
  特定のユーザーのpt変動をお知らせするbot\n
 使い方\n
  /start [監視対象]\n
   監視開始\n
  /end
   監視終了\n
    監視対象は大文字小文字などに注意してください\n
    間違っていると動きません"
bot.command :help do |ev|
  ev.send_message help
end
bot.command :start do |event,inname|
  if inname != nil then
    if i == 1
      i = 0
      while i == 0
        now = DateTime.now
        nowmin = "#{now.minute}"
        if nowmin == "4" or nowmin == "19" or nowmin == "34" or nowmin == "49" then
          #更新時間に計算
          url = 'https://aidoru.info/event/viewrank'
          html = open(url).read
          doc = Nokogiri::HTML.parse(html)
          doc.xpath("/html/body/div/div[2]/div/table/tbody").each do |node|
            node.xpath("/html/body/div/div[2]/div/table/tbody/tr/td[3]").each do |bname| #名前取得
              bpts = node.xpath("/html/body/div/div[2]/div/table/tbody/tr/td[2]")[x].inner_html.to_s.strip #pt取得
              apts = bpts.gsub(/\(.*/m, "").gsub!(/\,+/, "").to_i #差分削除
              x += 1
              aname = bname.inner_html.to_s.strip #整形
              hash[aname] = apts #名前とptを紐付け
              outpts = hash[inname]
            end
          end
          sabunpts = outpts - kakopts
          output = ("#{inname}" + " さんの現在のpt:" + "#{outpts}" + "(" + "#{sabunpts}" + ")")
          event.send_message output
          kakopts = outpts
          x = 0
        else
          #何もしない
        end
        sleep 60
      end
    else
      event.send_message("既に監視しています")
    end
  else
    event.send_message("対象の名前を入力してください")
  end
end

bot.command :end do |a|
  if i == 0 then
    i = 1
    a.send_message("監視を終了しました")
  else a.send_message("監視していません")
  end
end
bot.run
