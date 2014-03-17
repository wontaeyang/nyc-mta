class AddIndexStop < ActiveRecord::Migration
	def change
		add_index :stops, :route_id
	end
end