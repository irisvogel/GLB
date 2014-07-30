#encoding: utf-8
class HomeController < ApplicationController
  before_filter :authenticate_user!
  def index
    params[:search] = nil if params[:search] and params[:search].strip == "" 
    @page = params[:page] || 0
    all_entries = (params[:search] ? Entry.search(params[:search]) : Entry).order("romaji_order")
    @count = all_entries.count
    @entries = all_entries.page(@page)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @entries }
    end
  end

  LEMMATA = {"Heilsfiguren"=>[["1222:5", 8431, "仏", "butsu"], ["1295:2", 8879, "菩薩", "bosatsu"], ["1124:5", 7811, "如来", "nyorai"], ["28:1", 203, "阿羅漢", "arakan"], ["1374:5", 9302, "明王", "myōō"], ["1020:1", 7054, "天", "ten"], ["744:4", 5157, "聖人", "shōnin"], ["1185:3", 8180, "聖", "hijiri"]], "Ontologie / Weltbild"=>[["", "", "六道", "rokudō"], ["491:3", 3528, "三世", "sanze"], ["468:2", 3412, "三界", "sangai"], ["522:3", 3695, "色界", "shikikai"], ["1394:1", 9448, "無色界", "mushikikai"], ["1395:5", 9456, "無常", "mujō"], ["65:3", 500, "因果経", "inga"], ["125:7", 928, "縁起", "engi"], ["687:1", 4718, "性", "shō"]], "Philosophie / Epistemologie"=>[["51:3", 393, "一如", "ichinyo"], ["801:2", 5552, "真如", "shinnyo"], ["1244:5", 8542, "不二", "funi"], ["279:6", 2077, "空", "kū"], ["1388:4", 9415, "無", "mu"], ["1174:2", 8132, "般若", "hannya"], ["838:5", 5809, "禅", "zen"], ["687:6", 4723, "定", "jō"], ["86:5", 604, "有情", "ujō"], ["", "", "無情", "mujō"], ["668:6", 4569, "衆生", "shujō"], ["519:7", 3689, "色", "shiki"], ["871:2", 6013, "相", "sō"], ["254:8", 1877, "行", "gyō"], ["20:1", 150, "識", "shiki"], ["871:3", 6014, "想", "sō"], ["392:4", 2884, "五慍", "goun, goon"], ["236:4", "", "機", "ki"], ["237:1", 1721, "義", "gi"]], "Soteriologie"=>[["1037:2", 7167, "道", "dō"], ["689:1", 4724, "乗", "jō"], ["1259:6", 8658, "法", "hō"], ["254:3", 1872, "教", "kyō"], ["254:8", 1877, "行", "gyō"], ["660:5", 4515, "修行", "shugyō"], ["295:4", 2199, "功徳", "kudoku"], ["1397:8", 9483, "無明", "mumyō"], ["1336:2", 9098, "煩悩", "bonnō"], ["1340:3", 9104, "凡夫", "bonpu"], [">236:3", "", "器", "ki"], ["474:6", 3444, "懺悔", "sange, zange"], ["359:11", 2678, "悟", "go, satori"], ["177:4", 1267, "覚", "kaku, satori"], ["687: 3", "", "証", "shō"], ["747:5", 5189, "成仏", "jōbutsu"], ["1228:1", 8465, "仏性", "busshō"], ["1125:4", 7815, "如来蔵", "nyoraizō"], ["1132:3", 7858, "涅槃", "nehan"], ["324:9", 2411, "解脱", "gedatsu"]], "Institutionen, Ämter, Titel"=>[["513:2", 3649, "寺院", "jiin"], ["", "", "山号", "sangō"], ["1326:6", 9044, "本山", "honzan"], ["405:4", 2971, "五山", "gozan"], ["", "", "末寺", "matsuji"], ["", "", "僧", "sō"], ["22:8", 173, "尼", "ama, ni"], ["474:4", 3442, "山家", "sange"], ["873:3", 6021, "僧位", "sōi"], ["848:4", 5866, "禅師", "zenji"], ["886:1", 6119, "僧職", "sōshoku"], ["1255:9", 8630, "別当", "bettō"], ["1420:2", 9637, "山伏", "yamabushi"], ["888:6", 6126, "僧都", "sōzu"], ["", "", "住職", "jūshoku"], ["987:2", 6818, "知事", "chishiki"], ["1453:5", 9848, "律師", "risshi"], ["", "", "論師", "ronshi"], ["", "", "三蔵", "sanzō"], ["", "", "権僧正", "gonsōjō"]], "Lehre und Texte"=>[["254:4", 1873, "経", "kyō"], ["", "", "偽経", "gikyō"], ["1506:3", 10201, "論", "ron"], ["1449:9", 9843, "律", "ritsu"], ["175:3", 1245, "戒律", "kairitsu"], ["", "", "因果経", "ingakyō"], ["1384:1", 9380, "法華経", "hokkekyō"], ["317:2", 2362, "華厳経", "kegonkyō"], ["1175:1", 8135, "般若経", "hannyakyō"], ["1133:2", 7860, "涅槃経", "nehangyō"], ["", "", "伝", "den"], ["379:3", 2804, "高僧伝", "kōsōden"], ["431:3", 3132, "語録", "goroku"], ["1361:5", 9237, "曼荼羅", "mandara"]], "Schulen und Richtungen"=>[["928:3", 6436, "大乗", "daijō"], ["1421:7", 9650, "唯識", "yuishiki"], ["1026:6", 7104, "天台", "tendai"], ["321:1", 2383, "華厳", "kegon"], ["737:1", 5104, "浄土", "jōdo"], ["784:4", 5440, "真言", "shingon"], ["850:3", 5878, "禅", "zen"], ["510:2", 3633, "三論", "sanron"], ["1453:7", 9850, "律宗", "risshū"], ["719:1", 4963, "小乗", "shōjō"]], "Rituale, Meditation"=>[["1261:8", 8671, "法会", "hōe"], ["372:7", 2748, "講式", "kōshiki"], ["463:5", 3371, "座禅", "zazen"], ["518:7", 3682, "止観", "shikan"], ["28:2", 204, "荒行", "aragyō"]]}
  def hundredlemma
    @lemmata = LEMMATA
    respond_to do |format|
      format.html # hundredlemma.html.erb
      format.json { render json: @lemmata }
    end
  end
end
