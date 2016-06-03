#
# Cookbook Name:: mingw
# Resource:: msys2_package
#
# Copyright 2016, Chef Software, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Installs msys2 base system and installs/upgrades packages within in.
#
# Where's the version flag?  Where's idempotence you say?  Well f*** you
# for trying to version your product.  This is arch.  They live on the edge.
# You never get anything but the latest version.  And if that's broken...
# well that's your problem isn't it?  And they don't believe in preserving
# older versions.  Good luck!

property :package, kind_of: String, name_property: true
property :root, kind_of: String, required: true

resource_name :msys2_package

action_class do
  def msys2_exec(comment, cmd)
    f_root = win_friendly_path(root)
    execute comment do
      command ".\\bin\\bash.bat -l -c \"#{cmd}\""
      cwd f_root
    end
  end

  def msys2_init
    cache_dir = ::File.join(root, '.cache')
    f_cache_dir = win_friendly_path(cache_dir)
    base_url = 'http://iweb.dl.sourceforge.net/project/msys2/Base/x86_64/msys2-base-x86_64-20160205.tar.xz'
    base_checksum = '7e97e2af042e1b6f62cf0298fe84839014ef3d4a3e7825cffc6931c66cc0fc20'

    unless ::File.exist?(::File.join(root, 'msys2.exe'))
      seven_zip_archive "cache msys2 base to #{f_cache_dir}" do
        source base_url
        path f_cache_dir
        checksum base_checksum
      end

      seven_zip_archive "extract msys2 base archive to #{f_cache_dir}" do
        source "#{f_cache_dir}\\#{tar_name(base_url)}"
        path f_cache_dir
        overwrite true
      end

      ruby_block 'copy msys2 base files to root' do
        block do
          ::FileUtils.cp_r("#{cache_dir}/msys64/.", root)
        end
      end
    end

    home_dir = ::File.join(root, 'home', ENV['USERNAME'])
    bin_dir = ::File.join(root, 'bin')
    updated_marker_file = ::File.join(root, 'updated-core')

    directory win_friendly_path(bin_dir)

    cookbook_file win_friendly_path("#{bin_dir}/bash.bat") do
      source 'bash.bat'
      cookbook 'mingw'
    end

    # During first run, msys initialized the /home/user directory with files
    # from /etc/skel.  It also does a number of other first time setup steps.
    # The shell must be restarted and cannot be reused.
    msys2_exec('msys2 first time init', 'exit') unless ::File.exist?(home_dir)

    # Update pacman and msys base packages.
    # TODO: Why is this file not going away - debug this later.
    # unless ::File.exist?(::File.join(root, 'usr/bin/update-core'))
    unless ::File.exist?(updated_marker_file)
      msys2_exec('sync msys2 packages', 'pacman -Sy')
      msys2_exec('upgrade msys2 core packages', 'pacman -S --noconfirm --needed bash pacman msys2-runtime msys2-runtime-devel')
      msys2_exec('upgrade entire msys2 system', 'pacman -Suu --noconfirm')
      # Sometimes this step seems to be necessary.  Unsure why..
      # Not doing this results in only a few packages getting upgraded.
      msys2_exec('upgrade entire msys2 system', 'pacman -Syu --noconfirm')
      file win_friendly_path(updated_marker_file) do
        action :touch
      end
    end

    cookbook_file win_friendly_path("#{home_dir}/.bash_profile") do
      source 'bash_profile'
      cookbook 'mingw'
    end
  end

  def msys2_do_action(comment, action_cmd)
    msys2_init
    msys2_exec(comment, action_cmd)
  end
end

action :install do
  msys2_do_action("installing #{package}", "pacman -S --noconfirm #{package}")
end

# Package name is ignored.  This is arch.  Why would you ever upgrade a single
# package and its deps?  That'll just break everything else that ever depended
# on a different version of that dep.  Because arch is wonderful like that.
# So you only get the choice to move everything to latest or not...  it's the
# most agile development possible!
action :upgrade do
  msys2_do_action("upgrading #{package}", "pacman -Syu --noconfirm #{package}")
end

action :remove do
  msys2_do_action("removing #{package}", "pacman -R --noconfirm #{package}")
end
