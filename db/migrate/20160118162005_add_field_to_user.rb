class AddFieldToUser < ActiveRecord::Migration
  def change
    add_column :users, :company_name, :string
    add_column :users, :company_website, :string
    add_column :users, :accent_color, :string
    add_column :users, :title, :string
    add_column :users, :subtitle, :string
  end
end
