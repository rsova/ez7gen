require_relative 'service/utils'
class StructureParser
include Utils

  attr_accessor :encodedSegments, :idx
  # attr_reader :regExOp, :regExRep

  REGEX_OP =/(?=\[((?:[^\[\]]*|\[\g<1>\])*)\])/
  PRNTHS_OP = '[]'
  REGEX_REP =/(?=\{((?:[^{}]*|\{\g<1>\})*)\})/
  PRNTHS_REP = '{}'

  # @encodedSegments =[]
  # idx = 0
  def initialize
    @encodedSegments = []
    @idx = 0
  end

  def process_struct(struct)
    process_opt_groups(struct)
    process_rep_groups(struct)



    @encodedSegments.map!{|seg|

     if((seg.scan(REGEX_OP).size()>1 || seg.scan(REGEX_REP).size()>1))
       # p seg
       # seg[0] = ''
       # seg[-1] = ''
       # p seg
       # process_struct(seg)

       groupMarker = nil
       if(seg[0] == PRNTHS_OP[0])
         groupMarker = OptionalGroup.new()
       elsif(seg[0] == PRNTHS_REP)
         groupMarker = RepeatingGroup.new()
       end

       #trim to strip group marker and ~ folloing it from the front and back
       # if(groupMarker)
       # seg = seg[1..-1]
       # p seg
       # # end
       seg[0] = ''
       seg[-1] = ''
       # p seg
       process_struct(seg)

       # wrap group if marker exists
       (groupMarker)?groupMarker.mark(seg):seg
     else
        seg
     end

    }
  end

  def process_opt_groups(struct)
    process(struct, REGEX_OP, PRNTHS_OP)
  end

  def process_rep_groups(struct)
    process(struct, REGEX_REP, PRNTHS_REP)
  end

  def process(structure, regEx, prnths)
    # @prnths = prnths
    # prnth_mtch = @prnths[0]

    groups = []
    # el_ids = []

    ms = structure.scan(regEx)
    # ms = structure.scan(/(?=\{((?:[^{}]*|\{\g<1>\})*)\})/)

    ms.each {|a|

      # m = parenthesis_wrap(a.first())
      m = Marker.mark(a.first(), prnths)

      # is_g = (m.include?(prnth_mtch))

      if(groups.empty?)
        replace(structure, m)
        # structure.sub!(m, @idx.to_s)
      else
        if(groups.last().include?(m))
          # groups.last().sub!(m, @idx.to_s)
          replace(groups.last, m)
          if(!is_group?(groups.last, prnths)) #done resolving a group
            # @encodedSegments[el_ids.last()] = groups.last()
            groups.pop()
            # el_ids.pop()
          end
        else
          # structure.sub!(m, @idx.to_s)
          replace(structure, m)
        end
      end

      if (is_group?(m, prnths))
        groups << m
        # el_ids << @idx
      end

      @encodedSegments << m
      @idx +=1
  }
  end

  # check if there are inside elements of sub-groups defined by the same parenthesis
  def is_group?(str, prnths)
    # prnth_mtch = @prnths[0]
    # prnth_mtch = prnths[0]
    (str.scan(prnths[0]).size > 1)# outside paranthesis expected
  end

  def replace(str, m)
    str.sub!(m, @idx.to_s)
  end

  # wrap a match in parantesis used to brake structure into sub structures
  def parenthesis_wrap(m)
    @prnths.clone.insert(1, m)
  end

  def handle_groups(segments)

    #find groups and decode the group elements and put them in array
    segments.map!{ |seg|
    #@encodedSegments.map!{ |seg|
      # groupFound, tokens = is_group?(seg)
      if(is_complex_group?(seg))
        # seg = seg.split(/[~\{\[\}\]]/).delete_if{|it| blank?(it)}
        # groupMarker = Marker.gen(seg)
        seg = Marker.gen(seg)
        #substitute encoded group elements with values
        # if(!seg.instance_of? Array)
        # if(!seg.kind_of? Array)
        #   seg = seg.split(/[~\{\[\}\]]/).delete_if{|it| blank?(it)}
        # end

        if(seg.kind_of? Array)
        # tokens.map!{|it| is_number?(it)? encodedSegments[it.to_i]: it}.flatten
        #   seg.map!{|it| is_number?(it)? @encodedSegments[it.to_i]: it}.flatten
          seg.resolve(@encodedSegments)
        else
          is_number?(seg)? @encodedSegments[it.to_i] : seg
        end
        # seg = groupMarker.mark(seg)
        seg = handle_groups(seg)
      else
        seg
      end
    }
    return segments
  end

  # check if encoded segment is a group
  def is_complex_group?(encoded)

    # ignore arrays, they have already been resolved
    return  false if(encoded.instance_of?(Array))

    # group has an index of encoded optional element
    isGroupWithEncodedElements = ((encoded =~ /\~\d+\~/) || is_number?(encoded)) ? true: false

    # # group consists of all required elements {~MRG~PV1~}, so look ahead for that
    # subGroups = encoded.split(/[~\{\[\}\]]/).delete_if{|it| blank?(it)}
    # isGroupOfRequiredElements = (subGroups.size > 1)? true: false
    #
    # return (isGroupWithEncodedElements || isGroupOfRequiredElements), subGroups
  end
