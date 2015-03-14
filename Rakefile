require 'bundler/setup'
require 'releasy'

Releasy::Project.new do
   name "EienteiRL"
   version "0.1.0"
   verbose # Can be removed if you don't want to see all build messages.

   executable "./game.rb"
   files ["*.*", "fonts/**/*.*", "gen/**/*.*", "presets/**/*.*"]
   exposed_files ["README.md","VERSION"]
   add_link "http://github.com/BakaBBQ/EienteiRL", "EienteiRL Website"
   exclude_encoding # Applications that don't use advanced encoding (e.g. Japanese characters) can save build size with this.

   # Create a variety of releases, for all platforms.
   add_build :osx_app do
     url "org.ninesyllables.org.eienteirl"
     wrapper "./gosu-mac-wrapper-0.7.44.tar.gz" # Assuming this is where you downloaded this file.
     icon "./icon.icns"
     add_package :tar_gz
   end

   add_build :source do
     add_package :"7z"
   end

   add_deploy :local # Only deploy locally.
 end