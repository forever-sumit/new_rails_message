require 'rails_admin/config/actions'
require 'rails_admin/config/actions/base'

module RailsAdminApproveReview
end

module RailsAdmin
  module Config
    module Actions
      class ResendMessage < RailsAdmin::Config::Actions::Base
        RailsAdmin::Config::Actions.register(self)

        register_instance_option :visible? do
          bindings[:abstract_model].to_s == "Contact" && !bindings[:object].sent_at.blank?
        end

        register_instance_option :member? do
          true
        end

        register_instance_option :link_icon do
          'icon-repeat'
        end

        register_instance_option :controller do
          Proc.new do
            @object.regenerate_data()
            message = "Please click on the link "
            message << "#{request.host_with_port}/enter_passcode?uuid=#{@object.uuid}"
            message << "\nYour passcode is #{@object.passcode}"
            @object.send_message(message)
            redirect_to index_path, notice: 'Message sent'
          end
        end
      end
    end
  end
end
