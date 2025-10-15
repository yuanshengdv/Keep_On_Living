module DistantVoices::Keep_On_Living
  # 提肛函数
  def self.kegel_exercises
    random_index = rand(@jokes.length)
    joke_txt = @jokes[random_index]
    UI.messagebox("已经工作了30分钟呢，请开始提肛，提肛运动可以帮助预防痔疮等肛周疾病\n用力收缩前阴和肛门，稍微憋一会儿，然后放松，接着再往上提，一提一松，反复进行。\n\n#{joke_txt}")
  end

  # 站立函数
  def self.stand_up
    random_index = rand(@jokes.length)
    joke_txt = @jokes[random_index]
    UI.messagebox("已经很久没有站起来了，记得站起来活动一下腰颈哦，希望你能活到领养老金。\n\n#{joke_txt}")
  end

  # 喝水函数
  def self.drinking
    random_index = rand(@jokes.length)
    joke_txt = @jokes[random_index]
    UI.messagebox("你好像很久没喝水了呢，长期饮水不足可能增加泌尿系统结石的风险。\n\n#{joke_txt}")
  end

  # 休息函数
  def self.rest
    random_index = rand(@jokes.length)
    joke_txt = @jokes[random_index]
    UI.messagebox("活是公司的，命是自己的，请记得休息一下。\n\n#{joke_txt}")
  end

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
      # 每180分钟提醒休息
      if elapsed_minutes >= 180 && elapsed_minutes - @last_reminders[:rest] >= 180
        DistantVoices::Keep_On_Living.rest
        @last_reminders[:rest] = elapsed_minutes
        return
      end

      # 每120分钟提醒喝水
      if elapsed_minutes >= 120 && elapsed_minutes - @last_reminders[:drink] >= 120
        DistantVoices::Keep_On_Living.drinking
        @last_reminders[:drink] = elapsed_minutes
        return
      end

      # 每90分钟提醒站立
      if elapsed_minutes >= 90 && elapsed_minutes - @last_reminders[:stand] >= 90
        DistantVoices::Keep_On_Living.stand_up
        @last_reminders[:stand] = elapsed_minutes
        return
      end

      # 每30分钟提醒提肛
      if elapsed_minutes >= 30 && elapsed_minutes - @last_reminders[:kegel] >= 30
        DistantVoices::Keep_On_Living.kegel_exercises
        @last_reminders[:kegel] = elapsed_minutes
      end
    end
  end

  # 启动后台监听程序
  def self.start_background_listener
    if !@notifier || @notifier.nil?
      @notifier = BackgroundNotifier.new
      @notifier.start
    end
  end

  # 停止后台监听程序
  def self.stop_background_listener
    if @notifier
      @notifier.stop
      @notifier = nil
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

  unless file_loaded?(__FILE__)
    @button_state ||= false
    # 读取文件内容，移除空行和空白字符
    jokes_file = File.join(File.dirname(__FILE__), "jokes.txt")
    @jokes = File.readlines(jokes_file, chomp: true)
    @jokes.reject!(&:empty?)
    @toolbar = UI::Toolbar.new("活下去！")

    # 创建切换按钮
    @button = UI::Command.new("健康提示开关") {
      toggle_button_background
    }

    # 开关图标
    @button.small_icon = "ico/switch.png"
    @button.large_icon = "ico/switch.png"
    @button.tooltip = "点击开启或关闭健康提示"
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

    @toolbar.add_item @button
    @toolbar.show
    file_loaded(__FILE__)
  end
end
