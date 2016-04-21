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

  # takes a message structure and converts it into array of processed segments, ready for building hl7
  def process_segments(struct)
    process_struct(struct)
    handle_groups(@encodedSegments)
  end

  def process_struct(struct)
    #process original segments and build encoded segmets
    process_opt_groups(struct)
    process_rep_groups(struct)

    #check encoded segments to find and process segments which have subgroups
    @encodedSegments.map!{|seg|
     #has more subgroups
     if(has_subgroups?(seg))
       groupMarker = Marker.whatGroup?(seg)

       #unwrap for recursive processing
       process_struct(groupMarker.unwrap(seg))

       # wrap group back to restore the original segment
       groupMarker.mark(seg)
       # (groupMarker)?groupMarker.mark(seg):seg

     else
        seg
     end
    }
  end

  # handle groups in the array of ecnoded segments
  # groups and subgroups organized as Arrays with specific Markers
  def handle_groups(segments)
    #find groups and decode the group elements and put them in array
    segments.map!{ |seg|
      if(is_complex_group?(seg))

        # Generate marker for the segment to preserve specifics of type of the group - opt. vs repeating.
        seg = Marker.gen(seg)
        if(seg.kind_of? Array)# TODO: Refactor, check not needed?
          seg.resolve(@encodedSegments)
        else
          is_number?(seg)? @encodedSegments[it.to_i] : seg
        end
        handle_groups(seg)
        # seg = handle_groups(seg)
      else
        seg
      end
    }
    return segments
  end

  # checks a segment for subgroups
  def has_subgroups?(seg)
    inner = remove_outer_parenthesis(seg)
    # inner segment should have no groups identified by {} or []
    inner =~ /[\[{]/
  end

def remove_outer_parenthesis(seg)
  regexOptOuter = /^\[~(.*?)~\]$/
  regExRepOuter = /^{~(.*?)~}$/
  # (seg.scan(REGEX_OP).size()>1 || seg.scan(REGEX_REP).size()>1)
  # look for the outer parenthesis [] - opt
  # innerSeg =  seg.scan(/\[~{~(.*)~}~\]|\[~(.*)~\]|{~(.*)~}/)
  # innerOpt=  seg.scan(/^\[~(.*?)~\]/)
  innerOpt= seg.scan(regexOptOuter)
  innerOpt = (innerOpt.empty?) ? nil : innerOpt.flatten.first

  # look for outer {} - rep
  innerRep = (innerOpt) ? innerOpt.scan(regExRepOuter) : seg.scan(regExRepOuter)
  innerRep = (innerRep.empty?) ? nil : innerRep.flatten.first


  inner = innerRep || innerOpt || seg
end

  # process groups with optional markers - []
  def process_opt_groups(struct)
      process(struct, REGEX_OP, PRNTHS_OP)
  end

  # process groups with repeating markers - {}
  def process_rep_groups(struct)
    process(struct, REGEX_REP, PRNTHS_REP)
  end

  #process group using regular expression and specific pharenthesis as markers
  def process(structure, regEx, prnths)
    groups = []

    # brake up the structure into array of subgroups
    # using recursive regEx
    subGroups = structure.scan(regEx)

    subGroups.each {|subGroup|

      # m = parenthesis_wrap(a.first())
      # group boundaries - parenthesis, stripped by regEx
      # put the parenthesis back for processing
      groupElement = Marker.mark(subGroup.first(), prnths)

      # process an array of matches and substitute subgroups
      if(groups.empty?)
        replace(structure, groupElement)
      else
        if(groups.last().include?(groupElement))
          replace(groups.last, groupElement)
          if(!is_group?(groups.last, prnths)) #done resolving a group
            groups.pop()
          end
        else
          replace(structure, groupElement)
        end
      end

      if (is_group?(groupElement, prnths))
        groups << groupElement
      end

      # resolved group added to encoded segments
      @encodedSegments << groupElement
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

  # check if encoded segment is a group
  def is_complex_group?(encoded)

    # ignore arrays, they have already been resolved
    return  false if(encoded.kind_of?(Array))

    # group has an index of encoded optional element
    # isGroupWithEncodedElements = ((encoded =~ /\~\d+\~/) || is_number?(encoded)) ? true: false
    isGroupWithEncodedElements = (encoded =~ /\~\d+\~/) ? true: false
    return isGroupWithEncodedElements if(isGroupWithEncodedElements)

    inner = remove_outer_parenthesis(encoded)
    subGroups = inner.split('~')
    (subGroups.size > 1)? true: false

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
      # p self
      self.map!{|sub|
        if(sub.kind_of?(Array))
          sub.map!{|it|is_number?(it)? encodedSegments[it.to_i]: it}.flatten
        else
           is_number?(sub)? encodedSegments[sub.to_i]: sub
        end
      }.flatten
    # p self
  end

  #unwrap outer parenthesis.
  # this works vs. seg = seg[1...-1] TODO: Refactor?
  def unwrap(seg)
    seg[0] = ''
    seg[-1] = ''
    return seg
  end
end

class OptionalGroup < Group

  def mark(group, prnths=StructureParser::PRNTHS_OP)
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

# class Marker
class Marker
# include Utils

  @@opt = /\[~([^\[\]]*)~\]/
  @@rpt= /\{~([^\[\]]*)~}/
  @@match_regex = Regexp.union(@@opt, @@rpt)
  OPT = 1
  RPT = 2

  # decided that segment has subgroups
  def self.gen1(segment)
    marker = nil

    # 1 no match - just to cover bases
    marker = whatGroup?(segment)
    return nil if(!marker)# done if nothing to match

    # if(mtch[Marker::OPT])# 2 optional
    #   marker = OptionalGroup.new(mtch[Marker::OPT])
    #   # # check for optional repeating
    # elsif(mtch[Marker::RPT])# 3 repeating
    #   marker = RepeatingGroup.new(mtch[Marker::RPT])
    # end

    # 3 repeating

    # 4 if optional check for optional-repeating

      # if(mtch[Marker::OPT])
      #   marker = OptionalGroup.new(mtch[Marker::OPT])
      #   # # check for optional repeating
      #   if(repeatingSubMarker = Marker.gen(mtch[Marker::OPT]))
      #    marker= marker.clear.push(repeatingSubMarker)
      #   end
      # elsif(mtch[Marker::RPT])
      #   marker = RepeatingGroup.new(mtch[Marker::RPT])
      # end
      return marker

  end

  def self.gen(segment)
    marker = nil

    mtch = segment.match(@@match_regex)
    return nil if(!mtch)# done if nothing to match

    # seg = (mtch[Marker:OPT])?mtch[Marker:OPT]:mtch[Marker:RPT]
    if(mtch[Marker::OPT])
      marker = OptionalGroup.new(mtch[Marker::OPT])
      # # check for optional repeating
      if(repeatingSubMarker = Marker.gen(mtch[Marker::OPT]))
       marker= marker.clear.push(repeatingSubMarker)
      end
    elsif(mtch[Marker::RPT])
      marker = RepeatingGroup.new(mtch[Marker::RPT])
    end
    return marker
  end

  # def self.match_for_complex_group(segment)
  #   mtch = segment.match(@@match_regex)
  # end

  def self.mark(group, prnths)
      group = prnths.clone().insert(1,group)
  end

  def self.whatGroup?(segment)
    group = nil
    mtch = segment.match(@@match_regex)
    return group if(!mtch)# done if nothing to match

    if(mtch[Marker::OPT])
       OptionalGroup.new()
     elsif(mtch[Marker::RPT])
       RepeatingGroup.new()
    end

  end

end