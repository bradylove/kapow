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
  attr_accessor :browseButton
  attr_accessor :appNameField
  attr_accessor :appPathField
  attr_accessor :appListTableView
  attr_accessor :urlButton

  def applicationDidFinishLaunching(a_notification)
    @base_dir = File.expand_path '~/.pow/'
    self.get_current_apps
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
    files_paths = []
    files_names = []

    Dir[@base_dir + '/*'].each do |f|
      new_app = Apps.new
      new_app.app_name = File.basename(f.to_s)
      new_app.symlink_path = f
      new_app.destination_path = File.readlink(f)

      @apps << new_app
    end

    @appListTableView.reloadData
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
      when 'app_name'
        apps.app_name
      when 'symlink_path'
        apps.symlink_path
    end
  end

  def create_symlink(destination, name)
    link_path = @base_dir + "/" + name
    FileUtils.ln_sf destination, link_path
    
    new_app = Apps.new
    new_app.app_name = name
    new_app.symlink_path = link_path
    new_app.destination_path = destination

    @apps << new_app
    @appListTableView.reloadData

    @appPathField.stringValue = ""
    @appNameField.stringValue = ""
  end

  def add_app(sender)
    self.create_symlink(@appPathField.stringValue, @appNameField.stringValue)
  end

  def delete_symlink(index)
    link_path = @apps[index].symlink_path

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

    @appPathField.stringValue = selected_app.destination_path
    @appNameField.stringValue = selected_app.app_name
    @urlButton.title = "http://#{selected_app.app_name}.dev"
  end

  def go_to_app(sender)
   system("open", @urlButton.title) unless @urlButton.title == ""
  end

  def clear_fields
    @appPathField.stringValue = ""
    @appNameField.stringValue = ""
    @urlButton.title = ""

    @appNameField.selectText("")
  end

  def new_button(sender)
    self.clear_fields
  end
end

class Apps
  attr_accessor :app_name, :symlink_path, :destination_path
end
