
@files = %w{ vimrc zshrc gemrc gitconfig tmux.conf}

task :install do 
  @files.each do |file_name|
    `ln -s #{Dir.pwd}/#{file_name} ~/.#{file_name}`
  end 
end 

task :uninstall do 
  @files.each do |file_name|
    `rm ~/.#{file_name}`
  end 

end 
