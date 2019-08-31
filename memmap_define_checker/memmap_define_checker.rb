require "find"
require "pp"

def usage
  puts "Usage: " + File.basename($0) + ' [path]...'
end

if ARGV.empty? || ARGV.count() != 1
  usage()
  exit 1
end

memmap_defines = []
other_defines  = []

ARGV.each{|path|
  Find.find(path) {|file|
    next if !file.match?(/\.[ch]$/)
    defines = []
    if File.basename(file).include?("MemMap.h")
      defines = memmap_defines
    else
      defines = other_defines
    end
    File.open(file, "r") do |f|
      f.each_line do |line|
        m = line.match(/\w+(START|STOP)_SEC.*/)
        defines.push(m.to_s.chomp) if !m.nil?
      end
    end
  }
}

pp memmap_defines - other_defines
