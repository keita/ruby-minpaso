$KCODE = "UTF-8"
require "rubygems"
$LOAD_PATH << File.join(File.dirname(__FILE__), "..", "lib")
require "minpaso"
require "bacon"

$result = Minpaso.search(:manufacturer => "HITACHI")

describe "Minpaso::SearchResultPager" do
  @result = $result
  @item = @result.items.first

  it "size" do
    @result.size.should > 0
  end

  it "page" do
    @result.page.should == 1
  end

  it "next" do
    pager = @result.next
    pager.should.be.kind_of(Minpaso::SearchResultPager)
    pager.items.size.should > 0
  end

  it "prev" do
    @result.prev.should.be.nil
  end
end

describe "Minpaso::SearchResultPager::Item" do
  @item = $result.items.first

  it "id" do
    @item.id.should.be.kind_of(Integer)
  end

  it "manufacture" do
    @item.manufacture.should == "HITACHI"
  end

  it "product_name" do
    @item.product_name.should.be.kind_of(String)
  end

  it "wei_score" do
    @item.wei_score.should.be.kind_of(Float)
    @item.wei_score.should > 0
  end

  it "cpu_score" do
    @item.cpu_score.should.be.kind_of(Float)
    @item.cpu_score.should > 0
  end

  it "memory_score" do
    @item.memory_score.should.be.kind_of(Float)
    @item.memory_score.should > 0
  end

  it "video_score" do
    @item.video_score.should.be.kind_of(Float)
    @item.video_score.should > 0
  end

  it "game_score" do
    @item.game_score.should.be.kind_of(Float)
    @item.game_score.should > 0
  end

  it "hdd_score" do
    @item.hdd_score.should.be.kind_of(Float)
    @item.hdd_score.should > 0
  end

  it "total_score" do
    @item.total_score.should.be.kind_of(Float)
    @item.total_score.should > 0
  end
end

$pcinfo = Minpaso::PCInfo.new(1788)

describe "Minpaso::PCInfo::System" do
  @system = $pcinfo.system

  it "score" do
    @system.score.should == 7.4
  end

  it "total_score" do
    @system.total_score.should == 40.7
  end

  it "manufacturer" do
    @system.manufacturer.should == "Supermicro"
  end

  it "product_name" do
    @system.product_name.should == "X7DA8"
  end

  it "os" do
    @system.os.should == "Windows Vista (TM) Ultimate"
  end
end

describe "Minpaso::PCInfo::CPU" do
  @cpu = $pcinfo.cpu

  it "score" do
    @cpu.score.should == 9.7
  end

  it "processor_name" do
    @cpu.processor_name.should == "Intel(R) Xeon(R) CPU           E5345  @ 2.33GHz"
  end
end

describe "Minpaso::PCInfo::Memory" do
  @memory = $pcinfo.memory

  it "score" do
    @memory.score.should == 7.5
  end

  it "size" do
    @memory.size.should == 8588034048
  end
end

describe "Graphics" do
  @graphics = $pcinfo.graphics

  it "video_score" do
    @graphics.video_score.should == 7.6
  end

  it "game_score" do
    @graphics.game_score.should == 7.4
  end

  it "adapter" do
    @graphics.adapter.should == "NVIDIA GeForce 8800 GTS"
  end

  it "driver_version" do
    @graphics.driver_version.should == "7.15.11.65"
  end

  it "total_graphics_memory" do
    @graphics.total_graphics_memory.should == 1438515200.byte
  end

  it "dedicated_video_memory" do
    @graphics.dedicated_video_memory.should == 633733120.byte
  end

  it "dedicated_system_memory" do
    @graphics.dedicated_system_memory.should == 0.byte
  end

  it "shared_system_memory" do
    @graphics.shared_system_memory.should == 804782080.byte
  end
end

describe "Minpaso::PCInfo::HDD" do
  @hdd = $pcinfo.hdd

  it "score" do
    @hdd.score.should == 8.5
  end

  it "primary_size" do
    @hdd.primary_size.should == 639460438016.byte
  end

  it "primary_free_space" do
    @hdd.primary_free_space.should == 496327954432.byte
  end

  it "total_size" do
    @hdd.total_size.should == 639460438016.byte
  end
end
