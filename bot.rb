require 'discordrb'
require 'date'
require 'nokogiri'
require 'open-uri'

token = 'token'
client_id ='clientid'
bot = Discordrb::Commands::CommandBot.new token: token,client_id: client_id,prefix: "/"

i = 1
output = nil
x = 0
hash = {}
kakopts = 0
sabunpts = 0
outpts= 0
errer = false

help = ">>> ボーダー監視bot 0.2
 概要\n
  15分ごとにaidoru.infoのランキングから\n
  特定のユーザーのpt変動をお知らせするbot\n
 使い方\n
  /start [監視対象]\n
   監視開始\n
  /end
   監視終了\n
    監視対象は大文字小文字などに注意してください\n
    間違っていると動きません\n
   dev:@ftb_anz"
bot.command :help do |helpevent|
  helpevent.send_message help
end
bot.command :start do |event,inname|
  if inname != nil then
    if i == 1 # i = 1 →監視中 0 →監視していない
      i = 0
      while i == 0
        now = DateTime.now
        nowmin = "#{now.minute}"
        if nowmin == "4" or nowmin == "19" or nowmin == "34" or nowmin == "49" then #更新時間に計算
          url = 'https://aidoru.info/event/viewrank'
          html = open(url).read
          begin
          doc = Nokogiri::HTML.parse(html)
          rescue
             puts "取得エラー"
             errer = true
             sleep 10
             retry
          end
          doc.xpath("/html/body/div/div[2]/div/table/tbody").each do |node|
            node.xpath("/html/body/div/div[2]/div/table/tbody/tr/td[3]").each do |bname| #名前取得
              bpts = node.xpath("/html/body/div/div[2]/div/table/tbody/tr/td[2]")[x].inner_html.to_s.strip #pt取得
              apts = bpts.gsub(/\(.*/m, "").gsub!(/\,+/, "").to_i #bptsは ポイント (+差分) 形式なので差分部分、カンマを削除、intにしてaptsに代入
              x += 1
              aname = bname.inner_html.to_s.strip #整形
              hash[aname] = apts #名前とptをHashMapに入れる
              outpts = hash[inname] #入力された名前のptsをHashMapから取ってきてoutptsに代入
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
        if errer == true
          errer = false
          sleep 50
        else
        sleep 60
        end
      end
    else
      event.send_message("既に監視しています")
    end
  else
    event.send_message("対象の名前を入力してください")
  end
end

bot.command :end do |endevent|
  if i == 0 then
    i = 1
    output = nil
    x = 0
    hash = {}
    kakopts = 0
    sabunpts = 0
    outpts= 0
    errer = false
    inname = nil
    endevent.send_message("監視を終了しました")
    else endevent.send_message("監視していません")
  end
end
bot.run
