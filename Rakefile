require 'rake'
require 'pathname'

desc "Hook our dotfiles into system-standard positions."
task :install => [:dirs] do
  linkables = Dir.glob('*/**{.symlink}')
  home = Pathname.new("#{ENV['HOME']}").relative_path_from(Pathname.new("#{ENV['PWD']}"))
  dotfilesdir = Pathname.new("#{ENV['PWD']}").relative_path_from(Pathname.new("#{ENV['HOME']}"))
  skip_all = false
  overwrite_all = false
  backup_all = false

  linkables.each do |linkable|
    overwrite = false
    backup = false

    file = linkable.split('/').last.split('.symlink').last
    target = "#{home}/.#{file}"

    if File.exists?(target) || File.symlink?(target)
      unless skip_all || overwrite_all || backup_all
        puts "File already exists: #{target}, what do you want to do? [s]kip, [S]kip all, [o]verwrite, [O]verwrite all, [b]ackup, [B]ackup all"
        case STDIN.gets.chomp
        when 'o' then overwrite = true
        when 'b' then backup = true
        when 'O' then overwrite_all = true
        when 'B' then backup_all = true
        when 'S' then skip_all = true
        when 's' then next
        end
      end
      FileUtils.rm_rf(target) if overwrite || overwrite_all
      `mv "$HOME/.#{file}" "$HOME/.#{file}.backup"` if backup || backup_all
    end
    `ln -s "#{dotfilesdir}/#{linkable}" "#{target}"`
  end    
end

desc "Hook our dotfile directories into system-standard positions."
task :dirs do

  home = Pathname.new("#{ENV['HOME']}").relative_path_from(Pathname.new("#{ENV['PWD']}"))
  dotfilesdir = Pathname.new("#{ENV['PWD']}").relative_path_from(Pathname.new("#{ENV['HOME']}"))
  skip_all = false
  overwrite_all = false
  backup_all = false
  
  directories = Dir.glob('*/**{.dir}/')
  directories.each do |directory|
    overwrite = false
    backup = false
    
    linkable = directory.split('/').last.split('.dir').last
    target = "#{home}/.#{linkable}"
    
    if Dir.exists?(target) || File.symlink?(target)
      unless skip_all || overwrite_all || backup_all
        puts "Directory already exists: #{target}, what do you want to do? [s]kip, [S]kip all, [o]verwrite, [O]verwrite all, [b]ackup, [B]ackup all"
        case STDIN.gets.chomp
        when 'o' then overwrite = true
        when 'b' then backup = true
        when 'O' then overwrite_all = true
        when 'B' then backup_all = true
        when 'S' then skip_all = true
        when 's' then next
        end
      end
      FileUtils.rm_rf(target) if overwrite || overwrite_all
      `mv "$HOME/.#{linkable}" "$HOME/.#{linkable}.backup"` if backup || backup_all
    end
    `ln -s "#{dotfilesdir}/#{directory}" "#{target}"`    
  end
end

task :uninstall do

  Dir.glob('**/*.symlink').each do |linkable|

    file = linkable.split('/').last.split('.symlink').last
    target = "#{ENV["HOME"]}/.#{file}"

    # Remove all symlinks created during installation
    if File.symlink?(target)
      FileUtils.rm(target)
    end
    
    # Replace any backups made during installation
    if File.exists?("#{ENV["HOME"]}/.#{file}.backup")
      `mv "$HOME/.#{file}.backup" "$HOME/.#{file}"` 
    end

  end
end

task :default => 'install'
