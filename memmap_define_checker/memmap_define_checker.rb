require "find"
require "pp"
require "optparse"

if ARGV.empty? || ARGV.count() < 1
  puts "Usage: " + File.basename($0) + ' [path]...'
  exit 1
end

exclude_dirs = ARGV.getopts("exclude:")
p exclude_dirs if $DEBUG

memmap_defines = []
other_defines  = []

ARGV.each{|path|
  Find.find(path) {|file|
    next if !file.match(/\.[ch]$/)
    defines = []
    if File.basename(file).include?("MemMap.h")
      defines = memmap_defines
    else
      defines = other_defines
    end
    File.open(file, "r:utf-8") do |f|
      f.each_line do |line|
        m = line.match(/\w+(START|STOP)_SEC.*/)
        defines.push(m.to_s.chomp) if !m.nil?
      end
    end
  }
}

other_defines.uniq!
memmap_defines.uniq!

other_defines.each {|define|
  pp define unless memmap_defines.include?(define)
}

pp memmap_defines if $DEBUG
