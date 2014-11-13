require 'open-uri'

class Contact < ActiveRecord::Base
  has_attached_file :qr_code
  validates_attachment :qr_code, content_type: { content_type: /\Aimage\/.*\Z/ }

  validates_presence_of :phone_no, :serial_number, :bar_code
  before_create :validate_phone, if: "!phone_no.blank?"
  before_create :create_other_attributes
  before_create :generate_qrcode
  after_create :delete_temp_qrcode
  before_update :make_code_invalid

  def self.upload_csv(csv_data)
    CSV.foreach(csv_data.path, :headers => true, :header_converters => [:downcase]) do |row|
      self.create(phone_no: row["mobile number"], serial_number: row["serial number"], bar_code: row["bar code"])
    end
  end

  def self.upload_txt(txt_data)
    rows = txt_data.read.split("\n")
    rows.each do |row|
      data = row.split(",")
      self.create(phone_no: data[0].strip, bar_code: data[1].strip, serial_number: data[2].strip )
    end
  end

  def send_message(message)
    begin
      Client.messages.create(from: TWILIO_NUMBER, to: self.phone_no, body: message)
      self.sent_at = DateTime.now
      self.save
    rescue Twilio::REST::RequestError => e
      logger.error "error #{e}"
    end
  end

  def is_valid_url?
    !is_invalid
  end

  def regenerate_data()
    #self.passcode = Devise.friendly_token.first(8)
    #self.attempt_count = 0
    #self.is_invalid = false
    #self.save
  end

  rails_admin do
    create do
      field :phone_no
      field :bar_code
      field :serial_number
    end

    list do
      field :phone_no
      field :uuid
      field :passcode
      field :qr_code
      field :sent_at
    end
  end

  private

    def create_other_attributes
      #self.uuid = UUIDTools::UUID.random_create.to_s
      self.uuid = SecureRandom.urlsafe_base64(6)
      self.passcode = Devise.friendly_token.first(6)
    end

    def generate_qrcode
      #qr = RQRCode::QRCode.new( self.uuid, :size => 10, :level => :l )
      #png = qr.to_img
      #file_name = Rails.root.to_s + "/public/" + SecureRandom.hex(32) + ".png"
      #png.resize(90, 90).save(file_name)
      #file = File.open(file_name)
      #self.qr_code = file                                                    
      
      file_name = Rails.root.to_s + "/public/" + SecureRandom.hex(32) + ".png"      
      open(image_url(self.uuid, self.serial_number)) {|f|
        File.open(file_name, "wb") do |file|
          file.puts f.read          
        end         
      }     
      file = File.open(file_name) 
      self.qr_code = file
    end

    def image_url(code, serial_number)
      path = "http://qrickit.com/api/qr?d=#{code}&addtext=SERIAL+NUMBER:%20+#{serial_number}&txtcolor=000000&fgdcolor=000000&bgdcolor=ffffff&qrsize=300&t=p&e=m" 
      puts "Image URL: #{path}"
      return path
    end

    def delete_temp_qrcode
      #file_name = Rails.root.to_s + "/public/" + self.qr_code.original_filename
      #File.delete(file_name)
    end

    def make_code_invalid
      self.is_invalid = true if self.attempt_count == 10
    end

    def validate_phone
      if Phonie::Phone.parse self.phone_no
        self.phone_no = "+#{self.phone_no}" unless self.phone_no.include?('+')
      else
        self.errors.add(:phone_no, "#{self.phone_no} is not a valid number.")
        return false
      end
      true
    end

end
