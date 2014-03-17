class AddIndex < ActiveRecord::Migration
	def change
		add_index :routes, :starting
	end
end