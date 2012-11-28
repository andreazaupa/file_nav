require 'ostruct'

class FileNav

  attr_reader :chroot, :pwd, :white_list

  def initialize(chroot,options={})
  	@chroot = File.expand_path(chroot)
    @pwd="/"
  	@white_list = options[:white_list] ? [options[:white_list]].flatten.uniq  : []
  end

  def ls(path= nil)
    path = @pwd unless path

    if path=="/"
      return root_directory_entries
    elsif root_directory_entry? path
      real_path = @white_list.select{ |p|  p if (File.basename(p)==FileNav.expand_relative_path(path)) }.first
      return real_ls( real_path )
    else
      root_path = FileNav.split_all(path).first
      real_path = @white_list.select{ |p|  p if (File.basename(p)==FileNav.expand_relative_path(root_path)) }.first
      path=File.join(real_path, File.join( FileNav.split_all(path)[1..-1] ) )
      return real_ls(path)
    end

  end

  def root_directory_entry?(path)
    root_directory_entries.include? FileNav.expand_relative_path(path)
  end

  def real_ls(directory_path=nil)
    check_chroot_path!(directory_path)
    entries = Dir.entries(File.join(@chroot,directory_path)) - ["..","."]
    FileNav.entries_to_struct(File.join(@chroot,directory_path), entries)
  end

  def get_real_path path_to_file

    check_chroot_path! path_to_file

    file=File.split(path_to_file).last
    path=File.split(path_to_file).first

    path = @pwd unless path

    if path=="/"
      raise("file_not_found")
    elsif root_directory_entry? path
      path = @white_list.select{ |p|  p if (File.basename(p)==FileNav.expand_relative_path(path)) }.first
    else
      root_path = FileNav.split_all(path).first
      real_path = @white_list.select{ |p|  p if (File.basename(p)==FileNav.expand_relative_path(root_path)) }.first
      if FileNav.split_all(path).size > 1
        path=File.join(real_path, File.join( FileNav.split_all(path)[1..-1] ) )
      else
        raise("file_not_found")
      end
      # path=path
    end

    exp_path=File.join(@chroot,path,file)
    if File.exists?(exp_path) && !File.directory?(exp_path)
      return exp_path
    else
      raise("file_not_found")
    end
  end

  def cd path=nil
  	path = path || @chroot
  	check_chroot_path! File.join(@pwd, path)
  	@pwd = File.expand_path( File.join(@pwd, path) )
  end

  private

  def root_directory_entries
    sanitized_white_list.collect{|s| File.split(s).last }
  end

  def sanitized_white_list
    sanitized=[]
    @white_list.collect do |p|
      absolute_path=File.expand_path(File.join(@chroot, p))
      sanitized << p if File.exists?(absolute_path) && File.directory?(absolute_path) && check_chroot_path!(p)
    end
    sanitized.compact.uniq
  end


  def check_chroot_path!(path)
  	ar_dest = FileNav.split_all( File.expand_path( File.join(@chroot, path) ) )
  	ar_root = FileNav.split_all( File.expand_path( File.join(@chroot) ) )
    if ((ar_root&ar_dest) != ar_root)
      raise("chroot_permission_error #{(ar_dest&ar_root)}")
    end
    true
  end

  def self.split_all(path)
    head, tail = File.split(path)
    return [tail] if head == '.' || tail == '/'
    return [head, tail] if head == '/'
    return split_all(head) + [tail]
  end


  def self.entries_to_struct(base_path,entries)
    entries.collect do |item_path|
      i_path=File.join(base_path, item_path)
      a={}
      %w(directory? size basename ctime extname).each{ |i| a[i] = File.send(i.to_s, i_path.to_s)  }
      o=OpenStruct.new(a)
      o.sort_key="#{o.directory? ? "AAAAAA" : "zzzzz" }#{o.basename.downcase}"
      o
    end
  end

  def self.expand_relative_path(path)

    aux=[]
    FileNav.split_all(path).each do |e|
      if e == "/"
      elsif e == ".."
        aux.pop
      elsif e == "."
      else
        aux << e
      end
    end
    File.join(aux)
  end

end



