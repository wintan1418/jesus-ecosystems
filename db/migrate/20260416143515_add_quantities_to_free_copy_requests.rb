class AddQuantitiesToFreeCopyRequests < ActiveRecord::Migration[8.1]
  def change
    add_column :free_copy_requests, :qty_vol_1,       :integer, default: 0, null: false
    add_column :free_copy_requests, :qty_vol_1_combo, :integer, default: 0, null: false
    # Email is optional per the designer's spec — relax NOT NULL.
    change_column_null :free_copy_requests, :email, true
  end
end
