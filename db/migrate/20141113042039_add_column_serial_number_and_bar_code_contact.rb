class AddColumnSerialNumberAndBarCodeContact < ActiveRecord::Migration
  def change
    add_column :contacts, :serial_number, :string
    add_column :contacts, :bar_code, :string
  end
end
