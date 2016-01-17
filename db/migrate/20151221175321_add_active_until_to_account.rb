class AddActiveUntilToAccount < ActiveRecord::Migration
  def change
    add_column :accounts, :active_until, :datetime
  end
end
