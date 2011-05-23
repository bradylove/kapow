#
#  StatusBar.rb
#  KaPow
#
#  Created by Brady Love on 5/21/11.
#  Copyright 2011 None. All rights reserved.
#
class StatusBar < AppDelegate
  attr_accessor :statusBarItem
  attr_accessor :statusBarMenu
  attr_accessor :openKaPowMenuItem

  def initStatusBar(apps)
    @link_control = LinkControl.new
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
          smi.action = 'go_to_app:'
          smi.representedObject = app.name
          smi.target = self
          sub_menu.addItem smi

          smi = NSMenuItem.new
          smi.title = 'Restart App'
          smi.action = 'restart_server:'
          smi.representedObject = app.target
          smi.target = self
          sub_menu.addItem smi
        end)
      end)

    end

    menu

    @statusBarItem.setMenu menu
  end

  def go_to_app(sender)
    url = "http://" + sender.representedObject + ".dev"
    system("open", url)
  end

  def restart_server(sender)
    @link_control.restart(sender.representedObject.to_s)
  end

  def open_kapow(sender)
  end

end

