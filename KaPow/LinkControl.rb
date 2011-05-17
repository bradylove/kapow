#
#  LinkControl.rb
#  KaPow
#
#  Created by Brady Love on 5/17/11.
#  Copyright 2011 None. All rights reserved.
#
require 'FileUtils'

class LinkControl < AppDelegate

  def is_symlink?(f)
    File.symlink?(f)
  end

  def exists?(f)
    File.exists?(f)
  end
end
