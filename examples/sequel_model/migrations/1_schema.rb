#!/usr/bin/env ruby

require 'sequel'


Sequel.migration do

	change do
		create_schema :acme

		create_table( :acme__customers ) do
			primary_key :id
			String :first_name, null: false
			String :last_name, null: false
		end
		create_table( :acme__orders ) do
			primary_key :id
			timestamptz :ordered_at, default: Sequel.function(:now)
			timestamptz :updated_at
			foreign_key :customer_id, :acme__customers,
				null: false,
				on_delete: :cascade
		end
		create_table( :acme__order_items ) do
			primary_key :id
			String :sku, null: false
			foreign_key :order_id, :acme__orders,
				null: false,
				on_delete: :cascade
		end
	end

end

