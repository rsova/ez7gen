require 'yaml'
require_relative '../lib/ez7gen/service/utils'
include Utils
# require 'pathname'
d = 'MSH~MSA~[~ERR~]~[~{~NTE~}~]~QRD~[~QRF~]~[~[~PID~[~{~NTE~}~]~]~{~ORC~<~OBR~|~RQD~|~RQ1~|~RXO~|~ODS~|~ODT~>~[~{~NTE~}~]~[~{~CTI~}~]~}~]~[~DSC~]'

puts d.sub(/<(.*?)>/,['OBR','RXO'].sample())

a = 5
b = nil
a = b || a
puts a
b = 25
a = b || a
puts a
b = ''
a = b || a
puts a
exit

a = Array.new([1,2,3])

OPT =1
MLT =2
x = /\[~([^\[\]]*)~\]|\{~([^\[\]]*)~}/
opt = /\[~([^\[\]]*)~\]/
mult= /\{~([^\[\]]*)~}/

r = Regexp.union(opt, mult)
# r = /(\[~([^\[\]]*)\~])|(\{~([^\[\]]*)\~})/
# r = /(?<opt>\[~([^\[\]]*)~\])|(?<mult>\{~([^\[\]]*)~})/
# r = /(\[~([^\[\]]*)~\])|(\{~([^\[\]]*)~})/
# opt =/\[~([^\[\]]*)\~]/
# mult=//
# /\$(?<dollars>\d+)\.(?<cents>\d+)/.match("$3.67"
# a = ("[~{~IN1~7~8~}~]").split(r)
a = ("[~{~IN1~7~8~}~]").match(r)
p a
p a[OPT]
p a[MLT]
# p a.names
# p a['opt']
# p a['mult']
# p a['mult']
# a = ("{~IN1~7~8~}").match(r)
# p a.opt
# p a.mult
# a = ("IN1~7~8").match(r)
# p a.opt
# p a.mult

#first match is opt, second is mult
#
p (1..5).to_a.sample
# p [1,2,3,3,3,3,3,5,6,6,7,8].sample()

a = [1,2,3,3,3,3,3,5,6,6,7,9,2,1]
z = a.each_index.select{|i| a[i] >3}
p (a + [4,8,11] ).sort
# p a
exit
# class OrderedList < List
# end
# a = OArray.new([1,2])
# puts a.class
# puts a.instance_of?(OArray)
# puts a.instance_of?(Array)
# a.each{|it| puts it}
# bool =  a.kind_of?(Array) # => true
# p bool
#
# a = OptionalGroup.new()
# puts a.class
# puts a.instance_of?(OptArray)
# puts a.instance_of?(Array)
# a.each{|it| puts it}
# bool =  a.kind_of?(Array) # => true
# p bool

# b = a.reverse.class # => Array

# a = [1,2,3,4]
# b = OArray.new
# puts b.class
# a.concat([1,2,3,3,4])
p a[2..-2]
p "abcdef".slice(0,-1)
a = '{xyz}'
p "#{a[0]+a[-1]}"
p 'abc'[0..1]
p 'abcdef'[-2..-1]
exit

# a = '{~[~[~PID~[~PD1~]~]~[~PV1~[~PV2~]~]~[~10~]~11~]~}'
# e = a.scan(/(?=\[((?:[^\[\]]*|\[\g<1>\])*)\])/)
# p e
# exit

structure = 'MSH~[~{~NTE~}~]~[~PID~[~PD1~]~[~{~NTE~}~]~[~PV1~[~PV2~]~]~[~{~IN1~[~IN2~]~[~IN3~]~}~]~[~GT1~]~[~{~AL1~}~]~]~{~ORC~OBR~[~{~NTE~}~]~[~CTD~]~[~{~DG1~}~]~[~{~OBX~[~{~NTE~}~]~}~]~{~[~[~PID~[~PD1~]~]~[~PV1~[~PV2~]~]~[~{~AL1~}~]~{~[~ORC~]~OBR~[~{~NTE~}~]~[~CTD~]~{~OBX~[~{~NTE~}~]~}~}~]~}~[~{~FT1~}~]~[~{~CTI~}~]~[~BLG~]~}'
ms = structure.scan(/(?=\{((?:[^{}]*|\{\g<1>\})*)\})/)
#m = puts o19.scan(/[^{}]*|[^\[\]]*/)
p ms

