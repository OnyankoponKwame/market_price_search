# price_array = [3500, 60000, 64800, 9990, 118888, 14999, 62222, 64333, 7700, 18333, 63333, 1000, 25900, 20000, 59800, 3000, 24444, 45980, 1999, 3555, 2999, 3555, 5777, 14444, 145555, 59000, 25555, 23333, 31111, 15999, 1200, 7500, 3199, 5200, 2999, 1222, 58000, 110000, 26999, 9188, 4888, 45000, 777, 1083, 1527, 1600, 750, 750, 750, 750, 750, 750, 750, 750, 750, 750, 750, 750, 750, 750, 2900, 4900, 28888, 11111, 15555, 3900, 9300, 1199, 19999, 1999, 1222, 1699, 1088, 1499, 4500, 1111, 3888, 2666, 2222, 5444, 64999, 433, 274000, 28777, 1600, 555, 5444, 3099, 3600, 17777, 52000,8000, 7444, 63333, 63000, 8800, 58555, 8380, 35500, 33999, 5666, 15000, 63333, 1100, 880, 2999, 1222, 1500, 1611, 699, 699, 999, 1666, 7999, 56000]


price_array = [56000, 58555, 63000, 63333, 63333]

# min, max = price_array.minmax

# haba = max-min

price_array.select!{|x| x>=50000}
price_array.select!{|x| x<=90000}
price_array.sort!

min, max = price_array.minmax
haba = max-min

length = price_array.length

q1 = price_array[(length*0.25).round]
q3 = price_array[(length*0.75).round]

iqr=q3-q1

#外れ値基準の下限を取得
bottom=q1-(1.5*iqr)
#外れ値基準の上限を取得
up=q3+(1.5*iqr)

class_size = (Math.log2(length) + 3).round
class_width = iqr/class_size

bins = haba/class_size

bins = (bins/500.0).round * 500
# puts "bb:#{bb}"
label_array = []
data_array = []

def count_digits(num)
  Math.log10(num.abs).to_i + 1
end

count_digits(bins)

# bins = bins.round(1-count_digits(bins))


Range.new(1,bins).each do |i|
  MIN = min + i * bins
  MAX = min + (i + 1) * bins - 1
  filter_array = []
  filter_array = price_array.select{|x| x>=MIN}.select{|x| x<=MAX}

  label  = "#{MIN.to_s} ~ #{MAX.to_s}"
  label_array.push(label)
  dosuu = filter_array.length
  data_array.push(dosuu)
end
puts data_array.sum
puts length
puts data_array
puts label_array

puts label_array.to_json
