require 'rails_admin/config/actions'
require 'rails_admin/config/actions/base'

module RailsAdminApproveReview
end

module RailsAdmin
  module Config
    module Actions
      class SampleFile < RailsAdmin::Config::Actions::Base
        RailsAdmin::Config::Actions.register(self)

        register_instance_option :visible? do
        end

        register_instance_option :collection? do
          true
        end

        register_instance_option :controller do
          Proc.new do
            csv_file_location = [Rails.root.to_s, "config", "sample_files", "sample_csv.csv"].join("/")
            txt_file_location = [Rails.root.to_s, "config", "sample_files", "sample_txt.txt"].join("/")
            case params["format"]
            when "csv"
              send_file csv_file_location, :type => 'application/csv', :filename => "sample_csv.csv" 
            when "txt"
              send_file txt_file_location, :type => 'application/txt', :filename => "sample_txt.txt"
            else
              flash[:notice] = "Unsupported file"
              redirect_to import_contact_path
            end
          end
        end
      
      end
    end
  end
end
