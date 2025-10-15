module DistantVoices::Keep_On_Living
  open_time = Time.new.to_i



  kegel_exercises if (Time.new.to_i - open_time) % (60 * 30)  == 0

  #提肛函数
  def kegel_exercises
    UI.messagebox("已经工作了30分钟呢，请开始提肛，提肛运动可以帮助预防痔疮等肛周疾病\n
                  用力收缩前阴和肛门，稍微憋一会儿，然后放松，接着再往上提，一提一松，反复进行。")
  end

end

