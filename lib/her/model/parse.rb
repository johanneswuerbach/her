module Her
  module Model
    # This module handles resource data parsing at the model level (after the parsing middleware)
    module Parse
      extend ActiveSupport::Concern

      # Convert into a hash of request parameters, based on `include_root_in_json`.
      #
      # @example
      #   @user.to_params
      #   # => { :id => 1, :name => 'John Smith' }
      def to_params
        self.class.to_params(self.attributes)
      end

      module ClassMethods
        # Parse data before assigning it to a resource, based on `parse_root_in_json`.
        #
        # @param [Hash] data
        # @private
        def parse(data)
          parse_root_in_json? ? data[parsed_root_element] : data
        end

        # @private
        def to_params(attributes)
          include_root_in_json? ? { included_root_element => attributes.dup.symbolize_keys } : attributes.dup.symbolize_keys
        end

        # Return or change the value of `include_root_in_json`
        #
        # @example
        #   class User
        #     include Her::Model
        #     include_root_in_json true
        #   end
        def include_root_in_json(value = nil)
          @_her_include_root_in_json ||= begin
            superclass.include_root_in_json if superclass.respond_to?(:include_root_in_json)
          end

          return @_her_include_root_in_json unless value
          @_her_include_root_in_json = value
        end
        alias include_root_in_json? include_root_in_json

        # Return or change the value of `parse_root_in`
        #
        # @example
        #   class User
        #     include Her::Model
        #     parse_root_in_json true
        #   end
        def parse_root_in_json(value = nil)
          @_her_parse_root_in_json ||= begin
            superclass.parse_root_in_json if superclass.respond_to?(:parse_root_in_json)
          end

          return @_her_parse_root_in_json unless value
          @_her_parse_root_in_json = value
        end
        alias parse_root_in_json? parse_root_in_json

        # Return or change the value of `request_new_object_on_build`
        #
        # @example
        #   class User
        #     include Her::Model
        #     request_new_object_on_build true
        #   end
        def request_new_object_on_build(value = nil)
          @_her_request_new_object_on_build ||= begin
            superclass.request_new_object_on_build if superclass.respond_to?(:request_new_object_on_build)
          end

          return @_her_request_new_object_on_build unless value
          @_her_request_new_object_on_build = value
        end
        alias request_new_object_on_build? request_new_object_on_build

        # Return or change the value of `root_element`. Always defaults to the base name of the class.
        #
        # @example
        #   class User
        #     include Her::Model
        #     parse_root_in_json true
        #     root_element :huh
        #   end
        #
        #   user = User.find(1) # { :huh => { :id => 1, :name => "Tobias" } }
        #   user.name # => "Tobias"
        def root_element(value = nil)
          if value.nil?
            @_her_root_element ||= self.name.split("::").last.underscore.to_sym
          else
            @_her_root_element = value.to_sym
          end
        end

        # @private
        def included_root_element
          include_root_in_json == true ? root_element : include_root_in_json
        end

        # @private
        def parsed_root_element
          parse_root_in_json == true ? root_element : parse_root_in_json
        end
      end
    end
  end
end
