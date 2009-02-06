FILES = FileList["*.lua", "*.conf", "readme.txt", "**/*.jpg", "*.png", "*.wav"]

ARCHIVE = File.join(ENV["TMPDIR"], "baby-pow.love")

task :zip => FILES do
  rm_f ARCHIVE
  sh "zip #{ARCHIVE} #{FILES.join(' ')}"
end

task :run => :zip do
  sh "open #{ARCHIVE}"
end

task :default => :run
