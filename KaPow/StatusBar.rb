#
#  StatusBar.rb
#  KaPow
#
#  Created by Brady Love on 5/21/11.
#  Copyright 2011 None. All rights reserved.
#
class StatusBar
  attr_accessor :statusBarItem
  attr_accessor :statusBarMenu
  attr_accessor :openKaPowMenuItem

  def initStatusBar(apps)
    status_bar = NSStatusBar.systemStatusBar
    @statusBarItem = status_bar.statusItemWithLength(NSVariableStatusItemLength)
    
    image = NSImage.imageNamed 'system-icon'
    @statusBarItem.setImage image

    self.setup_menu(apps)
  end

  def setup_menu(apps)
    menu = NSMenu.new
    menu.initWithTitle 'KaPow'
    mi = NSMenuItem.new
    mi.title = 'Open KaPow'
    mi.action = 'open_kapow:'
    mi.target =  self
    menu.addItem mi

    mi = NSMenuItem.separatorItem

    menu.addItem mi
    
    apps.each do |app|
      menu.addItem(NSMenuItem.new.tap do |menu_item|
        menu_item.title = app.name
        menu_item.setSubmenu(NSMenu.new.tap do |sub_menu|
          smi = NSMenuItem.new
          smi.title = 'Open in Browser'
          smi.action = 'open_kapow:'
          smi.target = self
          sub_menu.addItem smi

          smi = NSMenuItem.new
          smi.title = 'Restart App'
          smi.action = 'open_kapow:'
          smi.target = self
          sub_menu.addItem smi
        end)
      end)

    end

    menu

    @statusBarItem.setMenu menu
  end

  def open_kapow(sender)

  end

  def update_menu(apps)

  end
end

