class CreateRoute < ActiveRecord::Migration
	def change
		create_table :routes do |t|
			t.string :carid #in routes
			t.integer :starting #in stops
			t.string :serviceid #in stops
			t.integer :ending #create before_save in stops
			t.string :color # in routes
		end
	end
end