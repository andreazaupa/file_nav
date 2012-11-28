require "./file_nav"
describe FileNav do

  before do
    @base_path = (File.expand_path("./test_dir/"))
    @white_list = ["dir1","dir3","dir4/dir41","imnotpresent"]
    @file_nav = FileNav.new(@base_path,:white_list=>@white_list)
  end

  it "should create new instance of FileNAv" do
    @file_nav.should_not be_nil
  end

  it "should set right chroot" do
    @file_nav = FileNav.new(@base_path, :white_list=>@white_list)
    @file_nav.chroot.should == @base_path
    @file_nav.white_list.should == @white_list
    @file_nav.pwd.should == "/"
  end


  it "should ls white_list present folders when send '/' to ls" do
    @file_nav.ls("/").should ==  ["dir1","dir3","dir41"]
  end

  it "should return content of dir1 if ls to dir1" do

    @file_nav.ls("dir1").collect(&:basename).should == ["dubdir1","dubdir2"]

    @file_nav.ls("../dir1").collect(&:basename).should == ["dubdir1","dubdir2"]

    @file_nav.ls("../dir1/../dir1").collect(&:basename).should == ["dubdir1","dubdir2"]

    @file_nav.ls("dir3").should == []

    @file_nav.ls("dir41").collect(&:basename).should == ["dir42","file411","file412"]

    @file_nav.ls("dir1/dubdir1").collect(&:basename).should == ["f1","f3","f3.ext1"]

    @file_nav.ls("dir41/dir42/").collect(&:basename).should == ["file4121"]

    @file_nav.ls("dir1/dubdir1").last.extname.should == ".ext1"

    @file_nav.ls("dir41/../dir1").collect(&:basename).should == ["dubdir1","dubdir2"]

    lambda{ @file_nav.ls("/../dir1/..") }.should raise_error

  end

  it "should return real_path to file or raise error if file not exist" do

    @file_nav.get_real_path("dir1/dubdir1/f1").should == File.expand_path(File.join(@base_path,"dir1/dubdir1/f1"))

    @file_nav.get_real_path("dir41/dir42/file4121").should == File.expand_path(File.join(@base_path,"dir4/dir41/dir42/file4121"))

  end

  it "should raise file_not_found" do
    lambda{
      @file_nav.get_real_path("dir1/dubdir1/f").should == File.expand_path(File.join(@base_path,"dir1/dubdir1/f1"))
    }.should raise_error "file_not_found"

    lambda{
      @file_nav.get_real_path("").should == File.expand_path(File.join(@base_path,"dir1/dubdir1/f1"))
    }.should raise_error "file_not_found"

    lambda{
      @file_nav.get_real_path("dir1").should == File.expand_path(File.join(@base_path,"dir1/dubdir1/f1"))
    }.should raise_error "file_not_found"
  end


end
