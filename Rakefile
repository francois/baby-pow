FILES = FileList["*.lua", "*.conf", "readme.txt", "*.png", "woosh.wav", "pow.wav", "keyhandler.lua"]

ARCHIVE = File.join(ENV["TMPDIR"], "baby-pow.love")

task "keyhandler.lua" do
  File.open("keyhandler.lua", "w") do |f|
    f.puts "function handleKeyboard()"
    (("a" .. "z").to_a + ("0" .. "9").to_a).each do |sym|
      f.puts "  if love.keyboard.isDown(love.key_#{sym}) then addFirework(\"#{sym.upcase}\") end"
    end
    f.puts "end"
  end
end

task ARCHIVE => FILES do
  rm_f ARCHIVE
  sh "zip #{ARCHIVE} #{FILES.join(' ')}"
end

task :run => ARCHIVE do
  sh "open #{ARCHIVE}"
end

task :default => :run