end

class Group < Array
include Utils
  def initialize(*several_variants)
    if(several_variants!= nil && several_variants[0].instance_of?(String))
      several_variants = several_variants[0].split('~').delete_if{|it| it.empty?}
    end
    super(several_variants)
  end

  def resolve(encodedSegments)
    # self.each{|sub|
      self.map!{|it| is_number?(it)? encodedSegments[it.to_i]: it}.flatten
    # }
  end
end

class OptionalGroup < Group
  # def initialize(*several_variants)
  #   if(several_variants!= nil && several_variants[0].instance_of?(String))
  #     several_variants = several_variants[0].split('~').delete_if{|it| it.empty?}
  #   end
  #   super(several_variants)
  # end

  def mark(group, prnths=StructureParser::PRNTHS_REP)
    if (group.kind_of?(String))
      group = Marker.mark(group, prnths)
    elsif(group.kind_of?(Array))
      group = OptionalGroup.new(group)
    end
  end
end

class RepeatingGroup < Group
  # include Marker
  def mark(group, prnths=StructureParser::PRNTHS_REP)
    if (group.kind_of?(String))
      group = Marker.mark(group, prnths)
    elsif(group.kind_of?(Array))
      group = RepeatingGroup.new(group)
    end
  end
end

# class OptRepeatingGroup < Array
#   # include Marker
#   def mark(group, prnths=StructureParser::PRNTHS_REP)
#     if (group.kind_of?(String))
#       group = Marker.mark(group, prnths)
#     elsif(group.kind_of?(Array))
#       group = RepeatingGroup.new(group)
#     end
#   end
# end

# class Marker
class Marker
# include Utils

  # def self.gen(str)
  #   prhths = "#{str[0]+str[-1]}"
  #   if(prhths == StructureParser::PRNTHS_REP)
  #     RepeatingGroup.new()
  #   elsif(prhths == StructureParser::PRNTHS_OP)
  #
  #     OptionalGroup.new()
  #   end
  # end
  @@opt = /\[~([^\[\]]*)~\]/
  @@rpt= /\{~([^\[\]]*)~}/
  @@match_regex = Regexp.union(@@opt, @@rpt)
  OPT = 1
  RPT = 2

  def self.gen(segment)
    marker = nil

    mtch = segment.match(@@match_regex)
    return nil if(!mtch)
    # seg = (mtch[Marker:OPT])?mtch[Marker:OPT]:mtch[Marker:RPT]
    if(mtch[Marker::OPT])
      marker = OptionalGroup.new(mtch[Marker::OPT])
      # check for optional repeating
      if(repMarker = Marker.gen(mtch[Marker::OPT]))
       marker= marker.clear.push(repMarker)
      end
    elsif(mtch[Marker::RPT])
      marker = RepeatingGroup.new(mtch[Marker::RPT])
    end
    return marker
  end

  def self.mark(group, prnths)
      group = prnths.clone().insert(1,group)
  end
end