#
#  StatusBar.rb
#  KaPow
#
#  Created by Brady Love on 5/17/11.
#  Copyright 2011 None. All rights reserved.
#
class StatusBar
  attr_accessor :statusMenu
  attr_accessor :status_item

  def initialize
    icon = NSImage.imageNamed 'system-icon'

    status_bar = NSStatusBar.systemStatusBar
    status_item = status_bar.statusItemWithLength(NSVariableStatusItemLength)
    status_item.setMenu @statusMenu
    status_item.setImage(icon)
  end

  def open_kapow(sender)
    # Open KaPow
  end
end


