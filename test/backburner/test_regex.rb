require "minitest/autorun"

class TestRegex < MiniTest::Unit::TestCase

	def test_match1
	str = "MSH~EVN~PID~[~PD1~]~[~{~ROL~}~]~[~{~NK1~}~]~PV1~[~PV2~]~[~{~ROL~}~]~[~{~DB1~}~]~[~{~OBX~}~]~[~{~AL1~}~]~[~{~DG1~}~]~[~DRG~]~[~{~PR1~[~{~ROL~}~]~}~]~[~{~GT1~}~]~[~{~IN1~[~IN2~]~[~{~IN3~}~]~[~{~ROL~}~]~}~]~[~ACC~]~[~UB1~]~[~UB2~]~[~PDA~]"
	#p = str =~/\[([^\[\]]*)\]/
	#u = str.gsub(/\[([^\[\]]*)\]/,"*")
	segment_patern = /\[([^\[\]]*)\]/
	idx = 0
	segments =[]
	# m
	 while(m = str.match(segment_patern).to_s)
	#while(m = str[/\[([^\[\]]*)\]/])
		str.sub!(segment_patern,idx.to_s)
		puts "~~~~~" + m
		segments << m.to_s
		idx +=1
		puts str
		# if(idx == 100) then (); end
	end
	p segments
		# puts u 
	# puts p
	end
end