idx = 0
encodedSegments =[]
profile=[]
# while(m = structure[@@segment_patern])
groups = []
el_ids = []

brckts = "{}"

ms.each {|a|
  p a
  m = a.first()
  brckt = brckts[0]
  is_g = (m.include?(brckt))
  m = brckts.clone.insert(1,m)

  if(groups.empty?)
      structure.sub!(m, idx.to_s)
    else
      if(groups.last().include?(m))
        groups.last().sub!(m, idx.to_s)
        if((groups.last().include?(brckt))) #done resolving a group
           encodedSegments[el_ids.last()] = groups.last()
          groups.pop()
          el_ids.pop()
        end
      else
        structure.sub!(m, idx.to_s)
      end
    end

  if (is_g)
    groups << m
    el_ids << idx
  end

  encodedSegments << m
  idx +=1
}
puts '_________1_____________'

ms = structure.scan(/(?=\[((?:[^\[\]]*|\[\g<1>\])*)\])/)
#m = puts o19.scan(/[^{}]*|[^\[\]]*/)
p ms
brckts = "[]"

ms.each {|a|
  p a
  m = a.first()
  brckt = brckts[0]
  is_g = (m.include?(brckt))
  m = brckts.clone.insert(1,m)

  if(groups.empty?)
    structure.sub!(m, idx.to_s)
  else
    if(groups.last().include?(m))
      groups.last().sub!(m, idx.to_s)
      if((groups.last().include?(brckt))) #done resolving a group
        encodedSegments[el_ids.last()] = groups.last()
        groups.pop()
        el_ids.pop()
      end
    else
      structure.sub!(m, idx.to_s)
    end
  end

  if (is_g)
    groups << m
    el_ids << idx
  end

  encodedSegments << m
  idx +=1
}


# ms.each {|a|
#   p a
#
#   is_g = (a.scan('[').size > 1)?true:false
#   m = '['<< a.first() << ']'
#
#   if(groups.size == 0)
#     structure.sub!(m, idx.to_s)
#     # if (is_g) then groups << m end
#   else
#     if(groups.last().include?(m))
#       groups.last().sub!(m, idx.to_s)
#       if(!(groups.last().scan('[').size > 1)) #done resolving a group
#       # if(is_group_resolved(groups.last(), '[')) #done resolving a group
#         rslvd = groups.last()
#         eid = el_ids.last()
#         encodedSegments[eid] = rslvd
#         groups.pop()
#         el_ids.pop()
#       end
#     else
#       structure.sub!(m, idx.to_s)
#     end
#     # if (is_g) then groups << m end
#   end
#
#   if (is_g)
#     groups << m
#     el_ids << idx
#   end
#
#   encodedSegments << m
#   idx +=1
# }


puts '_________2_____________'

encodedSegments.each{|es|
  puts es

    is_g = (es.scan('[').size > 1)?true:false

    if(is_g)
      ms = es.scan(/(?=\[((?:[^\[\]]*|\[\g<1>\])*)\])/)

      # # m = '['<< e.first() << ']'
      # puts e
      # puts '++'

      ms.each {|a|
        p a
        is_g = (a.scan('[').size > 1)?true:false
        m = '['<< a.first() << ']'

        if(groups.size == 0)
          es.sub!(m, idx.to_s)
          # if (is_g) then groups << m end
        else
          if(groups.last().include?(m))
            groups.last().sub!(m, idx.to_s)
            if(!(groups.last().scan('[').size > 1)) #done resolving a group
            #if(is_group_resolved(groups.last(), '[')) #done resolving a group
              rslvd = groups.last()
              eid = el_ids.last()
              encodedSegments[eid] = rslvd
              groups.pop()
              el_ids.pop()
            end
          else
            es.sub!(m, idx.to_s)
          end
          # if (is_g) then groups << m end
        end

        if (is_g)
          groups << m
          el_ids << idx
        end

        encodedSegments << m
        idx +=1
      }

    end

}

