require 'rubygems'
#require 'bundler/setup' # Releasy doesn't require that your application uses bundler, but it does make things easier.
require 'releasy'

#<<<
Releasy::Project.new do
  name "Meteors"
  version "0.5"
  verbose
  executable "lib/stroids.rb"
  files ["lib/**/*.rb", "media/*/*.*", "media/*.*"] # config/**/*.yml",
  exposed_files
  #exposed_files "README.html", "LICENSE.txt"
  #add_link "http://my_application.github.com", "My Application website"
  exclude_encoding # Applications that don't use advanced encoding (e.g. Japanese characters) can save build size with this.

  # Create a variety of releases, for all platforms.
  add_build :osx_app do
    url "com.github.billiam"
    wrapper File.join(File.dirname(__FILE__), "pkg", "rubies", "gosu-mac-wrapper-0.7.41.tar.gz") # Assuming this is where you downloaded this file.
    icon "media/icon.icns"
    add_package :tar_gz
  end

  add_build :source do
    add_package :"7z"
  end

  # If building on a Windows machine, :windows_folder and/or :windows_installer are recommended.
  add_build :windows_folder do
    icon "media/icon.ico"
    executable_type :windows # Assuming you don't want it to run with a console window.
    add_package :exe # Windows self-extracting archive.
  end

  add_build :windows_standalone do
    icon "media/icon.ico"
    executable_type :windows # Assuming you don't want it to run with a console window.
    add_package :exe # Windows self-extracting archive.
  end

  add_build :windows_installer do
    icon File.join(File.dirname(__FILE__), 'media', 'icon.ico')
    start_menu_group "Billigames Games"
    #readme "README.html" # User asked if they want to view readme after install.
    #license "LICENSE.txt" # User asked to read this and confirm before installing.
    executable_type :windows # Assuming you don't want it to run with a console window.
    add_package :zip
  end

  # If unable to build on a Windows machine, :windows_wrapped is the only choice.
  add_build :windows_wrapped do
    wrapper "wrappers/ruby-1.9.3-p0-i386-mingw32.7z" # Assuming this is where you downloaded this file.
    executable_type :windows # Assuming you don't want it to run with a console window.
    exclude_tcl_tk # Assuming application doesn't use Tcl/Tk, then it can save a lot of size by using this.
    add_package :zip
  end

  add_deploy :github # Upload to a github project.
end
#>>>