# frozen_string_literal: true

require 'ae_test_coverage/collectors/active_record/model_collector'
require 'ae_test_coverage/collectors/active_record/association_helper'

module AeTestCoverage
  module Collectors
    module ActiveRecord
      class AssociationCollector < ModelCollector

        private

        def set_hook
          ActiveSupport.on_load(:active_record) do
            include AssociationHelper
          end
        end

        def data
          {association_referenced: true}
        end
      end
    end
  end
end
