module DistantVoices::Keep_On_Living
  open_time = Time.new.to_i



  kegel_exercises if (Time.new.to_i - open_time) % (60 * 30)  == 0

  #提肛函数
  def kegel_exercises
    UI.messagebox("已经工作了30分钟呢，请开始提肛，提肛运动可以帮助预防痔疮等肛周疾病\n
                  用力收缩前阴和肛门，稍微憋一会儿，然后放松，接着再往上提，一提一松，反复进行。")
  end

  def stand_up
    UI.messagebox("已经很久没有站起来了，记得站起来活动一下腰颈哦，希望你能活到领养老金")
  end

  def drinking
    UI.messagebox("你好像很久没喝水了呢，长期饮水不足可能增加泌尿系统结石的风险")
  end

  def rest
    UI.messagebox("工作是公司的，命是自己的，请记得休息一下，休息一下，休息一下")
  end

end

