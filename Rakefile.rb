
@files = %w{ vimrc zshrc gemrc gitconfig}

task :install do 
  @files.each do |file_name|
    `ln -s ~/Dropbox/dot_files/#{file_name} ~/.#{file_name}`
  end 
end 

task :uninstall do 
  @files.each do |file_name|
    `rm ~/.#{file_name}`
  end 

end 
