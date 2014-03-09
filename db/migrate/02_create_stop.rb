class CreateStop < ActiveRecord::Migration
	def change
		create_table :stops do |t|

			#available in stops
			t.integer :stopsequence
			t.integer :departure
			t.integer :arrival
			t.float :lat
			t.float :lon
			t.belongs_to :route
		end
	end
end