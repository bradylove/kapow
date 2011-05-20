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

  def restart(f)
    folder = f + "/tmp"

    if !exists?(folder)
      FileUtils.mkdir(folder)
    end

    FileUtils.touch(folder + "/restart.txt")
  end

  def make_always_restart(f)
    folder = f + "/tmp"

    if !exists?(folder)
      FileUtils.mkdir(folder)
    end

    FileUtils.touch(folder + "/always_restart.txt")
  end

  def remove_always_restart(f)
    if self.exists?(f + "/tmp/always_restart.txt")
      FileUtils.rm(f + "/tmp/always_restart.txt")
    end
  end
end
