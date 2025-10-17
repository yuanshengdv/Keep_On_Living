require 'open-uri'
require 'openssl'

module DistantVoices::Keep_On_Living

  # 模型修改监听程序
  class ModelChangeObserver < Sketchup::ModelObserver
    def initialize(notifier)
      @notifier = notifier
      # puts "模型修改监听程序已启动"
    end

    # 当模型修改时触发
    def onChangeEntity(model, entity)
      @notifier.record_model_change
    end
  end

  # 后台监听程序
  class BackgroundNotifier
    def initialize
      @start_time = Time.new.to_i
      @last_reminders = {
        kegel: 0,
        stand: 0,
        drink: 0,
        rest: 0,
        model_change: 0   # 记录模型最后一次修改时间
      }
      @timer_id = nil
      # 注册模型观察者
      model = Sketchup.active_model
      @model_observer = ModelChangeObserver.new(self)
      model.add_observer(@model_observer)
    end

    # 记录模型修改时间
    def record_model_change
      current_minutes = ((Time.now.to_i - @start_time) / 60).floor
      @last_reminders[:model_change] = current_minutes
    end

    # 开始监听
    def start
      # 每分钟检查一次（60秒）
      @timer_id = UI.start_timer(60, true) {
        check_and_notify
      }
    end

    # 停止监听
    def stop
      if @timer_id
        UI.stop_timer(@timer_id)
        @timer_id = nil
      end
    end

    # 死亡提示界面
    def death_notice(elapsed_minutes)
      death_notice = UI::HtmlDialog.new({
          dialog_title: "生命检测",
          preferences_key: "com.DistantVoices.keep_on_living.death",
          scrollable: true,
          style: UI::HtmlDialog::STYLE_DIALOG,
          width: 600,
          height: 700,
          resizable: false
        })

        death_notice.set_file(File.join(__dir__, 'html', 'death.html'))
        death_notice.show

        death_notice.add_action_callback("living") do |action_context|
          death_notice.close
          @last_reminders[:model_change] = elapsed_minutes  #还没死，重置计时器
        end

        death_notice.add_action_callback("dead") do |action_context|
          death_notice.close
          # @last_reminders[:model_change] = elapsed_minutes  #人已经死了，就不用每隔6小时提醒一次了
        end
    end

    # 检查并提醒
    def check_and_notify
      current_time = Time.new.to_i
      elapsed_minutes = ((current_time - @start_time) / 60).floor

      # 模型 6 小时未修改
      if elapsed_minutes - @last_reminders[:model_change] >= 360 && elapsed_minutes - @last_reminders[:model_change] < 361
        death_notice(elapsed_minutes)
        return
      end

      # 按优先级检查提醒（优先时间长的）
      if elapsed_minutes - @last_reminders[:rest] >= 180
        UI.messagebox("活是公司的，命是自己的，请记得休息一下。")
        @last_reminders[:rest] = elapsed_minutes
        return
      end

      if elapsed_minutes - @last_reminders[:drink] >= 120
        UI.messagebox("你好像很久没喝水了呢，长期饮水不足可能增加泌尿系统结石的风险。")
        @last_reminders[:drink] = elapsed_minutes
        return
      end

      if elapsed_minutes - @last_reminders[:stand] >= 90
        UI.messagebox("已经很久没有站起来了，记得活动一下腰颈哦，希望你能活到领养老金。")
        @last_reminders[:stand] = elapsed_minutes
        return
      end

      if elapsed_minutes - @last_reminders[:kegel] >= 30
        UI.messagebox("已经工作了30分钟呢，请开始提肛，提肛运动可以帮助预防痔疮等肛周疾病。用力收缩前阴和肛门，稍微憋一会儿，然后放松，接着再往上提，一提一松，反复进行。")
        @last_reminders[:kegel] = elapsed_minutes
      end
    end
  end

  #来点笑话
  def self.jokes_windows
    joke = @jokes_text.sample

    # 将笑话文本作为URL参数传递
    joke_html_path = File.join(__dir__, 'html', "joke.html")
    encoded_joke = URI.encode_www_form_component(joke)
    full_url = "file:///#{joke_html_path}?joke=#{encoded_joke}"

    joke_html = UI::HtmlDialog.new({
      dialog_title: "人生哲理",
      preferences_key: "com.DistantVoices.keep_on_living.joke",
      scrollable: false,
      width: 450,
      height: 250,
      style: UI::HtmlDialog::STYLE_DIALOG
    })

    # 显示 HTML 页面
    joke_html.set_url(full_url)
    joke_html.show

  end

  # 雨后小故事
  def self.storiette_windows
    storiette = @storiette_text.first

    # 将雨后小故事文本作为URL参数传递
    storiette_html_path = File.join(__dir__, 'html', "storiette.html")
    encoded_storiette = URI.encode_www_form_component(storiette)
    full_url = "file:///#{storiette_html_path}?storiette=#{encoded_storiette}"

    storiette_html = UI::HtmlDialog.new({
      dialog_title: "雨后小故事",
      preferences_key: "com.DistantVoices.keep_on_living.storiette",
      scrollable: false,
      width: 1200,
      height: 450,
      style: UI::HtmlDialog::STYLE_DIALOG
    })

    # 显示 HTML 页面
    storiette_html.set_url(full_url)
    storiette_html.show
  end

  # 启动后台监听程序
  def self.start_background_listener
    # 防止重复启动
    return if @notifier

    unless @notifier
      @notifier = BackgroundNotifier.new
      @notifier.start
      # puts "启动后台监听程序"
    end
  end

  # 停止后台监听程序
  def self.stop_background_listener
    if @notifier
      @notifier.stop
      @notifier = nil
      # puts "停止后台监听程序"
    end
  end

  # 切换按钮背景色
  def self.toggle_button_background
    @button_state = !@button_state

    if @button_state
      start_background_listener unless @notifier
    else
      stop_background_listener
    end
  end

    #关于界面
  def self.about
    # 创建一个新的 HTML 对话框
    dlg = UI::HtmlDialog.new({
                               :dialog_title    => '作者信息',
                               :preferences_key => "com.DistantVoices.Keep_On_Living.about",
                               :scrollable      => false,
                               :resizable       => false,
                               :width           => 420,
                               :height          => 480,
                               :style           => UI::HtmlDialog::STYLE_DIALOG
                             })

    # 设置 HTML 文件路径
    dlg.set_file(File.join(__dir__, 'html', 'about.html'))
    # 绑定按钮的点击事件回调
    dlg.add_action_callback("onYes") do |action_context|
      dlg.close
    end
    dlg.add_action_callback("onNo") do |action_context|
      dlg.close
    end
    dlg.add_action_callback("openBilibili") do |action_context|
      UI.openURL("https://b23.tv/pO2xctz")
    end
    dlg.add_action_callback("openGithub") do |action_context|
      UI.openURL("https://github.com/yuanshengdv/Keep_On_Living")
    end
    # 显示对话框
    dlg.show
  end

  # 更新笑话和雨后小故事文本
  def self.update
    jokes_file = File.join(File.dirname(__FILE__), "jokes.txt")
    storiette_file = File.join(File.dirname(__FILE__), "storiette.txt")
    joke_github_url = "https://raw.githubusercontent.com/yuanshengdv/Keep_On_Living/main/Keep_On_Living/jokes.txt"
    storiette_github_url = "https://raw.githubusercontent.com/yuanshengdv/Keep_On_Living/main/Keep_On_Living/storiette.txt"

    # 更新 jokes.txt
    begin
      temp_file = File.join(File.dirname(__FILE__), "jokes_temp.txt")
      URI.open(joke_github_url,
               ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE,
               read_timeout: 3,
               open_timeout: 3) do |remote_file|
        File.open(temp_file, 'wb') do |file|
          file.write(remote_file.read)
        end
      end

      File.rename(temp_file, jokes_file)
      puts "笑话文本更新成功"
    rescue => e
      File.delete(temp_file) if File.exist?(temp_file)
      puts "笑话文本下载失败: #{e.message}"
    end

    # 更新 storiette.txt
    begin
      temp_file = File.join(File.dirname(__FILE__), "storiette_temp.txt")
      URI.open(storiette_github_url,
               ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE,
               read_timeout: 3,
               open_timeout: 3) do |remote_file|
        File.open(temp_file, 'wb') do |file|
          file.write(remote_file.read)
        end
      end

      File.rename(temp_file, storiette_file)
      puts "雨后小故事文本更新成功"
    rescue => e
      File.delete(temp_file) if File.exist?(temp_file)
      puts "雨后小故事文本下载失败: #{e.message}"
    end
  end

  #小说阅读器
  def self.reader
    reader_html_path = File.join(__dir__, 'html', "reader.html")
    reader_html = UI::HtmlDialog.new({
      dialog_title: "参考资料", # 伪装标题
      preferences_key: "com.DistantVoices.keep_on_living.reader",
      scrollable: false,
      width: 580,
      height: 250,
      style: UI::HtmlDialog::STYLE_DIALOG
    })
    reader_html.set_url(reader_html_path)
    reader_html.show
  end

  unless file_loaded?(__FILE__)
    toolbar = UI::Toolbar.new("活下去！")
    #================================提醒开关================================
    @button_state ||= false
    # 创建切换按钮
    @button = UI::Command.new("健康提示开关") {
      toggle_button_background
    }

    # 开关图标
    @button.small_icon = "ico/switch.png"
    @button.large_icon = "ico/switch.png"
    @button.tooltip = "健康提示开关"
    @button.status_bar_text = "点击开启或关闭健康提示，每30分钟提醒你提肛，每90分钟提醒你站立，每120分钟提醒你喝水，每180分钟提醒你休息，6小时没干活就问问你死了没，死了给你联系火葬场"

    # 添加验证过程来控制选中状态和文本提示
    @button.set_validation_proc {
      # 根据状态设置选中标志和提示文本
      if @button_state
        # 开启状态
        @button.status_bar_text = "健康提示已开启（点击关闭）"
        MF_CHECKED    # 按钮显示为选中状态
      else
        # 关闭状态
        @button.status_bar_text = "健康提示已关闭（点击开启），每30分钟提醒你提肛，每90分钟提醒你站立，每120分钟提醒你喝水，每180分钟提醒你休息，6小时没干活就问问你死了没，死了给你联系火葬场"
        MF_UNCHECKED  # 按钮显示为未选中状态
      end
    }

    toolbar.add_item @button
    #================================人生哲理================================
    jokes_file = File.join(File.dirname(__FILE__), "jokes.txt")

    # 读取文件内容，移除空行和空白字符
    @jokes_text = File.readlines(jokes_file, chomp: true)
    @jokes_text.reject!(&:empty?)

    cmd_jokes = UI::Command.new("人生哲理") {
      jokes_windows
    }
    cmd_jokes.small_icon = "ico/jokes.png"
    cmd_jokes.large_icon = "ico/jokes.png"
    cmd_jokes.tooltip = "来点人生哲理"
    cmd_jokes.status_bar_text = "来点人生哲理"
    toolbar.add_item cmd_jokes
    #================================雨后小故事================================
    storiette_file = File.join(File.dirname(__FILE__), "storiette.txt")

    # 读取文件内容，移除空行和空白字符
    @storiette_text = File.readlines(storiette_file, chomp: true)
    @storiette_text.reject!(&:empty?)

    cmd_storiette = UI::Command.new("雨后小故事") {
      storiette_windows
    }
    cmd_storiette.small_icon = "ico/storiette.png"
    cmd_storiette.large_icon = "ico/storiette.png"
    cmd_storiette.tooltip = "来听听别的设计师的雨后小故事吧"
    cmd_storiette.status_bar_text = "来听听别的设计师的雨后小故事吧"
    toolbar.add_item cmd_storiette
    #================================小说阅读器================================
    cmd_reader = UI::Command.new("小说阅读器") {
       reader
    }
    cmd_reader.small_icon = "ico/reader.png"
    cmd_reader.large_icon = "ico/reader.png"
    cmd_reader.tooltip = "小说阅读器"
    cmd_reader.status_bar_text = "小说阅读器"
    toolbar.add_item cmd_reader
    #================================更新 joke.txt===========================
    cmd_update_joke = UI::Command.new("更新") {
      update
    }
    cmd_update_joke.small_icon = "ico/update_joke.png"
    cmd_update_joke.large_icon = "ico/update_joke.png"
    cmd_update_joke.tooltip = "更新人生哲理和雨后小故事"
    cmd_update_joke.status_bar_text = "将人生哲理和雨后小故事更新"
    toolbar.add_item cmd_update_joke
    #================================关于界面================================
    cmd_about = UI::Command.new("关于界面") {
      about
    }
    cmd_about.small_icon = "ico/about.png"
    cmd_about.large_icon = "ico/about.png"
    cmd_about.tooltip = "关于界面"
    cmd_about.status_bar_text = "关于界面"
    toolbar.add_item cmd_about

    toolbar.show
    file_loaded(__FILE__)
  end

end

# 直接调用死亡提醒，测试用
# DistantVoices::Keep_On_Living.instance_variable_get(:@notifier).death_notice(10)