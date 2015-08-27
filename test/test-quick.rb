require 'yaml'
file = File.open('properties.yml')
yml = YAML::load(file)
puts yml['user'] # juixe-username

# yml = YAML.load_file 'properties.yml'
# yml.each_pair { |key, value| puts "#{key} = #{value}" }


exit




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
