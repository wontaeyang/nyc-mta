class CreateStation < ActiveRecord::Migration
	def change
		create_table :stations do |t|
			t.string :name
			t.float :lat
			t.float :lon
		end
	end
end