puts groups
puts encodedSegments
puts structure

# def self.is_group_resolved(seg, group_token)
#   (seg.scan(group_token).size > 1)?true:false
# end

exit


#ORM_O01 Order message
# MSH;NTE;PID;PD1;PV1;PV2;IN1;IN2;IN3;GT1;AL1;ORC;OBR;RQD;RQ1;RXO;ODS;ODT;CTD;DG1;OBX;FT1;CTI;BLG
#RDE_O11 Pharmacy/treatment encoded order message
# MSH;NTE;PID;PD1;PV1;PV2;IN1;IN2;IN3;GT1;AL1;ORC;RXO;RXR;RXC;OBX;CTI
#OMG_O19 General clinical order message
# MSH;NTE;PID;PD1;PV1;PV2;IN1;IN2;IN3;GT1;AL1;ORC;OBR;CTD;DG1;OBX;AL1;FT1;CTI;BLG
o19 = 'MSH~[~{~NTE~}~]~[~PID~[~PD1~]~[~{~NTE~}~]~[~PV1~[~PV2~]~]~[~{~IN1~[~IN2~]~[~IN3~]~}~]~[~GT1~]~[~{~AL1~}~]~]~{~ORC~OBR~[~{~NTE~}~]~[~CTD~]~[~{~DG1~}~]~[~{~OBX~[~{~NTE~}~]~}~]~{~[~[~PID~[~PD1~]~]~[~PV1~[~PV2~]~]~[~{~AL1~}~]~{~[~ORC~]~OBR~[~{~NTE~}~]~[~CTD~]~{~OBX~[~{~NTE~}~]~}~}~]~}~[~{~FT1~}~]~[~{~CTI~}~]~[~BLG~]~}'
# mt = /(?=\{((?:[^{}]*|\{\g<1>\})*)\})/.match(o19)
# mt = o19.scan(/(?=\{((?:[^{}]*|\{\g<1>\})*)\})/)
# # [["~NTE~"], ["~NTE~"], ["~IN1~[~IN2~]~[~IN3~]~"], ["~AL1~"], ["~ORC~OBR~[~{~NTE~}~]~[~CTD~]~[~{~DG1~}~]~[~{~OBX~[~{~NTE~}~]~}~]~{~[~[~PID~[~PD1~]~]~[~PV1~[~PV2~]~]~[~{~AL1~}~]~{~[~ORC~]~OBR~[~{~NTE~}~]~[~CTD~]~{~OBX~[~{~NTE~}~]~}~}~]~}~[~{~FT1~}~]~[~{~CTI~}~]~[~BLG~]~"], ["~NTE~"], ["~DG1~"], ["~OBX~[~{~NTE~}~]~"], ["~NTE~"], ["~[~[~PID~[~PD1~]~]~[~PV1~[~PV2~]~]~[~{~AL1~}~]~{~[~ORC~]~OBR~[~{~NTE~}~]~[~CTD~]~{~OBX~[~{~NTE~}~]~}~}~]~"], ["~AL1~"], ["~[~ORC~]~OBR~[~{~NTE~}~]~[~CTD~]~{~OBX~[~{~NTE~}~]~}~"], ["~NTE~"], ["~OBX~[~{~NTE~}~]~"], ["~NTE~"], ["~FT1~"], ["~CTI~"]]
# puts mt
# /(\((?:([^\(\)]*)|(?:\g<2>\g<1>\g<2>)*)\))/
# m = /(\((?:([^\{\}]*)|(?:\g<2>\g<1>\g<2>)*)\))/.match(o19)
# p m
  idx = 0
  encodedSegments =[]
