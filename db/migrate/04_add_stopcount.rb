class AddStopcount < ActiveRecord::Migration
	def change
		add_column :routes, :stop_count, :integer
	end
end