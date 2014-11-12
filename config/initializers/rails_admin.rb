RailsAdmin.config do |config|

  require Rails.root.join('lib', 'send_message.rb')
  require Rails.root.join('lib', 'resend_message.rb')
  require Rails.root.join('lib', 'send_messages.rb')
  ### Popular gems integration

  ## == Devise ==
  # config.authenticate_with do
  #   warden.authenticate! scope: :user
  # end
  # config.current_user_method(&:current_user)

  ## == Cancan ==
  # config.authorize_with :cancan

  ## == PaperTrail ==
  # config.audit_with :paper_trail, 'User', 'PaperTrail::Version' # PaperTrail >= 3.0.0

  ### More at https://github.com/sferik/rails_admin/wiki/Base-configuration

  config.actions do
    dashboard                     # mandatory
    index                         # mandatory
    new
    #send_message
    export
    bulk_delete
    show
    edit
    delete
    show_in_app

    # Set the custom action here
    send_messages
    send_message
    resend_message

    collection :import_contact do
      register_instance_option :link_icon do
        'icon-upload'
      end

      register_instance_option :visible? do
        bindings[:abstract_model].to_s == "Contact"
      end

      register_instance_option :http_methods do
        [:get, :post]
      end

      register_instance_option :pjax? do
        false
      end

      register_instance_option :controller do
        Proc.new do
          if request.get?
            render "/contacts/upload_phone_numbers"
          else
          file = params[:contacts]
            begin
              case File.extname(file.original_filename)
              when '.csv'
                Contact.upload_csv(file)
                redirect_to :action => :index, :notice => "CSV imported successfully!"
              when '.txt'
                Contact.upload_txt(file)
                redirect_to :action => :index, :notice => "CSV imported successfully!"
              else
                flash[:error] = "Unknown file type: #{file.original_filename}. Please upload .csv or .txt file"
                render "/contacts/upload_phone_numbers"
              end
            rescue Exception => e
              Rails.logger.error e.message
              Rails.logger.error e.backtrace.join("\n")
              flash[:error] = "something wrong"
              render "/contacts/upload_phone_numbers"
            end
          end
        end
      end
    end
  end



  config.authenticate_with do
    warden.authenticate! scope: :admin
  end
  config.current_user_method(&:current_admin)
end
