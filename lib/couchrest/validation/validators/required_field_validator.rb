# Extracted from dm-validations 0.9.10
#
# Copyright (c) 2007 Guy van den Berg
# 
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
# 
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

module CouchRest
  module Validation

    ##
    #
    # @author Guy van den Berg
    # @since  0.9
    class RequiredFieldValidator < GenericValidator

      def initialize(field_name, options={})
        super
        @field_name, @options = field_name, options
      end

      def call(target)
        value = target.validation_property_value(field_name)
        property = target.validation_property(field_name)
        return true if present?(value, property)

        error_message = @options[:message] || default_error(property)
        add_error(target, error_message, field_name)

        false
      end

      protected

      # Boolean property types are considered present if non-nil.
      # Other property types are considered present if non-blank.
      # Non-properties are considered present if non-blank.
      def present?(value, property)
        boolean_type?(property) ? !value.nil? : !value.blank?
      end

      def default_error(property)
        actual = boolean_type?(property) ? :nil : :blank
        ValidationErrors.default_error_message(actual, field_name)
      end

      # Is +property+ a boolean property?
      #
      # Returns true for Boolean, ParanoidBoolean, TrueClass, etc. properties.
      # Returns false for other property types.
      # Returns false for non-properties.
      def boolean_type?(property)
        property ? property.type == TrueClass : false
      end

    end # class RequiredFieldValidator

    module ValidatesPresent

      ##
      # Validates that the specified attribute is present.
      #
      # For most property types "being present" is the same as being "not
      # blank" as determined by the attribute's #blank? method. However, in
      # the case of Boolean, "being present" means not nil; i.e. true or
      # false.
      #
      # @note
      #   dm-core's support lib adds the blank? method to many classes,
      # @see lib/dm-core/support/blank.rb (dm-core) for more information.
      #
      # @example [Usage]
      #
      #   class Page
      #
      #     property :required_attribute, String
      #     property :another_required, String
      #     property :yet_again, String
      #
      #     validates_presence_of :required_attribute
      #     validates_presence_of :another_required, :yet_again
      #
      #     # a call to valid? will return false unless
      #     # all three attributes are !blank?
      #   end
      def validates_presence_of(*fields)
        opts = opts_from_validator_args(fields)
        add_validator_to_context(opts, fields, CouchRest::Validation::RequiredFieldValidator)
      end
      
      def validates_present(*fields)
        warn "[DEPRECATION] `validates_present` is deprecated.  Please use `validates_presence_of` instead."
        validates_presence_of(*fields)
      end

    end # module ValidatesPresent
  end # module Validation
end # module CouchRest
