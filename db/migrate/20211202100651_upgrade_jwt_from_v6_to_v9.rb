class UpgradeJwtFromV6ToV9 < ActiveRecord::Migration[6.0]
  def change
    rename_table :jwt_blacklists, :jwt_denylist
    # remove_index :jwt_blacklists, name: :jti
    # change_column :jwt_blacklists
  end
end
