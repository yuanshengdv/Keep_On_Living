# Copyright (c) 2025 DistantVoices
# =============================功能说明=============================
# sketchup插件：活下去！
# 督促你活下去
# 每30分钟提醒你提肛
# 每90分钟提醒你站立
# 每120分钟提醒你喝水
# 每180分钟提醒你休息
# 6小时没干活就问问你死了没，死了给你联系火葬场
# 内置一个小说阅读器，预约心情，减少抑郁

require 'sketchup.rb'
require 'extensions.rb'

module DistantVoices
  module Keep_On_Living

    unless file_loaded?(__FILE__)
      ex = SketchupExtension.new('活下去！', 'Keep_On_Living/main')
      ex.description = '设计行业的加班情况日益严重，希望通过这个工具来督促你活下去'
      ex.version     = "0.1.0"
      ex.copyright   = 'Copyright (c) 2025 DistantVoices.'
      ex.creator     = 'DistantVoices'
      Sketchup.register_extension(ex, true)
      file_loaded(__FILE__)
    end

  end
end