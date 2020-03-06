# frozen_string_literal: true

require 'af_test_coverage/collectors/action_view/asset_tag_helper'

module AfTestCoverage
  module Collectors
    module ActionView
      class AssetTagCollector
        @@action_view_hook_set = false

        def initialize
          unless @@action_view_hook_set
            ActiveSupport.on_load(:action_view) do
              prepend AfTestCoverage::Collectors::ActionView::AssetTagHelper
            end
            @@action_view_hook_set = true
          end
        end

        def on_start
          @covered_assets_collection = Set.new
        end

        def add_covered_assets(*assets)
          @covered_assets_collection&.merge(assets)
        end

        def covered_files
          test_assets = Set.new(
            @covered_assets_collection.flat_map do |asset_path|
              asset = ::Rails.application.assets[asset_path]
              # It's not clear why an asset would not be found in the cache.  It happens but it seems to happen rarely and repeatably
              # If there is a bug with assets changes not triggering a test to run, look here to see if the asset was not included
              # as a dependency because it was not found in the cache
              puts "Skipping asset #{asset_path} because it was not found in the cache" if asset.nil?
              asset.nil? ? [] : asset.metadata[:dependencies].select { |d| d.ends_with?('.js', '.es6', '.css', '.scss') }
            end
          )
          {}.tap do |coverage_data|
            test_assets.to_a.map do |asset_uri|
              coverage_data[URI.parse(asset_uri).path] = {asset: true}
            end
          end
        end
      end
    end
  end
end