# m = o19.scan(/(?=\{((?:[^{}]*|\{\g<1>\})*)\})/)
# p m
# m = /(?=\{((?:[^{}]*|\{\g<1>\})*)\})/.match(o19)
# p m

  # while(m = (structure.match(@@segment_patern).to_s))
  abc = o19
  xyz = ''
  m = abc.scan(/(?=\{((?:[^{}]*|\{\g<1>\})*)\})/)
p m

# /(?=\{((?:[^{}]*|\{\g<1>\})*)\})/.match(abc){|it|
#   p it
# }

p o19
    p abc
    puts m
    p m[1]
    m.each{|it|
      # p m.begin
      # p m.end
      p m.first.begin
      p m.first.end

      mtch = it.first.to_s
      o19.sub!(mtch,idx.to_s)
      encodedSegments << mtch
      idx +=1
    }
    abc = m.post_match

  m = abc.match(/(?=\{((?:[^{}]*|\{\g<1>\})*)\})/)
  p o19
  p abc
  p m
  p m[1]
  o19.sub!(m[1],idx.to_s)
  encodedSegments << m
  idx +=1
  abc = m.post_match

  m = abc.match(/(?=\{((?:[^{}]*|\{\g<1>\})*)\})/)
  p o19
  p abc
  p m
  p m[1]
  o19.sub!(m[1],idx.to_s)
  encodedSegments << m
  idx +=1
  abc = m.post_match

p '!!!!!!!!!!'
exit

puts '[~17~19~20~{~21~OBR~22~23~{~OBX~24~}~}~]'.scan(/[\[\]]/).size()
puts '[~17~19~20~{~21~OBR~22~23~{~OBX~24~}~}~]'.scan(/[\{\}]/).size()
puts '[~17~19~20~{~21~OBR~22~23~{~OBX~24~}~}~]'.scan(/[\{\}\[\]]/).size()

puts '[~17~19~20~{~21~OBR~22~23~{~OBX~24~}~}~]'.scan(/[\{\}\[\]]/).size().odd?

puts  '{~ORC~OBR~11~12~13~15~{~25~}'.scan(/[\{\}\[\]]/).size
puts  '{~ORC~OBR~11~12~13~15~{~25~}'.scan(/[\{\}\[\]]/).size.even?

m = '{~ORC~OBR~11~12~13~15~{~25~}'
puts 'MSH~0~10~{~ORC~OBR~11~12~13~15~{~25~}~[~{~FT1~}~]~[~{~CTI~}~]~[~BLG~]~}'.scan(/[\[\]]/).size


a25 ='[~17~19~20~{~21~OBR~22~23~{~OBX~24~}~}~]'
a= 'MSH~0~10~{~ORC~OBR~11~12~13~15~{~[~17~19~20~{~21~OBR~22~23~{~OBX~24~}~}~]~}~[~{~FT1~}~]~[~{~CTI~}~]~[~BLG~]~}'

a26 = '{~ORC~OBR~11~12~13~15~{~25~}'
struct ='MSH~0~10~{~ORC~OBR~11~12~13~15~{~25~}~[~{~FT1~}~]~[~{~CTI~}~]~[~BLG~]~}'
b = struct.sub('25',a25)
puts a
puts b
puts a.eql?(b)

sq = /[\[\]]/
crl = /[\{\}]/
if( a26.scan(sq).size.odd?)
  puts ((a26.scan(/\[/).size - a26.scan(/\]/).size) <0) ?']':'['
end

if( a26.scan(crl).size.odd?)
  puts ((a26.scan(/\{/).size - a26.scan(/\}/).size) <0) ?'{':'}'
end

p '+++++++++++'
puts struct

