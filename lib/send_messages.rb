require 'rails_admin/config/actions'
require 'rails_admin/config/actions/base'

module RailsAdminApproveReview
end

module RailsAdmin
  module Config
    module Actions
      class SendMessages < RailsAdmin::Config::Actions::Base
        RailsAdmin::Config::Actions.register(self)

        register_instance_option :visible? do
          bindings[:abstract_model].to_s == "Contact"
        end

        register_instance_option :link_icon do
          'icon-send'
        end

        register_instance_option :bulkable? do
          true
        end

        register_instance_option :controller do
          Proc.new do
            # Get all selected rows
            @objects = list_entries(@model_config, :destroy)
            #contacts = Contact.where("id in(?)", params[:collection_selection])
            @objects.each do |contact|
              message = "Please click on the link "
              message << "#{request.host_with_port}/enter_passcode?uuid=#{contact.uuid}"
              message << "\nYour passcode is #{contact.passcode}"
              contact.send_message(message)
            end
            redirect_to back_or_index, notice: 'Messages send to selected contacts'
          end
        end
      end
    end
  end
end
