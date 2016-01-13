class CLLI
  ##
  # This module provides methods to load external data from YAML files.
  class YAMLData
    class << self
      @cache = nil

      ##
      # Expand the relative path into a real path.
      #
      # Params:
      # +paths+:: a splat containing the path names.
      def real_path(*paths)
        File.join([File.dirname(__FILE__), '..'] + paths)
      end
    end

    ##
    # Create a new +YAMLData+ object loading the data from the specified YAML
    # file.
    #
    # Params:
    # +paths+:: a splat containing the path names.
    def initialize(*paths)
      @cache = YAML.load_file(self.class.real_path(paths)).freeze
    end

    ##
    # Get the +Hash+ keys from the cached data.
    def keys
      @cache.keys
    end

    ##
    # Get the cached data +Hash+. Note the +hash+ is frozen, any modification
    # will cause a +RuntimeError+ to be thrown.
    def data
      @cache
    end

    ##
    # Get the data at the corresponding keys. Note the keys are interpreted as a
    # tree. So a second key indicates that the first key returns a +Hash+ which
    # contains the second key. If no matching records are found then +nil+ will
    # be returned.
    #
    # Porams:
    # +keys+:: the keys to lookup.
    def get(*keys)
      keys.inject(@cache) do |data, key|
        return nil unless data.respond_to?(:[])
        data[key]
      end
    end
  end
end
