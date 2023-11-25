s = ''
256.times do |i|
  s += [0xcb, i, 0, 0].pack('C*')
end
File.binwrite(ARGV[0], s)
