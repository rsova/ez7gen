require 'yaml'

module Ez7gen

  VERSION = "0.0.5"

  # Move the Configurator into main module
  class Configurator

      # This works with some corks, will be needed for external location of schema files
      def configure()
        propertiesFile = File.expand_path('../resources/properties.yml', __FILE__)
        yml = YAML.load_file propertiesFile
        puts 'Before update schema location:' + ((yml['web.install.dir']) ? yml['web.install.dir'] : 'schema location not set')

        #This will remove all comments
        if(ARGV[0])
          yml['web.install.dir'] =  ARGV[0]
          File.open(propertiesFile, 'w') { |f| YAML.dump(yml, f) }
        end

        # This will add multiple properties
        # if(ARGV[0])
        #   file = File.open(propertiesFile, 'a')
        #   file.puts 'schema.dir.location: ' + ARGV[0]
        #   file.flush
        # end


        propertiesFile = File.expand_path('../resources/properties.yml', __FILE__)
        yml = YAML.load_file propertiesFile
        puts 'After update schema location:' + ((yml['web.install.dir']!=nil)?yml['web.install.dir']:'schema location not set')
      end
  end

end
