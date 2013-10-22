require_relative './associatable'
require_relative './db_connection'
require_relative './mass_object'
require_relative './searchable'
require 'active_support/inflector'

class SQLObject < MassObject

  extend Searchable, Associatable

  def self.set_table_name(table_name)
    @table_name = table_name.underscore
  end

  def self.table_name
    @table_name
  end

  def self.all
    parse_all(DBConnection.execute("SELECT * FROM #{table_name}"))
  end

  def self.find(id)
    parse_all(DBConnection.execute("SELECT * FROM #{table_name} WHERE id = ?", id)).first
  end

  def save
    self.id.nil? ? create : update
  end

  private

  def create
    attributes = attribute_values

    sql = "INSERT INTO #{self.class.table_name} (#{attributes[:columns].join(", ")}) VALUES (#{attributes[:q_marks]})"

    DBConnection.execute(sql, *attributes[:values])
    self.id = DBConnection.last_insert_row_id
  end

  def update
    attributes = attribute_values
    set_string = attributes[:columns].map { |column| "#{column} = ?" }.join(", ")

    sql = "UPDATE #{self.class.table_name} SET #{set_string} WHERE id = ?"

    DBConnection.execute(sql, *attributes[:values], self.id)
  end

  def attribute_values
    insertable_attributes = self.class.attributes[1..-1]

    {
      columns: insertable_attributes,
      values: insertable_attributes.map { |attr| send(attr) },
      q_marks: (['?'] * insertable_attributes.length).join(", ")
    }
  end
end
