require 'yaml'



h = { "apple tree" => "plant", "ficus" => "plant",
      "shrew" => "animal", "plesiosaur" => "animal" }
p h.keys.grep /p/
# => ["apple tree", "plesiosaur"]
p h.inject([]) { |res, kv| res << kv if kv[1] =~ /p/; res }
exit
# => [["ficus", "plant"], ["apple tree", "plant"]]
p "[~{~PR1~10~}~]".split(/[~\{\[\}\]]/)
p "[~{~PR1~10~}~]".split(%r|{.*}|)
# p a

begin
  a/0
rescue => e
  raise e
  puts 'in rescue'
  puts e
ensure
  puts 'in ensure'
end

puts 'end'

puts '%.2f' % 515.0
file = File.open('../lib/ez7gen/resources/properties.yml')
yml = YAML::load(file)
puts yml['person.names.last'][0] # juixe-username
# yml['user'] # juixe-username
puts yml['bar']

puts yml['bar'].to_a.sample(1).to_h

pair = yml['codes.allergens'].to_a.sample(1).to_h
p pair.first

# @@MONEY_FORMAT_INDICATORS = ['Money', 'Balance', 'Charge', 'Adjustment', 'Income', 'Amount', 'Payment','Cost']
reg = /\bMoney\b|\bBalance\b|\bCharge|\bAdjustment\b|\bIncome\b|\bAmount\b|\bPayment\b|\bCost\b/

str = 'Total Charges'
# exp = /\bMoney\b|\bBalance\b/
case str
  # when /\bMoney\b|\bBalance\b|\bCharge\b|\bAdjustment\b|\bIncome\b|\bAmount\b|\bPayment\b|\bCost\b/
  when reg
    puts 'when'
  else
    puts 'else'
end



puts 'base:MSH'.delete(':base')
if('[~{~ZMH~}~]'=~/\~Z/)
  puts 'ok!'
end
# arr = [6,2, 5]
# p arr.find_index{|it| it>13}
#
# arr = ['1','a','3','4','b','5','6','c','7']
# p arr.delete_if{|it| it.is}
#
# p ['1','a','3','4','b','5','6','c','7'].index(arr)
# # p arr.delete_if{|it| it.is}

if("Hello"=~/^[A-Z][a-z]+$/)
  puts 'ok'
end

exit
code =nil
code ||='bla'
puts code
exit
yml = YAML.load_file 'properties.yml'
puts yml['person.names.first'][0]
puts yml['address.streetNames']

#yml.each_pair { |key, value| puts "#{key} = #{value}" }

#puts yml['juixe']['user'] # juixe-username

exit
puts "Result is %.2f" % 1000
mfi = ['Balance', 'Charges', 'Adjustments', 'Income', 'Amount', 'Money']
puts mfi.include?('Balance')

h1 = { "a" => 100, "b" => 200, 'c' => "c" }
p h1.update({'a' => 11,'b'=>2 })
exit
line = "100,200,300"

# Split on the comma char.
values = line.split(",")
puts values

line = "[max_length:250, description:Organization Unit Type - ROL, ifrepeating:0, datatype:CE, required:O, piece:10, codetable:406]"
values = line.gsub(/(\[|\])/,'').gsub(':',',').split(',').map{|it| it.strip()}.each_slice(2).to_a.to_h


#values = line.gssplit(",")
puts values
puts '_______'


exit
val =[]
val << '200'
val<<'abc'<<'123'
p val
puts val.join('|')
exit

# file = File.open('properties.yml')
# yml = YAML::load(file)
# puts puts yml['juixe']['user'] # juixe-username
# yml['user'] # juixe-username
# exit

yml = YAML.load_file 'properties.yml'
puts yml['person.names.first'][0]
puts yml['address.streetNames']

#yml.each_pair { |key, value| puts "#{key} = #{value}" }

#puts yml['juixe']['user'] # juixe-username

#exit

map = {'required'=>'X'}
check = if(['X','W','B'].include?(map['required'])) then true end
puts check 
puts "~~~~~~~~~~"

map = {'required'=>'A'}
check = if(['X','W','B'].include?(map['required'])) then true end
puts check 
exit 

code, description = 'bla', 'bla1'
puts code + " " + description
puts"1".to_i

codes = 
1.times do |i|
    puts i
end
codes = []
codes << {'a'=>1, 'b'=>1, 'c'=>3}
codes << {'a'=>10, 'b'=>11, 'c'=>12}
codes << {'a'=>20, 'b'=>21, 'c'=>23}

puts codes
puts "------------"
codes.select! {|map| map['a'] > 5 }
puts codes

puts codes.include?('a')
puts codes.find('a')

range = 1..5
range.each {|it| puts it}

ends = '1...12'.split('...').map{|d| d}
range = ends[0]..ends[1]
range.each {|it| puts it}
#puts 'E1 ... E9'.strip(' ')
puts 'E1 ... E9'.delete(' ')

ends = 'E1 ... E9'.delete(' ').split('...').map{|it| it}
range = ends[0]..ends[1]
range.each {|it| puts it}

ends = '...'.delete(' ').split('...').map{|it| it}
puts ends.length
