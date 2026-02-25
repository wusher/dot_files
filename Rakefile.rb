
@files = %w[vimrc zshrc gemrc gitconfig tmux.conf]
@dotfiles_dir = File.expand_path(__dir__)
@tmux_bin_files = %w[
  tmux-mode-pill.sh
  tmux-popup-menu.sh
  tmux-right-status.py
  tmux-workstate.py
]
@tmux_theme_files = %w[
  tokyonight.conf
  monokai.conf
  github-light.conf
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

  print "ensuring ~/.tmux/themes exists\n"
  print `mkdir -p ~/.tmux/themes`

  @tmux_theme_files.each do |file_name|
    print "linking theme #{file_name}\n"
    print `ln -sfn #{@dotfiles_dir}/tmux/themes/#{file_name} ~/.tmux/themes/#{file_name}`
    print "\n"
  end

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
