
@files = %w[vimrc zshrc gemrc gitconfig tmux.conf]
@dotfiles_dir = Dir.pwd
@tmux_bin_files = %w[
  tmux-mode-pill.sh
  tmux-popup-menu.sh
  tmux-right-status.py
  tmux-workstate.py
]

task :install do
  @files.each do |file_name|
    print "linking #{file_name}\n"
    print `ln -sfn #{@dotfiles_dir}/#{file_name} ~/.#{file_name}`
    print "\n"
  end
end

task :tmux do
  print "linking tmux.conf\n"
  print `ln -sfn #{@dotfiles_dir}/tmux.conf ~/.tmux.conf`

  print "ensuring ~/bin exists\n"
  print `mkdir -p ~/bin`

  @tmux_bin_files.each do |file_name|
    print "linking #{file_name}\n"
    print `chmod +x #{@dotfiles_dir}/bin/#{file_name}`
    print `ln -sfn #{@dotfiles_dir}/bin/#{file_name} ~/bin/#{file_name}`
    print "\n"
  end
end

task :uninstall do
  @files.each do |file_name|
    `rm ~/.#{file_name}`
  end
end
