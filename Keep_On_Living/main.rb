module DistantVoices::Keep_On_Living

  # 后台监听程序
  class BackgroundNotifier
    def initialize
      @start_time = Time.new.to_i
      @last_reminders = {
        kegel: 0,
        stand: 0,
        drink: 0,
        rest: 0
      }
      @timer_id = nil
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

    # 检查并提醒
    def check_and_notify
      current_time = Time.new.to_i
      elapsed_minutes = (current_time - @start_time) / 60

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
        UI.messagebox("已经工作了30分钟呢，请开始提肛，提肛运动可以帮助预防痔疮等肛周疾病\n用力收缩前阴和肛门，稍微憋一会儿，然后放松，接着再往上提，一提一松，反复进行。")
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
      dialog_title: "人生哲理", # 清空标题
      preferences_key: "com.DistantVoices.keep_on_living.joke",
      scrollable: false,
      width: 450,
      height: 400,
      style: UI::HtmlDialog::STYLE_DIALOG
    })

    # 显示 HTML 页面
    joke_html.set_url(full_url)
    joke_html.show

  end

  # 启动后台监听程序
  def self.start_background_listener
    # 防止重复启动
    return if @notifier

    unless @notifier
      @notifier = BackgroundNotifier.new
      @notifier.start
      puts "启动后台监听程序"
    end
  end

  # 停止后台监听程序
  def self.stop_background_listener
    if @notifier
      @notifier.stop
      @notifier = nil
      puts "停止后台监听程序"
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
                               :height          => 440,
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
    # 显示对话框
    dlg.show
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
    @button.status_bar_text = "点击开启或关闭健康提示"

    # 添加验证过程来控制选中状态和文本提示
    @button.set_validation_proc {
      # 根据状态设置选中标志和提示文本
      if @button_state
        # 开启状态
        @button.status_bar_text = "健康提示已开启（点击关闭）"
        MF_CHECKED    # 按钮显示为选中状态
      else
        # 关闭状态
        @button.status_bar_text = "健康提示已关闭（点击开启）"
        MF_UNCHECKED  # 按钮显示为未选中状态
      end
    }

    toolbar.add_item @button
    #================================人生哲理================================
    # 读取文件内容，移除空行和空白字符
    jokes_file = File.join(File.dirname(__FILE__), "jokes.txt")
    #读取笑话文本
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