mt = struct.scan(/(?=\{((?:[^{}]++|\{\g<1>\})++)\})/)
p mt
mt = struct.scan(/(?=\{((?:[^{}]*|\{\g<1>\})*)\})/)
p mt
mt = /(?=\{((?:[^{}]*|\{\g<1>\})*)\})/.match(struct)
p mt

# mt = /[^{}]*/.match(struct)
# p mt
# mt = /(?<={)\*(?=})/.match(struct) #nothing
# p mt
# mt = /\{([^\[\]]*)\}/.match(struct) #wrong
# p mt

p '~~~~~~~'
exit

mt = /\[([^\[\]]*)\]|\{([^\[\]]*)\}/.match(struct)
p mt
# mt = /(\((?:([^\(\)]*)|(?:(?2)(?1)(?2))*)\))/.match("(a)")
# http://stackoverflow.com/questions/19486686/recursive-nested-matching-pairs-of-curly-braces-in-ruby-regex
mt = /(\((?:([^\{\}]*)|(?:\g<1>({\g<1>\})({\g<2>\}))*)\))/.match(struct)
# (?=\{((?:[^{}]++|\{\g<1>\})++)\})
p mt
mt = /\{*\}/.match(struct)
p mt
#     /(?=\{((?:[^{}]++|\{\g<1>\})++)\})/
# mt = /(\((?:([^\(\)]*)|(?:(\2)(\1)(\2))*)\))/.match("(a)")
mt = /(\((?:([^\(\)]*)|(?:(?<out>)(?<in>)(?<out>))*)\))/.match("((c))")
mt = /(\((?:([^\(\)]*)|(?:\g<2>\g<1>\2<1>)*)\))/.match("((c)a)")
mt = /(\((?:([^\(\)]*)|(?:\g<2> \g<1> \g<2>)*)\))/.match("(((c)a)v)")
p mt
str = "The {quick} brown fox {jumps {over {deep} the} {sfsdf} lazy} dog {sdfsdf {sdfsdf}"
mt = str.scan(/(?=\{((?:[^{}]++|\{\g<1>\})++)\})/)
p mt

p '============'

exit
idx = b.index(a25)+a25.size
puts b[idx,b.size]

var = 'stac'
puts /#{var}/.match('haystack')

puts /(?<=<b>)\w+(?=<\/b>)/.match("Fortune favours the <b>bold</b>")
puts /(?<={)\w+(?=})/.match("Fortune favours the {bold}")
# $~ is equivalent to ::last_match;
# $& contains the complete matched text;
# $` contains string before match;
# $' contains string after match;
# $1, $2 and so on contain text matching first, second, etc capture group;
# $+ contains last capture group.

m = /s(\w{2}).*(c)/.match('haystack') #=> #<MatchData "stac" 1:"ta" 2:"c">
puts $~                                    #=> #<MatchData "stac" 1:"ta" 2:"c">
puts Regexp.last_match                     #=> #<MatchData "stac" 1:"ta" 2:"c">

