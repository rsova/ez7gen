# Ez7gen

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

    gem 'ez7gen'

And then execute:

    $ bundle
    
To build a gem localy:

    $ gem build ez7gen.gemspec

Or install it yourself as:
    
    $ gem install ez7gen

## Usage

TODO: Write usage instructions here

## Contributing

1. Fork it ( https://github.com/[my-github-username]/ez7gen/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request


  1) Error:
TestMessageFactory#test_ADT_03:
ArgumentError: invalid value for Float(): "A3"
    /Users/romansova/RubymineProjects/ez7gen-staged/lib/ez7gen/service/type_aware_field_generator.rb:703:in `%'
    /Users/romansova/RubymineProjects/ez7gen-staged/lib/ez7gen/service/type_aware_field_generator.rb:703:in `NM'
    /Users/romansova/RubymineProjects/ez7gen-staged/lib/ez7gen/service/type_aware_field_generator.rb:1208:in `UVC'
    /Users/romansova/RubymineProjects/ez7gen-staged/lib/ez7gen/service/segment_generator.rb:121:in `call'
    /Users/romansova/RubymineProjects/ez7gen-staged/lib/ez7gen/service/segment_generator.rb:121:in `addField'
    /Users/romansova/RubymineProjects/ez7gen-staged/lib/ez7gen/service/segment_generator.rb:106:in `block in generateSegmentElements'
    /Users/romansova/RubymineProjects/ez7gen-staged/lib/ez7gen/service/segment_generator.rb:105:in `times'
    /Users/romansova/RubymineProjects/ez7gen-staged/lib/ez7gen/service/segment_generator.rb:105:in `generateSegmentElements'
    /Users/romansova/RubymineProjects/ez7gen-staged/lib/ez7gen/service/segment_generator.rb:83:in `generateSegment'
    /Users/romansova/RubymineProjects/ez7gen-staged/lib/ez7gen/service/segment_generator.rb:65:in `block in generate'
    /Users/romansova/RubymineProjects/ez7gen-staged/lib/ez7gen/service/segment_generator.rb:63:in `times'
    /Users/romansova/RubymineProjects/ez7gen-staged/lib/ez7gen/service/segment_generator.rb:63:in `generate'
    /Users/romansova/RubymineProjects/ez7gen-staged/lib/ez7gen/message_factory.rb:40:in `block in generate'
    /Users/romansova/RubymineProjects/ez7gen-staged/lib/ez7gen/message_factory.rb:34:in `each'
    /Users/romansova/RubymineProjects/ez7gen-staged/lib/ez7gen/message_factory.rb:34:in `generate'
    /Users/romansova/RubymineProjects/ez7gen-staged/test/message_factory_test.rb:53:in `test_ADT_03'
    /Users/romansova/.rvm/rubies/ruby-2.1.2/lib/ruby/2.1.0/minitest/unit.rb:1265:in `run'
    /Users/romansova/.rvm/rubies/ruby-2.1.2/lib/ruby/2.1.0/minitest/unit.rb:940:in `block in _run_suite'
    /Users/romansova/.rvm/rubies/ruby-2.1.2/lib/ruby/2.1.0/minitest/unit.rb:933:in `map'
    /Users/romansova/.rvm/rubies/ruby-2.1.2/lib/ruby/2.1.0/minitest/unit.rb:933:in `_run_suite'
    /Users/romansova/.rvm/rubies/ruby-2.1.2/lib/ruby/2.1.0/minitest/unit.rb:914:in `block in _run_suites'
    /Users/romansova/.rvm/rubies/ruby-2.1.2/lib/ruby/2.1.0/minitest/unit.rb:914:in `map'
    /Users/romansova/.rvm/rubies/ruby-2.1.2/lib/ruby/2.1.0/minitest/unit.rb:914:in `_run_suites'
    /Users/romansova/.rvm/rubies/ruby-2.1.2/lib/ruby/2.1.0/minitest/unit.rb:884:in `_run_anything'
    /Users/romansova/.rvm/rubies/ruby-2.1.2/lib/ruby/2.1.0/minitest/unit.rb:1092:in `run_tests'
    /Users/romansova/.rvm/rubies/ruby-2.1.2/lib/ruby/2.1.0/minitest/unit.rb:1079:in `block in _run'
    /Users/romansova/.rvm/rubies/ruby-2.1.2/lib/ruby/2.1.0/minitest/unit.rb:1078:in `each'
    /Users/romansova/.rvm/rubies/ruby-2.1.2/lib/ruby/2.1.0/minitest/unit.rb:1078:in `_run'
    /Users/romansova/.rvm/rubies/ruby-2.1.2/lib/ruby/2.1.0/minitest/unit.rb:1066:in `run'
    /Users/romansova/.rvm/rubies/ruby-2.1.2/lib/ruby/2.1.0/minitest/unit.rb:802:in `block in autorun'

  2) Error:
