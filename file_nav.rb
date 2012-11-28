require 'file'
require 'dir'
require 'ostruct'

class FileNav
  
  def initialize(chroot,options={})
  	@chroot = @pwd = chroot
  	@white_list = [options[:white_list]].flatten.uniq 
  end

  def ls(path= ".")
  	check_path path
    current_dir=Dir.pwd
    Dir.chdir(File.join(@pwd, path))
    entries=Dir.entries(path)
    Dir.chdir current_dir
    entries
  end

  def cd path=nil
  	path = path || @chroot
  	check_path File.join(@pwd, path)
  	@pwd = File.exapand_path( File.join(@pwd, path) ) 
  end

  private

  def check_path(path)
  	ar_dest = File.split( File.exapand_path( File.join(@chroot, path) ) )
  	ar_root = File.split( File.exapand_path( File.join(@chroot) ) )
    if ((ar_root&ar_dest) != ar_root)
      raise("chroot_permission_error")
    end
  end

end