puts $&      #=> "stac"
# # same as m[0]
puts  $`      #=> "hay"
 # same as m.pre_match
puts  $'      #=> "k"
# # same as m.post_match
puts $1      #=> "ta"
# # same as m[1]
# $2      #=> "c"
# # same as m[2]
# $3      #=> nil
# # no third group in pattern
# $+      #=> "c"
# # same as m[-1]
puts $+
ex ='[([^\[\]]*)\]|\{([^\[\]]*)\}'
#(?<={)[[:alnum:]~]+(?=})
puts Regexp.escape('[]')
puts Regexp.union(/dogs/, /cats/i)
puts Regexp.union(/\[([^\[\]]*)\]/,/\{([^\[\]]*)\}/)
/^[a-z]*$/ === "HELLO" #=> false
/^[A-Z]*$/ === "HELLO" #=> true

/(?<lhs>\w+)\s*=\s*(?<rhs>\w+)/ =~ "  x = y  "
p lhs    #=> "x"
p rhs    #=> "y"
#metacharacthers (, ), [, ], {, }, ., ?, +, *
mt = /[cs](..) [cs]\1 in/.match("The cat sat in the hat")
p mt[1]
p mt[2]
p /[aeiou]\w{2}/.match("Caenorhabditis elegans")
p /([aeiou]\w){2}/.match("Caenorhabditis elegans")
mt= /I(n)ves(ti)ga\2ons/.match("Investigations")
p mt[1] + '....' + mt[2]
mt= /I(?:n)ves(ti)ga\1ons/.match("Investigations")
p mt[1] + '....' + mt[2].to_s
# Finds the outermost pair of parentheses. Compatible with any amount of nesting
#/(\((?:([^\(\)]*)|(?:(?2)(?1)(?2))*)\))/
# /(\((?:([^\(\)]*)|(?:\g<1>)*)\))/
#     /(?=\{((?:[^{}]++|\{\g<1>\})++)\})/
# mt = /(\((?:([^\(\)]*)|(?:(\2)(\1)(\2))*)\))/.match("(a)")
mt = /(\((?:([^\(\)]*)|(?:(?<out>)(?<in>)(?<out>))*)\))/.match("((c))")
mt = /(\((?:([^\(\)]*)|(?:\g<1>)*)\))/.match("((c))")
p mt
p '----------------'
mt=/\A(?<paren>\(<paren>*\))*\z/ =~ "a()"
p mt
# result = a.scan(/(?=\{((?:[^{}]++|\{\g<1>\})++)\})/)
# p result

exit

# p = "\\Users\\romansova\\RubymineProjects\\ez7gen-staged\\ez7gen-web\\README.md"
# p = %w("\Users\romansova\RubymineProjects\ez7gen-staged\ez7gen-web\README.md")
# puts p.class
# puts p.gsub(File::SEPARATOR, File::ALT_SEPARATOR || File::SEPARATOR)
p = '\Users\romansova\RubymineProjects\ez7gen-staged\ez7gen-web\README.md'
p = 'c:\ez7Gen\ez7gen-web\config\resources'
puts p
a = p.gsub("\\", '/')
a = File.join(a, '/schmea/resources/')
# a = p.gsub(File::ALT_SEPARATOR || File::SEPARATOR, '/')
puts a
exit

p = "/Users/romansova/RubymineProjects/ez7gen-staged/ez7gen-web"
dir, base = File.split(p)
puts "dir: " + dir
puts "base:" + base
puts

# path = Pathname.new(p)
# puts path.realpath()

nm = Dir.glob("#{p}*").select {|f| File.directory? f}
puts nm
exit

time = Time.new
puts time
time = Time.new.strftime("%Y%m%d%H%M%S%L")
puts time
time = Time.new.strftime("%Y-%m-%d %H:%M:%S.%L")
puts time

# path = Dir.new("/Users/romansova/RubymineProjects/ez7gen-staged/ez7gen-web/config/schema")
# p =  Dir.glob '/Users/romansova/RubymineProjects/ez7gen-staged/ez7gen-web/config/**'
# puts p
# d = Dir.glob('/Users/romansova/RubymineProjects/ez7gen-staged/ez7gen-web/config/schema/**').select {|f| File.directory? f}
# puts d
 # path.each{|it| puts it }
# path.glob('*').select {|f| File.directory? f}
dir = '/Users/romansova/RubymineProjects/ez7gen-staged/ez7gen-web/config/schema/'
# pn = Pathname.new(dir).children.select { |c| c.directory? }
# pn = Pathname.new(dir).children.select { |c| c.directory? }
# names = Pathname.new(dir).children.inject([]) { |files, c| (c.directory? ? (files << c) : files) }
names = Dir.glob("#{dir}**").select {|f| File.directory? f}#.each{|it| it.sub!(dir,'')}
# names = Dir.glob(dir<<'/**').inject([]){|files,f| (f.directory? ? (files<<f) : files)}
puts names


exit


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
