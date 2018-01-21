
@files = %w{ vimrc zshrc gemrc gitconfig tmux.conf}

task :install do 
  @files.each do |file_name|
    print "linking #{file_name}\n"
    print `ln -s #{Dir.pwd}/#{file_name} ~/.#{file_name}`
    print "\n"
  end 
end 

task :uninstall do 
  @files.each do |file_name|
    `rm ~/.#{file_name}`
  end 

end 
