require 'yaml'

module Ez7gen

  VERSION = "0.1.3"

  # Move the Configurator into main module
  class Configurator

      # This works with some corks, will be needed for external location of schema files
      def configure()

        properties_file = File.expand_path('../resources/properties.yml', __FILE__)
        yml = YAML.load_file properties_file
        puts 'Before update schema location:' + ((yml['web.install.dir']) ? yml['web.install.dir'] : 'schema location not set')

        #This will remove all comments
        if(ARGV[0])
          yml['web.install.dir'] =  ARGV[0].gsub("\\", '/') # convert windows path to linux, ruby defaults to that
          File.open(properties_file, 'w') { |f| YAML.dump(yml, f) }
        end

        # This will add multiple properties
        # if(ARGV[0])
        #   file = File.open(propertiesFile, 'a')
        #   file.puts 'schema.dir.location: ' + ARGV[0]
        #   file.flush
        # end


        properties_file = File.expand_path('../resources/properties.yml', __FILE__)
        yml = YAML.load_file properties_file
        puts 'After update schema location:' + ((yml['web.install.dir']!=nil)?yml['web.install.dir']:'schema location not set')
      end
  end

end