TestMessageFactory#test_ADT_01:
ArgumentError: invalid value for Float(): "X0"
    /Users/romansova/RubymineProjects/ez7gen-staged/lib/ez7gen/service/type_aware_field_generator.rb:703:in `%'
    /Users/romansova/RubymineProjects/ez7gen-staged/lib/ez7gen/service/type_aware_field_generator.rb:703:in `NM'
    /Users/romansova/RubymineProjects/ez7gen-staged/lib/ez7gen/service/type_aware_field_generator.rb:1208:in `UVC'
    /Users/romansova/RubymineProjects/ez7gen-staged/lib/ez7gen/service/segment_generator.rb:121:in `call'
    /Users/romansova/RubymineProjects/ez7gen-staged/lib/ez7gen/service/segment_generator.rb:121:in `addField'
    /Users/romansova/RubymineProjects/ez7gen-staged/lib/ez7gen/service/segment_generator.rb:106:in `block in generateSegmentElements'
    /Users/romansova/RubymineProjects/ez7gen-staged/lib/ez7gen/service/segment_generator.rb:105:in `times'
    /Users/romansova/RubymineProjects/ez7gen-staged/lib/ez7gen/service/segment_generator.rb:105:in `generateSegmentElements'
    /Users/romansova/RubymineProjects/ez7gen-staged/lib/ez7gen/service/segment_generator.rb:83:in `generateSegment'
    /Users/romansova/RubymineProjects/ez7gen-staged/lib/ez7gen/service/segment_generator.rb:65:in `block in generate'
    /Users/romansova/RubymineProjects/ez7gen-staged/lib/ez7gen/service/segment_generator.rb:63:in `times'
    /Users/romansova/RubymineProjects/ez7gen-staged/lib/ez7gen/service/segment_generator.rb:63:in `generate'
    /Users/romansova/RubymineProjects/ez7gen-staged/lib/ez7gen/message_factory.rb:40:in `block in generate'
    /Users/romansova/RubymineProjects/ez7gen-staged/lib/ez7gen/message_factory.rb:34:in `each'
    /Users/romansova/RubymineProjects/ez7gen-staged/lib/ez7gen/message_factory.rb:34:in `generate'
    /Users/romansova/RubymineProjects/ez7gen-staged/test/message_factory_test.rb:32:in `test_ADT_01'
    /Users/romansova/.rvm/rubies/ruby-2.1.2/lib/ruby/2.1.0/minitest/unit.rb:1265:in `run'
    /Users/romansova/.rvm/rubies/ruby-2.1.2/lib/ruby/2.1.0/minitest/unit.rb:940:in `block in _run_suite'
    /Users/romansova/.rvm/rubies/ruby-2.1.2/lib/ruby/2.1.0/minitest/unit.rb:933:in `map'
    /Users/romansova/.rvm/rubies/ruby-2.1.2/lib/ruby/2.1.0/minitest/unit.rb:933:in `_run_suite'
    /Users/romansova/.rvm/rubies/ruby-2.1.2/lib/ruby/2.1.0/minitest/unit.rb:914:in `block in _run_suites'
    /Users/romansova/.rvm/rubies/ruby-2.1.2/lib/ruby/2.1.0/minitest/unit.rb:914:in `map'
    /Users/romansova/.rvm/rubies/ruby-2.1.2/lib/ruby/2.1.0/minitest/unit.rb:914:in `_run_suites'
    /Users/romansova/.rvm/rubies/ruby-2.1.2/lib/ruby/2.1.0/minitest/unit.rb:884:in `_run_anything'
    /Users/romansova/.rvm/rubies/ruby-2.1.2/lib/ruby/2.1.0/minitest/unit.rb:1092:in `run_tests'
    /Users/romansova/.rvm/rubies/ruby-2.1.2/lib/ruby/2.1.0/minitest/unit.rb:1079:in `block in _run'
    /Users/romansova/.rvm/rubies/ruby-2.1.2/lib/ruby/2.1.0/minitest/unit.rb:1078:in `each'
    /Users/romansova/.rvm/rubies/ruby-2.1.2/lib/ruby/2.1.0/minitest/unit.rb:1078:in `_run'
    /Users/romansova/.rvm/rubies/ruby-2.1.2/lib/ruby/2.1.0/minitest/unit.rb:1066:in `run'
    /Users/romansova/.rvm/rubies/ruby-2.1.2/lib/ruby/2.1.0/minitest/unit.rb:802:in `block in autorun'
