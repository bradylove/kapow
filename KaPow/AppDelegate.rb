#
#  AppDelegate.rb
#  KaPow
#
#  Created by Brady Love on 5/15/11.
#  Copyright 2011 None. All rights reserved.
#
require 'FileUtils'

class AppDelegate
  attr_accessor :window
  attr_accessor :mainMenu
  attr_accessor :browseButton, :saveButton, :urlButton, :restartButton
  attr_accessor :alwaysRestartCheckbox
  attr_accessor :appNameField, :appPathField
  attr_accessor :appListTableView

  POWDIR = File.expand_path '~/.pow/'

  def applicationDidFinishLaunching(a_notification)
    # self.menuBarVisible = false

    @link_control = LinkControl.new
    self.initStatusBar
    
    self.get_current_apps
    self.enable_fields
  end




  def browse(sender)
    dialog = NSOpenPanel.openPanel
    dialog.canChooseFiles = false
    dialog.canChooseDirectories = true
    dialog.allowsMultipleSelection = false

    if dialog.runModalForDirectory(nil, file:nil) == NSOKButton
      @appPathField.stringValue = dialog.filename.to_s
    end
  end

  def get_current_apps
    Dir[POWDIR + '/*'].each do |f|
      if @link_control.is_symlink?(f)
        new_app = Apps.new
        new_app.name = File.basename(f.to_s)
        new_app.link = f
        new_app.target = File.readlink(f)

        @apps << new_app
      else
        #do nothing
      end
    end

    @appListTableView.reloadData
    self.setup_menu
  end

  def numberOfRowsInTableView(view)
    @apps.size
  end

  def awakeFromNib
    @apps = []
    @appListTableView.dataSource = self
  end

  def tableView(view, objectValueForTableColumn:column, row:index)
    apps = @apps[index]
    case column.identifier
      when 'name'
        apps.name
    end
  end

  def create_symlink(target, name)
    link_path = POWDIR + "/" + name
    if @link_control.exists?(link_path)
      self.show_error("#{name} already exists.", "Please enter a different name.")
    elsif @link_control.exists?(target)
      FileUtils.ln_sf target, link_path

      new_app = Apps.new
      new_app.name = name
      new_app.link = link_path
      new_app.target = target

      @apps << new_app
      @appListTableView.reloadData
      self.setup_menu

      self.clear_fields
    else
      self.show_error("#{target} does not exist.", "Please verify that the path is correct and exists")
    end
  end

  def add_app(sender)
    self.create_symlink(@appPathField.stringValue, @appNameField.stringValue)
  end

  def delete_symlink(index)
    link_path = @apps[index].link

    FileUtils.rm_r link_path, :force => true
    @apps.delete_at(index)

    @appListTableView.reloadData

    self.clear_fields
  end

  def delete_button(sender)
    self.delete_symlink(@appListTableView.selectedRow)
  end

  def app_selection(sender)
    selected_app = @apps.at(@appListTableView.selectedRow)

    @appPathField.stringValue = selected_app.target
    @appNameField.stringValue = selected_app.name
    @urlButton.title = "http://#{selected_app.name}.dev"

    if @link_control.exists?(selected_app.target + "/tmp/always_restart.txt")
      @alwaysRestartCheckbox.state = 1
    else
      @alwaysRestartCheckbox.state = 0
    end

    self.disable_fields
  end

  def go_to_app(url)
   system("open", url) 
  end

  def url_button_click(sender)
    go_to_app(@urlButton.title) unless @urlButton.title == ""
  end

  def show_error(error, error_correction)
    alert = NSAlert.alertWithMessageText(error, defaultButton: "OK",
                                         alternateButton: nil,
                                         otherButton: nil,
                                         informativeTextWithFormat: error_correction)
    alert.runModal
  end

  def clear_fields
    @appPathField.stringValue = ""
    @appNameField.stringValue = ""
    @urlButton.title = ""

    @appNameField.selectText("")
  end

  def new_button(sender)
    self.enable_fields
    self.clear_fields
  end

  def disable_fields
    @appPathField.enabled = false
    @appNameField.enabled = false
    @browseButton.enabled = false
    @saveButton.enabled   = false

    @restartButton.enabled         = true
    @alwaysRestartCheckbox.enabled = true
  end

  def enable_fields
    @appPathField.enabled = true
    @appNameField.enabled = true
    @browseButton.enabled = true
    @saveButton.enabled   = true

    @restartButton.enabled         = false
    @alwaysRestartCheckbox.enabled = false
  end

  def restart_server(sender)
    f = @apps.at(@appListTableView.selectedRow).target

    @link_control.restart(f)
  end

  def always_restart_control(sender)
    f = @apps.at(@appListTableView.selectedRow).target


    if @alwaysRestartCheckbox.state == 1
      @link_control.make_always_restart(f)
    else
      @link_control.remove_always_restart(f)
    end
  end


  #################################
  # Status Bar
  #################################

  def initStatusBar
    status_bar = NSStatusBar.systemStatusBar
    @statusBarItem = status_bar.statusItemWithLength(NSVariableStatusItemLength)
    
    image = NSImage.imageNamed 'system-icon'
    @statusBarItem.setImage image

    self.setup_menu
  end

  def setup_menu
    menu = NSMenu.new
    menu.initWithTitle 'KaPow'
    mi = NSMenuItem.new
    mi.title = 'Open KaPow'
    mi.action = 'open_kapow:'
    mi.target =  self
    menu.addItem mi

    mi = NSMenuItem.separatorItem

    menu.addItem mi
    
    @apps.each do |app|
      menu.addItem(NSMenuItem.new.tap do |menu_item|
        menu_item.title = app.name
        menu_item.setSubmenu(NSMenu.new.tap do |sub_menu|
          smi = NSMenuItem.new
          smi.title = 'Open in Browser'
          smi.action = 'go_to_app_click:'
          smi.representedObject = app.name
          smi.target = self
          sub_menu.addItem smi

          smi = NSMenuItem.new
          smi.title = 'Restart App'
          smi.action = 'restart_server_from_menu:'
          smi.representedObject = app.target
          smi.target = self
          sub_menu.addItem smi
        end)
      end)

    end

    menu

    @statusBarItem.setMenu menu
  end

  def go_to_app_click(sender)
     go_to_app("http://" + sender.representedObject + ".dev")
  end

  def restart_server_from_menu(sender)
    @link_control.restart(sender.representedObject.to_s)
  end

  def open_kapow(sender)
    @window.isVisible = true
  end
end

class Apps
  attr_accessor :name, :target, :link
end
