require "open-uri"
require "uri"
require "rexml/document"
require "units/standard"

module Minpaso
  VERSION = "002"

  # params:: See http://minpaso.goga.co.jp/ja-JP/api.php for details.
  # - :manufacturer
  # - :product_name
  # - :cpu_name
  # - :graphics_adapter
  # - :wei_min
  # - :wei_max
  # - :cpu_min
  # - :cpu_max
  # - :memory_min
  # - :memory_max
  # - :game_min
  # - :game_max
  # - :hdd_min
  # - :hdd_max
  # - :total_min
  # - :total_max
  # - :s or :sort
  # - :p or :page
  # - :h
  # - :e or :guess_score
  def self.search(params={})
    uri = URI.parse("http://minpaso.goga.co.jp/api/search.php")
    params = params.inject(Hash.new) do |table, (k, v)|
      case k
      when :sort; table["s"] = v
      when :page; table["p"] = v
      when :guess_score; table["e"] = e
      else
        if k.to_s.size > 1
          table[k.to_s.capitalize.gsub(/_([a-z])/){$1.capitalize}] = v
        else
          table[k.to_s] = v
        end
      end
      table
    end
    keys = params.keys - ["Manufacturer", "ProductName", "CpuName", "GraphicsAdapter",
                          "WeiMin", "WeiMax", "CpuMin", "CpuMax", "MemoryMin",
                          "MemoryMax", "VideoMin", "VideoMax", "GameMin", "GameMax",
                          "HddMin", "HddMax", "TotalMin", "TotalMax", "s", "p",
                          "h", "e"]
    raise ArgumentError, keys if keys.size > 0
    uri.query = params.map{|k, v| k + "=" + v.to_s}.join("&")
    SearchResultPager.new(REXML::Document.new(uri.read), params)
  end

  class SearchResultPager
    class Item
      attr_reader :id, :manufacture, :product_name, :wei_score, :cpu_score
      attr_reader :memory_score, :video_score, :game_score, :hdd_score
      attr_reader :total_score

      def initialize(elt)
        elt.elements.each do |e|
          case e.name
          when "ItemId"; @id = e.text.to_i
          when "Manufacture"; @manufacture = e.text
          when "ProductName"; @product_name = e.text
          when "WeiScore"; @wei_score = e.text.to_f
          when "CpuScore"; @cpu_score = e.text.to_f
          when "MemoryScore"; @memory_score = e.text.to_f
          when "VideoScore"; @video_score = e.text.to_f
          when "GameScore"; @game_score = e.text.to_f
          when "HddScore"; @hdd_score = e.text.to_f
          when "TotalScore"; @total_score = e.text.to_f
          end
        end
      end

      # Qeury the PC detail informations.
      def pcinfo(guess_score = true)
        Minpaso::PCInfo.new(@id, guess_score)
      end
    end

    attr_reader :size, :items
    def initialize(doc, params)
      @params = params
      @items = []
      doc.root.elements.each do |elt|
        case elt.name
        when "NumOfResult"
          @size = elt.text.to_i
        when "Item"
          @items << Item.new(elt)
        end
      end
    end

    def page
      @params.has_key?("p") ? @params["p"] : 1
    end

    # Go to previous page.
    def prev
      prev_page = page - 1
      return nil if prev_page <= 0
      Minpaso.search(@params.merge(:p => prev_page))
    end

    # Go to next page.
    def next
      next_page = page + 1
      return nil if next_page >= ((@size - 1) / 10) + 1
      Minpaso.search(@params.merge(:p => next_page))
    end
  end

  # PCInfo shows PC detail informations.
  class PCInfo
    attr_reader :id, :guess_score, :system, :cpu, :graphics, :memory, :hdd

    def initialize(id, guess_score = true)
      @id = id
      @guess_score = guess_score
      uri = URI.parse("http://minpaso.goga.co.jp/api/pc.php?id=#{@id.to_s}&e=#{guess_score}")
      doc = REXML::Document.new(uri.read)
      doc.root.elements.each do |elt|
        case elt.name
        when "System"; @system = System.new(elt)
        when "Cpu"; @cpu = CPU.new(elt)
        when "Graphics"; @graphics = Graphics.new(elt)
        when "Memory"; @memory = Memory.new(elt)
        when "Hdd"; @hdd = HDD.new(elt)
        end
      end
    end

    class System
      attr_reader :score, :total_score, :manufacturer, :product_name, :os
      def initialize(elt)
        elt.elements.each do |e|
          case e.name
          when "Score"; @score = e.text.to_f
          when "TotalScore"; @total_score = e.text.to_f
          when "Manufacturer"; @manufacturer = e.text
          when "ProductName"; @product_name = e.text
          when "Os"; @os = e.text
          end
        end
      end
    end

    class CPU
      attr_reader :score, :processor_name
      def initialize(elt)
        elt.elements.each do |e|
          case e.name
          when "Score"; @score = e.text.to_f
          when "ProcessorName"; @processor_name = e.text
          end
        end
      end
    end

    class Memory
      attr_reader :score, :size
      def initialize(elt)
        elt.elements.each do |e|
          case e.name
          when "Score"; @score = e.text.to_f
          when "Size"; @size = e.text.to_i.byte
          end
        end
      end
    end

    class Graphics
      attr_reader :video_score, :game_score, :adapter, :driver_version
      attr_reader :total_graphics_memory, :dedicated_video_memory
      attr_reader :dedicated_system_memory, :shared_system_memory
      def initialize(elt)
        elt.elements.each do |e|
          case e.name
          when "VideoScore"; @video_score = e.text.to_f
          when "GameScore"; @game_score = e.text.to_f
          when "Adapter"; @adapter = e.text
          when "DriverVersion"; @driver_version = e.text
          when "TotalGraphicsMemory"; @total_graphics_memory = e.text.to_i.byte
          when "DedicatedVideoMemory"; @dedicated_video_memory = e.text.to_i.byte
          when "DedicatedSystemMemory"; @dedicated_system_memory = e.text.to_i.byte
          when "SharedSystemMemory"; @shared_system_memory = e.text.to_i.byte
          end
        end
      end
    end

    class HDD
      attr_reader :score, :primary_size, :primary_free_space, :total_size
      def initialize(elt)
        elt.elements.each do |e|
          case e.name
          when "Score"; @score = e.text.to_f
          when "PrimarySize"; @primary_size = e.text.to_i.byte
          when "PrimaryFreeSpace"; @primary_free_space = e.text.to_i.byte
          when "TotalSize"; @total_size = e.text.to_i.byte
          end
        end
      end
    end
  end
end
