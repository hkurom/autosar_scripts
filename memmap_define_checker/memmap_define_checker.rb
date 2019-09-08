require "find"
require "pp"
require "optparse"

p ARGV
if ARGV.empty? || ARGV.count() < 1
  puts "Usage: " + File.basename($0) + ' [path]...'
  exit 1
end

exclude_dirs = []
args = ARGV.getopts("e:", "exclude:")
pp args if $DEBUG
if (!args["exclude"].nil?) 
  exclude_dirs = args["exclude"]
else
end
ARGV.parse!()
memmap_defines = []
other_defines  = []

ARGV.each{|path|
  next if exclude_dirs.include?(path)
  Find.find(path) {|file|
    next if !file.match(/\.[ch]$/)
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

other_defines.uniq!
memmap_defines.uniq!

other_defines.each {|define|
  pp define unless memmap_defines.include?(define)
}
