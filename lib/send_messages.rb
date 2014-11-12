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
              message = "建行(亞洲)CCB(Asia)：感謝您對我們「網上銀行」服務的支持。現奉上Pacific Coffee 8安士細杯裝手調飲品電子現金券，請按 "
              message << "#{request.host_with_port}/ep?u=#{@object.uuid} "
              message << "領取. 驗證碼: "
              message << "#{@object.passcode}"
              message << " 受條款約束 查詢EN/取消UN 29038303"
              contact.send_message(message)
            end
            redirect_to back_or_index, notice: 'Messages send to selected contacts'
          end
        end
      end
    end
  end
end
